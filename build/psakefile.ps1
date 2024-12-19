Include ".\version.ps1"
Include "..\src\Tools.ps1"

$currentDir = get-location
$ErrorActionPreference = 'Stop'
$Title = "ToolKit"
$target = " "
$icon = "$currentDir\..\res\AppIcon.ico" 


task CreateNugetPackage{
    Create-NugetPackage -Output "..\Artifacts" -Version $version
}

task PushNugetPackage{
    Push-NugetPackage -PackagePath "..\Artifacts\*.nupkg"
}

task CreateAndPushPackage -depends CreateNugetPackage,PushNugetPackage{
    
}