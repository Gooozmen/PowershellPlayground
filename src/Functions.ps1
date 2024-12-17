".\Notifications.ps1"

function Clean-Solution {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath
    )

    Write-Host "Cleaning solution: $SolutionPath" -ForegroundColor Cyan
    dotnet clean $SolutionPath
    if ($LASTEXITCODE -ne 0) {
        ShowError -message "Failed to clean the solution: $SolutionPath"
                  -icon $icon
                  -title $title
        exit 1
    }
    Write-Host "Clean succeeded!" -ForegroundColor Green
}

function Restore-Solution {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath
    )

    Write-Host "Restoring NuGet packages for: $SolutionPath" -ForegroundColor Cyan
    dotnet restore $SolutionPath
    if ($LASTEXITCODE -ne 0) {
        ShowError -message "Failed to restore NuGet packages for: $SolutionPath"
                  -icon $icon
                  -title $title
        exit 1
    }
    Write-Host "Restore succeeded!" -ForegroundColor Green
}

function Build-Solution {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath,
        [string]$Configuration = "Release"
    )

    Write-Host "Building solution: $SolutionPath with Configuration: $Configuration" -ForegroundColor Cyan
    dotnet build $SolutionPath --configuration $Configuration --no-restore
    if ($LASTEXITCODE -ne 0) {
        ShowError -message "Failed to build the solution: $SolutionPath"
                  -icon $icon
                  -title $title
        exit 1
    }
    Write-Host "Build succeeded!" -ForegroundColor Green
}

function Publish-Solution {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath,
        [string]$OutputPath,
        [string]$Configuration = "Release"
    )

    Write-Host "Publishing solution: $SolutionPath to Output Path: $OutputPath" -ForegroundColor Cyan
    dotnet publish $SolutionPath --configuration $Configuration --output $OutputPath --no-restore
    if ($LASTEXITCODE -ne 0) {
        ShowError "Failed to publish the solution: $SolutionPath"
                  -icon $icon
                  -title $title
        exit 1
    }
    Write-Host "Publish succeeded! Artifacts available at: $OutputPath" -ForegroundColor Green
}


