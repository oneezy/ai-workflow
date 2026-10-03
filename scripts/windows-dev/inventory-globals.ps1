#requires -Version 7.4
# Read-only. Exports package names/versions and tool ownership metadata; never auth values.
[CmdletBinding()]
param([string]$OutputFile)
$ErrorActionPreference='Stop'
function Read-GlobalPackages([string]$Modules) {
    if (-not (Test-Path -LiteralPath $Modules)) { return }
    foreach($dir in Get-ChildItem -LiteralPath $Modules -Directory -Force) {
        $candidates = if ($dir.Name.StartsWith('@')) { @(Get-ChildItem -LiteralPath $dir.FullName -Directory) } else { @($dir) }
        foreach($package in $candidates) {
            $file=Join-Path $package.FullName 'package.json'
            if (Test-Path -LiteralPath $file) {
                try {
                    $m=Get-Content -Raw -LiteralPath $file | ConvertFrom-Json
                    [ordered]@{Name=$m.name;Version=$m.version;Path=$package.FullName;Bin=$m.bin}
                } catch {
                    [ordered]@{Path=$package.FullName;Error='Manifest unavailable'}
                }
            }
        }
    }
}
$nvmRoot=Join-Path $env:LOCALAPPDATA 'nvm'
$roots=@()
if(Test-Path -LiteralPath $nvmRoot) {
    $roots += @(Get-ChildItem -LiteralPath $nvmRoot -Directory | Where-Object Name -match '^v\d+\.' | ForEach-Object {
        [ordered]@{Owner="NVM $($_.Name)";Prefix=$_.FullName}
    })
}
$roots += @(
    @{Owner='Roaming npm';Prefix="$env:APPDATA\npm"},
    @{Owner='Standalone Node candidate';Prefix='C:\Program Files\nodejs'},
    @{Owner='Standalone Node x86 candidate';Prefix='C:\Program Files (x86)\nodejs'}
)
$inventory=@(foreach($r in $roots) {
    [ordered]@{
        Owner=$r.Owner;Prefix=$r.Prefix;Exists=Test-Path -LiteralPath $r.Prefix
        Packages=@(Read-GlobalPackages (Join-Path $r.Prefix 'node_modules'))
        Shims=@(if(Test-Path -LiteralPath $r.Prefix){Get-ChildItem -LiteralPath $r.Prefix -File |
            Where-Object Extension -in @('.cmd','.ps1','.exe','') | Select-Object -ExpandProperty Name})
    }
})
$pnpmRoot=Join-Path $env:LOCALAPPDATA 'pnpm'
$pnpmManifests=@()
if(Test-Path -LiteralPath "$pnpmRoot\global"){
    $pnpmManifests=@(Get-ChildItem -LiteralPath "$pnpmRoot\global" -Filter package.json -Recurse -Depth 2 | ForEach-Object {
        $m=Get-Content -Raw -LiteralPath $_.FullName | ConvertFrom-Json
        [ordered]@{File=$_.FullName;Dependencies=$m.dependencies}
    })
}
$result=[ordered]@{
    TimeUtc=[DateTime]::UtcNow.ToString('o')
    GlobalPackages=$inventory
    PnpmGlobalManifests=$pnpmManifests
    PnpmShims=@(if(Test-Path -LiteralPath $pnpmRoot){Get-ChildItem -LiteralPath $pnpmRoot -File | Select-Object -ExpandProperty Name})
    CorepackDirectories=@(foreach($p in @("$env:LOCALAPPDATA\Programs\corepack\shims","$env:USERPROFILE\scoop\shims")){
        [ordered]@{Path=$p;Exists=Test-Path -LiteralPath $p;Names=@(if(Test-Path -LiteralPath $p){Get-ChildItem -LiteralPath $p -File | Select-Object -ExpandProperty Name})}
    })
    NvmEnvironment=@(foreach($scope in 'User','Machine'){
        [ordered]@{Scope=$scope;NVM_HOME=[Environment]::GetEnvironmentVariable('NVM_HOME',$scope);NVM_SYMLINK=[Environment]::GetEnvironmentVariable('NVM_SYMLINK',$scope)}
    })
    Resolution=@(Get-Command node,npm,pnpm,nvm,corepack,codex,copilot,gh,vercel,vc,clasp,gemini,turbo -All -ErrorAction SilentlyContinue | Select-Object Name,Source)
    Note='Presence is not proof of use. No shell history, credentials, sessions, or caches were exported.'
}
$json=$result | ConvertTo-Json -Depth 12
if($OutputFile){
    if(Test-Path -LiteralPath $OutputFile){throw 'Refusing to overwrite an existing inventory.'}
    [IO.File]::WriteAllText($OutputFile,$json)
} else {$json}
