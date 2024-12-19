Include "..\src\Tools.ps1"

$currentDir = get-location
$ErrorActionPreference = 'Stop'
$Title = "ToolKit"
$target = "Psakefile"
$icon = "$currentDir\..\res\AppIcon.ico" 
$version = "1.0.0"


task CreateNugetPackage{
    Log-Info -Target $target -Message "Package Version: $version"
    Create-NugetPackage -Output "..\Artifacts" -Version $version
}

task PushNugetPackage{
    Push-NugetPackage -PackagePath "..\Artifacts\*.nupkg"
}

task CreateAndPushPackage -depends CreateNugetPackage,PushNugetPackage{
    
}