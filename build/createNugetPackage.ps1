$current = get-location .
Write-Host "Currect Location $current"
$psakeFilePath = Resolve-Path ".\psakefile.ps1"
& (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.ps1") $psakeFilePath CreateNugetPackage