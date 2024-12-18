.".\version.ps1"
."..\src\Functions.ps1"

$currentDir = get-location
$ErrorActionPreference = 'Stop'
$Title = "ToolKit"
$target = " "
$icon = "$currentDir\..\res\AppIcon.ico" 

task CreateNugetPackage{
    Create-NugetPackage -Output "..\Artifacts" -Version $version
}


dotnet nuget push "..\Artifacts\Toolkit.1.0.0.nupkg" --api-key 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 --source "github"
dotnet nuget add source --username Gooozmen --password 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 --store-password-in-clear-text --name github "https://nuget.pkg.github.com/Gooozmen/index.json"