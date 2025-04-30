$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

#Package
function Create-NugetPackage([string]$Output,[string]$Version){
    $target = "CreateNugetPackage"
    $AbsoluteOutput = Resolve-Path $Output
    & nuget.exe pack Component.nuspec /OutputDirectory $AbsoluteOutput -Properties "version=$Version" -Force
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Push-NuGetPackage([string]$PackagePath)
{
    $currentTarget = "Push-NuGetPackage"
    $AbsolutePackagePath = Resolve-Path $PackagePath
    
    # Push the package
    try {
        Log-Info -Target $currentTarget -Message "Pushing package to GitHub repository..."
        & nuget push $PackagePath -Source "github"

        if ($LASTEXITCODE -ne 0) {
            Log-Error -Target $currentTarget
            exit 1
        }
    }
    catch {
        Log-Error -Target $currentTarget

    }
}  
