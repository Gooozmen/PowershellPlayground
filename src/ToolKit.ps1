function BuildSolution {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SolutionPath,        # Path to the .sln file
        [string]$Configuration = "Release", # Build configuration (default is Release)
        [string]$Platform = "Any CPU"       # Platform to build (default is Any CPU)
    )

    # Locate MSBuild
    $currentDir = Get-location
    $msbuildPath = GoToMsbuildLocation
    Write-Host "msbuild location: $msbuildPath"

    # Ensure the solution path exists
    if (-not (Test-Path $SolutionPath)) {
        Write-Error "Solution file not found at: $SolutionPath"
        return
    }

    # Build command
    $buildCommand =
    Write-Host "Building solution..." -ForegroundColor Cyan
    Write-Host $buildCommand -ForegroundColor Yellow

    # Execute the build
    $result = Invoke-Expression $buildCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build succeeded!" -ForegroundColor Green
    } else {
        Write-Error "Build failed. Check the output for details."
    }
}
function GoToMsbuildLocation{
    $path = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    return $path
}

BuildSolution -SolutionPath "C:\Git\Playground\src\Playground.sln"

