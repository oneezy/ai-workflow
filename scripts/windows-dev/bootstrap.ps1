#requires -Version 7.4
[CmdletBinding()]
param(
    [ValidateSet('Audit','Plan','Install','Update','Verify','Enter')]
    [string]$Mode = 'Audit',
    [string]$Manifest = (Join-Path $PSScriptRoot 'versions.json'),
    [string]$PlanFile,
    [string]$Root = (Join-Path $env:LOCALAPPDATA 'JustinDevToolchain'),
    [switch]$Apply,
    [string]$ApprovedPlanSha256,
    [string]$ShellPath,
    [switch]$LibraryOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:BootstrapFile = $PSCommandPath

function Get-Sha256([string]$File) {
    (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Write-JsonNew([string]$File, $Value) {
    $stream = [IO.File]::Open($File, 'CreateNew', 'Write', 'None')
    try {
        $bytes = [Text.Encoding]::UTF8.GetBytes(($Value | ConvertTo-Json -Depth 20))
        $stream.Write($bytes)
    } finally { $stream.Dispose() }
}
function Get-DeduplicatedPath([string[]]$Entries) {
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $result = foreach ($entry in $Entries) {
        $trimmed = $entry.Trim().Trim('"').TrimEnd('\','/')
        if ($trimmed -and $seen.Add([Environment]::ExpandEnvironmentVariables($trimmed))) { $entry.Trim() }
    }
    $result -join ';'
}
function Assert-LocalRoot([string]$Directory) {
    if ($Directory -notmatch '^[A-Za-z]:\\' -or $Directory -match '[;\r\n]') {
        throw 'Use an absolute local Windows path without semicolons.'
    }
    $full = [IO.Path]::GetFullPath($Directory).TrimEnd('\')
    if ($full.Length -lt 4 -or $full -eq $env:USERPROFILE -or $full -eq $env:LOCALAPPDATA) {
        throw 'The toolchain needs a dedicated subdirectory.'
    }
    $check = $full
    while ($check) {
        if (Test-Path -LiteralPath $check) {
            if ((Get-Item -LiteralPath $check -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw "Root or ancestor is a junction/symlink: $check"
            }
        }
        $check = Split-Path -Path $check -Parent
    }
    $full
}
function Get-ProtectedState {
    $files = @(
        "$env:USERPROFILE\.npmrc",
        "$env:USERPROFILE\.bashrc",
        "$env:USERPROFILE\.bash_profile",
        "$env:USERPROFILE\Documents\PowerShell\profile.ps1",
        "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        "$env:USERPROFILE\Documents\PowerShell\CTTcustom.ps1",
        "$env:APPDATA\Code\User\settings.json",
        "$env:APPDATA\Code\User\profiles\-4a0d1427\settings.json",
        "$env:USERPROFILE\.codex\config.toml"
    )
    [ordered]@{
        UserPath = [Environment]::GetEnvironmentVariable('Path','User')
        MachinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
        UserVpHome = [Environment]::GetEnvironmentVariable('VP_HOME','User')
        MachineVpHome = [Environment]::GetEnvironmentVariable('VP_HOME','Machine')
        Files = @($files | ForEach-Object {
            [ordered]@{ Path = $_; Hash = if (Test-Path -LiteralPath $_ -PathType Leaf) { Get-Sha256 $_ } else { $null } }
        })
    }
}
function Assert-SameState($Expected, $Actual) {
    $a = $Expected | ConvertTo-Json -Depth 10 -Compress
    $b = $Actual | ConvertTo-Json -Depth 10 -Compress
    if ($a -cne $b) { throw 'PATH, profile, npm, or Codex settings changed since planning. Create and review a fresh plan.' }
}
function Read-Versions([string]$File) {
    $v = Get-Content -Raw -LiteralPath $File | ConvertFrom-Json
    foreach ($key in 'vp','node','pnpm','npm','codex') {
        if ($v.$key -notmatch '^\d+\.\d+\.\d+$') { throw "An exact stable version is required for $key." }
    }
    # This internal no-profile-change flag was reviewed against this release.
    if ($v.vp -ne '0.3.2') { throw 'Review Vite+ self-setup behavior before changing the supported version.' }
    if (@($v.artifacts).Count -ne 2 -or @($v.artifacts.Name | Sort-Object -Unique).Count -ne 2) { throw 'Exactly one vp and one codex artifact are required.' }
    if ($v.architecture -ne 'x64') { throw 'This reviewed bootstrap supports Windows x64 only.' }
    $v
}
function Get-ReleaseId($Versions) {
    "vp-$($Versions.vp)_node-$($Versions.node)_pnpm-$($Versions.pnpm)_npm-$($Versions.npm)_codex-$($Versions.codex)"
}
function Get-Audit {
    $names = 'vp','node','npm','pnpm','nvm','codex','git','gh','copilot','code','pwsh','bash','nu','oh-my-posh','zoxide','rg','python','uv','deno','docker'
    [ordered]@{
        TimeUtc = [DateTime]::UtcNow.ToString('o')
        PowerShell = $PSVersionTable.PSVersion.ToString()
        Architecture = [Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
        Commands = @(foreach ($name in $names) {
            $commands = @(Get-Command $name -All -ErrorAction SilentlyContinue)
            [ordered]@{ Name=$name; Paths=@($commands | ForEach-Object Source) }
        })
        Protected = Get-ProtectedState
        Note = 'No executable version probes, downloads, profiles, or package-manager shims run during audit.'
    }
}
function Get-ChildEnvironment([string]$Release, $Versions) {
    # Pass no inherited credentials, npm prefix, node options, CI tokens, or Vite overrides.
    $environment = @{}
    foreach ($key in 'SystemRoot','WINDIR','SystemDrive','COMSPEC','USERPROFILE','LOCALAPPDATA','APPDATA','TEMP','TMP','PATHEXT','PROCESSOR_ARCHITECTURE','NUMBER_OF_PROCESSORS') {
        $value = [Environment]::GetEnvironmentVariable($key)
        if ($null -ne $value) { $environment[$key] = $value }
    }
    $environment['PATH'] = Get-DeduplicatedPath @("$Release\vite-plus\bin","$env:SystemRoot\System32",'C:\Program Files\Git\cmd')
    $environment['VP_HOME'] = "$Release\vite-plus"
    $environment['VP_SELF_SETUP_NO_MODIFY_PATH'] = '1'
    $environment['VP_NODE_MANAGER'] = 'yes'
    $environment['VP_PM_MANAGER'] = 'yes'
    $environment['VP_NODE_VERSION'] = $Versions.node
    $environment['VP_PNPM_VERSION'] = $Versions.pnpm
    $environment['VP_NPM_VERSION'] = $Versions.npm
    $environment['NPM_CONFIG_REGISTRY'] = 'https://registry.npmjs.org'
    $environment['NPM_CONFIG_USERCONFIG'] = "$Release\empty.npmrc"
    $environment['CI'] = '1'
    $environment['NO_COLOR'] = '1'
    $environment
}
function Invoke-Child([string]$Exe, [string[]]$Arguments, [hashtable]$Environment, [string]$Directory, [int]$TimeoutSeconds = 600) {
    $info = [Diagnostics.ProcessStartInfo]::new($Exe)
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.WorkingDirectory = $Directory
    foreach ($arg in $Arguments) { $info.ArgumentList.Add($arg) }
    $info.Environment.Clear()
    foreach ($key in $Environment.Keys) { $info.Environment[$key] = $Environment[$key] }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    try {
        if (-not $process.Start()) { throw "Could not launch $Exe" }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
            $process.Kill($true)
            throw "Timed out running $(Split-Path $Exe -Leaf). Partial files are retained."
        }
        $out = $stdout.GetAwaiter().GetResult()
        $null = $stderr.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) { throw "$(Split-Path $Exe -Leaf) exited $($process.ExitCode). Output omitted from logs to avoid secrets." }
        return $out.Trim()
    } finally { $process.Dispose() }
}
function Assert-Artifact($Artifact, $Versions) {
    if ($Artifact.Name -eq 'vp') {
        $expected = "https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-win32-x64-msvc/-/vite-plus-cli-win32-x64-msvc-$($Versions.vp).tgz"
        if ($Artifact.Url -cne $expected -or $Artifact.Integrity -notmatch '^sha512-[A-Za-z0-9+/]{86}==$') { throw 'Invalid Vite+ source or integrity.' }
    } elseif ($Artifact.Name -eq 'codex') {
        $expected = "https://github.com/openai/codex/releases/download/rust-v$($Versions.codex)/codex-package-x86_64-pc-windows-msvc.tar.gz"
        if ($Artifact.Url -cne $expected -or $Artifact.Integrity -notmatch '^sha256:[a-f0-9]{64}$') { throw 'Invalid Codex source or integrity.' }
    } else { throw 'Unknown artifact.' }
}
function Test-ArtifactHash([string]$File, [string]$Integrity) {
    if ($Integrity.StartsWith('sha256:')) { return (Get-Sha256 $File) -ceq $Integrity.Substring(7) }
    if ($Integrity.StartsWith('sha512-')) {
        $stream = [IO.File]::OpenRead($File)
        $sha = [Security.Cryptography.SHA512]::Create()
        try { $actual = [Convert]::ToBase64String($sha.ComputeHash($stream)) }
        finally { $stream.Dispose(); $sha.Dispose() }
        return $actual -ceq $Integrity.Substring(7)
    }
    return $false
}
function Expand-CheckedTar([string]$Archive, [string]$Destination) {
    # Inspect every member before extracting. Refuse links, absolute paths, and traversal.
    $stream = [IO.File]::OpenRead($Archive)
    $gzip = [IO.Compression.GZipStream]::new($stream,[IO.Compression.CompressionMode]::Decompress)
    $reader = [System.Formats.Tar.TarReader]::new($gzip)
    try {
        while ($entry = $reader.GetNextEntry()) {
            $name = $entry.Name.Replace('\','/')
            if ($name -match '(^/|^[A-Za-z]:|(^|/)\.\.(/|$)|:)' -or
                $entry.EntryType.ToString() -notin @('RegularFile','V7RegularFile','Directory')) {
                throw "Unsafe archive member: $name"
            }
        }
    } finally { $reader.Dispose(); $gzip.Dispose(); $stream.Dispose() }
    [IO.Directory]::CreateDirectory($Destination) | Out-Null
    $stream = [IO.File]::OpenRead($Archive)
    $gzip = [IO.Compression.GZipStream]::new($stream,[IO.Compression.CompressionMode]::Decompress)
    try { [System.Formats.Tar.TarFile]::ExtractToDirectory($gzip,$Destination,$false) }
    finally { $gzip.Dispose(); $stream.Dispose() }
}
function Get-OwnedFiles([string]$Release) {
    # Immutable executables and configuration, not mutable runtime caches/history.
    $paths = @(
        "$Release\vite-plus\current\bin\vp.exe",
        "$Release\vite-plus\current\bin\vp-shim.exe",
        "$Release\vite-plus\config.json",
        "$Release\empty.npmrc"
    )
    $paths += @(Get-ChildItem -LiteralPath "$Release\codex" -File -Recurse | Select-Object -ExpandProperty FullName)
    $paths += @(Get-ChildItem -LiteralPath "$Release\vite-plus\bin" -File | Select-Object -ExpandProperty FullName)
    @($paths | Where-Object {Test-Path -LiteralPath $_ -PathType Leaf} | Sort-Object -Unique | ForEach-Object {
        [ordered]@{Path=$_;Hash=Get-Sha256 $_}
    })
}
function Assert-OwnedFiles($Receipt) {
    foreach ($file in $Receipt.Files) {
        if (-not (Test-Path -LiteralPath $file.Path -PathType Leaf) -or (Get-Sha256 $file.Path) -cne $file.Hash) {
            throw "Local change or missing managed file: $($file.Path). Preserve it and review recovery."
        }
    }
}
function Test-Release([string]$Release,$Versions) {
    $envMap = Get-ChildEnvironment $Release $Versions
    $vp = "$Release\vite-plus\bin\vp.exe"
    $codex = "$Release\codex\bin\codex.exe"
    if (-not (Test-Path -LiteralPath $codex)) { $codex = "$Release\codex\codex.exe" }
    $checks = @(
        @{Name='vp';Exe=$vp;Args=@('--version');Pattern="(?m)^vp v$([regex]::Escape($Versions.vp))(\s|$)"},
        @{Name='node';Exe="$Release\vite-plus\bin\node.exe";Args=@('--version');Pattern="^v$([regex]::Escape($Versions.node))$"},
        @{Name='pnpm';Exe="$Release\vite-plus\bin\pnpm.exe";Args=@('--version');Pattern="^$([regex]::Escape($Versions.pnpm))$"},
        @{Name='npm';Exe="$Release\vite-plus\bin\npm.exe";Args=@('--version');Pattern="^$([regex]::Escape($Versions.npm))$"},
        @{Name='codex';Exe=$codex;Args=@('--version');Pattern="^codex-cli $([regex]::Escape($Versions.codex))$"}
    )
    foreach ($check in $checks) {
        if (-not (Test-Path -LiteralPath $check.Exe)) { throw "Missing $($check.Exe)" }
        $out = Invoke-Child $check.Exe $check.Args $envMap $Release 60
        if ($out -notmatch $check.Pattern) { throw "$($check.Name) version mismatch." }
    }
    $checks | ForEach-Object { [ordered]@{Tool=$_.Name;Path=$_.Exe;Passed=$true} }
}
function Invoke-Bootstrap {
    if (-not $IsWindows) { throw 'Run with native Windows PowerShell 7.4 or newer.' }
    if ($Apply -and $Mode -notin @('Install','Update')) { throw '-Apply is only valid with Install or Update.' }
    $versions = Read-Versions $Manifest
    $rootPath = Assert-LocalRoot $Root
    $release = Join-Path $rootPath (Get-ReleaseId $versions)
    if ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() -ne 'X64') { throw 'Windows x64 is required.' }
    if ($Mode -eq 'Audit') { Get-Audit | ConvertTo-Json -Depth 12; return }
    if ($Mode -eq 'Plan') {
        if (-not $PlanFile) { throw 'Specify -PlanFile for a new reviewable plan.' }
        $plan = [ordered]@{
            Schema=1; Root=$rootPath; Release=$release
            ManifestHash=Get-Sha256 $Manifest
            ScriptHash=Get-Sha256 $script:BootstrapFile
            Versions=$versions
            Before=Get-ProtectedState
            Artifacts=$versions.artifacts
            Changes=@(
                "Create only $release and its downloaded packages, runtime data, logs, and receipt.",
                'Vite+ manages the recorded Node/npm/pnpm versions in a private VP_HOME.',
                'No persisted PATH, shell/profile, npmrc, Codex config, model, auth, or VS Code changes.',
                'No NVM removal, old-package removal, repository copy, project upgrade, or scheduled update.',
                'Enter starts a chosen child shell with a deduplicated process PATH. Closing it restores the old environment.'
            )
        }
        foreach ($artifact in $plan.Artifacts) { Assert-Artifact $artifact $versions }
        Write-JsonNew $PlanFile $plan
        [ordered]@{PlanFile=$PlanFile;Sha256=Get-Sha256 $PlanFile;Changes=$plan.Changes} | ConvertTo-Json -Depth 6
        return
    }
    $receiptFile = "$release\receipt.json"
    if ($Mode -in @('Verify','Enter')) {
        if (-not (Test-Path -LiteralPath $receiptFile)) { throw 'No successful installation receipt.' }
        $receipt = Get-Content -Raw -LiteralPath $receiptFile | ConvertFrom-Json
        if ($receipt.ManifestHash -cne (Get-Sha256 $Manifest)) { throw 'Manifest differs from installed receipt.' }
        Assert-OwnedFiles $receipt
        $checks = @(Test-Release $release $versions)
        if ($Mode -eq 'Verify') { $checks | ConvertTo-Json; return }
        if (-not $ShellPath -or -not (Test-Path -LiteralPath $ShellPath -PathType Leaf) -or
            $ShellPath -notmatch '^[A-Za-z]:\\' -or $ShellPath -notmatch '\.exe$') {
            throw 'Enter requires an explicit absolute native shell .exe path.'
        }
        $codexBin = if (Test-Path -LiteralPath "$release\codex\bin\codex.exe") { "$release\codex\bin" } else { "$release\codex" }
        $savedPath = $env:Path
        $savedVp = $env:VP_HOME
        try {
            $env:VP_HOME = "$release\vite-plus"
            $env:Path = Get-DeduplicatedPath (@("$release\vite-plus\bin",$codexBin) + ($savedPath -split ';'))
            Write-Host "Session only. Close this child shell to return to the previous environment."
            & $ShellPath
        } finally { $env:Path=$savedPath; $env:VP_HOME=$savedVp }
        return
    }
    if (-not $Apply) {
        [ordered]@{DryRun=$true;Mode=$Mode;Release=$release;Next='Create a Plan, review its exact changes, then supply -Apply and -ApprovedPlanSha256.'} | ConvertTo-Json
        return
    }
    if (-not $PlanFile -or $ApprovedPlanSha256 -notmatch '^[a-fA-F0-9]{64}$' -or
        (Get-Sha256 $PlanFile) -ne $ApprovedPlanSha256.ToLowerInvariant()) { throw 'Supply the reviewed plan and its exact SHA-256.' }
    $plan = Get-Content -Raw -LiteralPath $PlanFile | ConvertFrom-Json
    if ($plan.Schema -ne 1 -or $plan.Root -cne $rootPath -or $plan.Release -cne $release -or
        $plan.ManifestHash -cne (Get-Sha256 $Manifest) -or $plan.ScriptHash -cne (Get-Sha256 $script:BootstrapFile)) {
        throw 'Script, manifest, or destination differs from reviewed plan.'
    }
    foreach ($artifact in $versions.artifacts) { Assert-Artifact $artifact $versions }
    if (Test-Path -LiteralPath $receiptFile) {
        $receipt = Get-Content -Raw -LiteralPath $receiptFile | ConvertFrom-Json
        if ($receipt.ManifestHash -cne $plan.ManifestHash) { throw 'Existing receipt conflict.' }
        Assert-OwnedFiles $receipt
        Test-Release $release $versions | ConvertTo-Json
        return
    }
    Assert-SameState $plan.Before (Get-ProtectedState)
    if (Test-Path -LiteralPath $release) { throw 'Destination already exists without a successful receipt. Preserve partial files; review recovery.' }
    if (Test-Path -LiteralPath $rootPath) {
        Assert-LocalRoot $rootPath | Out-Null
    } else { [IO.Directory]::CreateDirectory($rootPath) | Out-Null }
    $lock = [IO.File]::Open("$rootPath\.bootstrap.lock",'OpenOrCreate','ReadWrite','None')
    try {
        if (Test-Path -LiteralPath $release) { throw 'Concurrent installation or destination conflict.' }
        [IO.Directory]::CreateDirectory($release) | Out-Null
        Write-JsonNew "$release\before.json" $plan.Before
        [IO.File]::WriteAllText("$release\empty.npmrc",'')
        Write-JsonNew "$release\started.json" @{TimeUtc=[DateTime]::UtcNow.ToString('o');PlanHash=$ApprovedPlanSha256}
        foreach ($artifact in $versions.artifacts) {
            Write-Host "Downloading verified $($artifact.Name) archive."
            $archive = "$release\$($artifact.Name).tar.gz"
            Invoke-WebRequest -Uri $artifact.Url -OutFile $archive -TimeoutSec 180
            if (-not (Test-ArtifactHash $archive $artifact.Integrity)) { throw "$($artifact.Name) integrity mismatch. Nothing from this archive was executed." }
            Expand-CheckedTar $archive "$release\$($artifact.Name)-payload"
        }
        $envMap = Get-ChildEnvironment $release $versions
        # The reviewed Vite+ release self-installs on first execution. CI prevents cleanup prompts.
        $null = Invoke-Child "$release\vp-payload\package\vp.exe" @('--version') $envMap $release
        foreach ($spec in @("node@$($versions.node)","pnpm@$($versions.pnpm)","npm@$($versions.npm)")) {
            $null = Invoke-Child "$release\vite-plus\bin\vp.exe" @('env','install',$spec) $envMap $release
            $null = Invoke-Child "$release\vite-plus\bin\vp.exe" @('env','default',$spec) $envMap $release
        }
        # Keep the complete official package, including Codex's companion executables.
        [IO.Directory]::Move("$release\codex-payload","$release\codex")
        $checks = @(Test-Release $release $versions)
        Assert-SameState $plan.Before (Get-ProtectedState)
        Write-JsonNew $receiptFile ([ordered]@{
            TimeUtc=[DateTime]::UtcNow.ToString('o'); ManifestHash=$plan.ManifestHash
            PlanHash=$ApprovedPlanSha256; Versions=$versions; Checks=$checks
            Files=@(Get-OwnedFiles $release)
        })
        Write-Host "Verified installation retained at $release. No persistent activation performed."
    } catch {
        Write-Host 'Stopped. Partial files are retained for inspection. Existing toolchains were not removed.'
        throw
    } finally { $lock.Dispose() }
}
if (-not $LibraryOnly) { Invoke-Bootstrap }
