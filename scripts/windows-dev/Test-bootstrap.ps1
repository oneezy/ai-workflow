#requires -Version 7.4
$ErrorActionPreference='Stop'
$bootstrap=Join-Path $PSScriptRoot 'bootstrap.ps1'
$syntaxTokens=$null; $syntaxErrors=$null
$null=[Management.Automation.Language.Parser]::ParseFile($bootstrap,[ref]$syntaxTokens,[ref]$syntaxErrors)
if($syntaxErrors.Count){throw ($syntaxErrors | Out-String)}
. $bootstrap -LibraryOnly
$testDir=Join-Path ([IO.Path]::GetTempPath()) ('windows-dev-tests-'+[guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($testDir) | Out-Null
$script:passed=0
function Assert([bool]$Condition,[string]$Message){
    if(-not $Condition){throw "FAIL: $Message"}; $script:passed++
}
function Must-Fail([scriptblock]$Action,[string]$Pattern){
    $caught=$false
    try { & $Action | Out-Null } catch {if($_.Exception.Message -notmatch $Pattern){throw};$caught=$true}
    Assert $caught "Expected refusal: $Pattern"
}
$baseline=Get-ProtectedState
Assert ((Get-DeduplicatedPath @('C:\Tools','c:\tools\','','C:\Other')) -eq 'C:\Tools;C:\Other') 'Deduplicate case/trailing separators'
Must-Fail {Assert-LocalRoot '\\server\share\toolchain'} 'absolute local'
Must-Fail {Assert-LocalRoot 'C:\'} 'dedicated'
Must-Fail {Assert-LocalRoot 'C:\bad;path'} 'absolute local'
$versions=Read-Versions (Join-Path $PSScriptRoot 'versions.json')
foreach($artifact in $versions.artifacts){Assert-Artifact $artifact $versions}
$bad=$versions.artifacts[0] | ConvertTo-Json | ConvertFrom-Json
$bad.Url='https://example.com/vp.tgz'
Must-Fail {Assert-Artifact $bad $versions} 'Invalid Vite'
$sample=Join-Path $testDir 'sample'
[IO.File]::WriteAllText($sample,'fixture')
Assert (Test-ArtifactHash $sample ('sha256:'+(Get-Sha256 $sample))) 'Valid digest'
Assert (-not (Test-ArtifactHash $sample ('sha256:'+('0'*64)))) 'Corrupt digest rejected'
$envMap=Get-ChildEnvironment "$testDir\release" $versions
Assert (-not $envMap.ContainsKey('CODEX_ACCESS_TOKEN')) 'No credential inheritance'
Assert ($envMap.VP_SELF_SETUP_NO_MODIFY_PATH -eq '1') 'Vite cannot alter profiles'
Assert ($envMap.PATH -notmatch 'nvm4w') 'Install does not resolve NVM Node'

# Real archive validation using .NET, including traversal and link fixtures.
function Make-TarFixture([string]$File,[string]$Name,[System.Formats.Tar.TarEntryType]$Type){
    $f=[IO.File]::Create($File)
    $g=[IO.Compression.GZipStream]::new($f,[IO.Compression.CompressionMode]::Compress)
    $w=[System.Formats.Tar.TarWriter]::new($g)
    try {
        $e=[System.Formats.Tar.PaxTarEntry]::new($Type,$Name)
        if($Type -eq [System.Formats.Tar.TarEntryType]::SymbolicLink){$e.LinkName='../outside'}
        $w.WriteEntry($e)
    } finally {$w.Dispose();$g.Dispose();$f.Dispose()}
}
Make-TarFixture "$testDir\good.tgz" 'package/file.txt' RegularFile
Expand-CheckedTar "$testDir\good.tgz" "$testDir\good"
Assert (Test-Path "$testDir\good\package\file.txt") 'Safe archive extracts'
Make-TarFixture "$testDir\bad.tgz" '../outside' RegularFile
Must-Fail {Expand-CheckedTar "$testDir\bad.tgz" "$testDir\bad"} 'Unsafe archive'
Make-TarFixture "$testDir\link.tgz" 'package/link' SymbolicLink
Must-Fail {Expand-CheckedTar "$testDir\link.tgz" "$testDir\link"} 'Unsafe archive'

# Mock every network/process/extraction boundary for install flow tests.
$script:networkCalls=0; $script:childCalls=0
function Invoke-WebRequest {param($Uri,$OutFile,$TimeoutSec)
    $script:networkCalls++; [IO.File]::WriteAllText($OutFile,'mock archive')
}
function Test-ArtifactHash {param($File,$Integrity) return $true}
function Expand-CheckedTar {param($Archive,$Destination)
    if($Destination.EndsWith('vp-payload')){
        [IO.Directory]::CreateDirectory("$Destination\package") | Out-Null
        [IO.File]::WriteAllText("$Destination\package\vp.exe",'mock')
    } else {
        [IO.Directory]::CreateDirectory("$Destination\bin") | Out-Null
        [IO.File]::WriteAllText("$Destination\bin\codex.exe",'mock')
    }
}
function Invoke-Child {param($Exe,$Arguments,$Environment,$Directory,$TimeoutSeconds)
    $script:childCalls++
    if($Exe -like '*vp-payload*'){
        [IO.Directory]::CreateDirectory("$Directory\vite-plus\bin") | Out-Null
        [IO.Directory]::CreateDirectory("$Directory\vite-plus\current\bin") | Out-Null
        foreach($name in 'vp','node','npm','pnpm'){
            [IO.File]::WriteAllText("$Directory\vite-plus\bin\$name.exe",'mock')
        }
        [IO.File]::WriteAllText("$Directory\vite-plus\current\bin\vp.exe",'mock')
        [IO.File]::WriteAllText("$Directory\vite-plus\current\bin\vp-shim.exe",'mock')
        return 'vp v0.3.2'
    }
    if($Arguments[0] -eq '--version'){
        switch(Split-Path $Exe -Leaf){
            'vp.exe' {return 'vp v0.3.2'}
            'node.exe' {return 'v24.21.0'}
            'pnpm.exe' {return '12.4.1'}
            'npm.exe' {return '11.19.0'}
            'codex.exe' {return 'codex-cli 0.154.0'}
        }
    }
    return ''
}
$Manifest=Join-Path $PSScriptRoot 'versions.json'
$Root=Join-Path $testDir 'managed'
$PlanFile=Join-Path $testDir 'plan.json'
$Mode='Audit'; $Apply=$false
Invoke-Bootstrap | Out-Null
Assert ($script:networkCalls -eq 0 -and $script:childCalls -eq 0) 'Audit has no network or process calls'
$Mode='Install'
Invoke-Bootstrap | Out-Null
Assert (-not (Test-Path $Root)) 'Dry run creates no installation directory'
$Mode='Plan'
Invoke-Bootstrap | Out-Null
$ApprovedPlanSha256=Get-Sha256 $PlanFile
Must-Fail {Invoke-Bootstrap} 'already exists'
$Mode='Install'; $Apply=$true
$approved=$ApprovedPlanSha256
$ApprovedPlanSha256='0'*64
Must-Fail {Invoke-Bootstrap} 'reviewed plan'
$ApprovedPlanSha256=$approved
Invoke-Bootstrap | Out-Null
$release=Join-Path $Root (Get-ReleaseId $versions)
Assert (Test-Path "$release\receipt.json") 'Successful install creates receipt'
Assert ($script:networkCalls -eq 2) 'Downloads exactly the two approved payloads'
$beforeRepeat=$script:networkCalls
Invoke-Bootstrap | Out-Null
Assert ($script:networkCalls -eq $beforeRepeat) 'Repeat install does not download or replace packages'
[IO.File]::WriteAllText("$release\codex\bin\codex.exe",'local edit')
Must-Fail {Invoke-Bootstrap} 'Local change'
Assert-SameState $baseline (Get-ProtectedState)
$script:passed++
# Stale plan must fail before downloads or directories.
$Root=Join-Path $testDir 'stale-managed';$PlanFile=Join-Path $testDir 'stale-plan.json'
$Apply=$false;$Mode='Plan';Invoke-Bootstrap | Out-Null
$p=Get-Content -Raw $PlanFile | ConvertFrom-Json
$p.Before.UserPath='changed fixture'
[IO.File]::WriteAllText($PlanFile,($p | ConvertTo-Json -Depth 20))
$ApprovedPlanSha256=Get-Sha256 $PlanFile
$Mode='Install';$Apply=$true
Must-Fail {Invoke-Bootstrap} 'changed since planning'
Assert (-not (Test-Path $Root)) 'Stale plan does not create target'
# Failed integrity must not execute payloads; partial state must block retries.
$Root=Join-Path $testDir 'bad-hash-managed';$PlanFile=Join-Path $testDir 'bad-hash-plan.json'
$Apply=$false;$Mode='Plan';Invoke-Bootstrap | Out-Null
$ApprovedPlanSha256=Get-Sha256 $PlanFile
$priorChildCalls=$script:childCalls
function Test-ArtifactHash {param($File,$Integrity) return $false}
$Mode='Install';$Apply=$true
Must-Fail {Invoke-Bootstrap} 'integrity mismatch'
Assert ($script:childCalls -eq $priorChildCalls) 'Bad digest never executes payload'
$failedRelease=Join-Path $Root (Get-ReleaseId $versions)
Assert (-not (Test-Path "$failedRelease\receipt.json")) 'Failure creates no successful receipt'
Must-Fail {Invoke-Bootstrap} 'without a successful receipt'
Assert-SameState $baseline (Get-ProtectedState)
$script:passed++
Write-Host "$script:passed checks passed. Mock files retained at $testDir"
