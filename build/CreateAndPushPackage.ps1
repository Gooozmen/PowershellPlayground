param ([string]$buildVersion = "0")
$VersionInput ="1.0.0.$buildVersion"
$psakeFilePath = Resolve-Path ".\psakefile.ps1"
& (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.ps1") -parameters @{"version"=$VersionInput} $psakeFilePath CreateAndPushPackage