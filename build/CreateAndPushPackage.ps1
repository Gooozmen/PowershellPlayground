param ([string]$buildVersion = "0")
$VersionInput ="1.0.0.$buildVersion"
$environment = ""
if($environment -eq "local"){$psakeFilePath = Resolve-Path ".\psakefile.ps1"}
else{$psakeFilePath = Resolve-Path ".\Build\psakefile.ps1"}
& (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.ps1") -parameters @{"version"=$VersionInput} $psakeFilePath CreateAndPushPackage