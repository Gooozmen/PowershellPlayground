.".\version.ps1"
."..\src\Functions.ps1"

$currentDir = get-location
$ErrorActionPreference = 'Stop'
$Title = "dotnet.ToolKit"
$target = " "
$icon = "$currentDir\..\res\AppIcon.ico" 

task CreateNugetPackage{
    $target = "CreateNugetPackage"
    & nuget.exe pack Component.nuspec /OutputDirectory ..\Artifacts -Properties "version=$version" -Force
    if($LASTEXITCODE -eq 1){
        Write-Verbose "Encountered problems while runnning task: $target"
        ShowError -message "$target finished with errors." -icon $icon -title $title 
    }
}
