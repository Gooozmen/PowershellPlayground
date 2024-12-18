function Nuget-Install{
    choco install nuget.commandline -y
}

function Chocolatey-Install{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

function Install-Dependencies{
    nuget install psake -Source "nuget.org" -OutputDirectory ..\Dependencies
}

function Clean-Folders([string[]]$PathsArray){
    foreach ($_ in $PathsArray) {
        $AbsolutePath = Resolve-Path "$_"
        if(Test-Path $AbsolutePath){
            Write-Host "Removing items in $AbsolutePath"
            Remove-Item -Recurse "$_\**"
        }
        else{
            Write-Host "$AbsolutePath Contains doesnt contain items"
        }
    }
}

function Import-PsakeModule {
    # Resolve the psake module path and import it
    try {
        $modulePath = Resolve-Path "..\Dependencies\psake*\tools\psake\psake.psm1"
        Import-Module $modulePath -Force -ErrorAction Stop
        Write-Host "Psake Module Imported Successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to import Psake module. Error: $_" -ForegroundColor Red
    }
}

function Verify-PsakeImport {
    # Check if psake is imported into the session
    if (Get-Module -Name psake) {
        Write-Host "The 'psake' module is currently imported in the session." -ForegroundColor Green
    }
    # Check if psake is available but not imported
    elseif (Get-Module -ListAvailable -Name psake) {
        Write-Host "The 'psake' module is available on the system but not yet imported." -ForegroundColor Yellow
    }
    else {
        Write-Host "The 'psake' module is NOT available on the system." -ForegroundColor Red
    }
}

# Chocolatey-Install
# Nuget-Install
# Clean-Folders -PathsArray @("..\Dependencies","..\Artifacts")
Install-Dependencies
Import-PsakeModule
Verify-PsakeImport

# dotnet nuget add source --username OWNER --password YOUR_GITHUB_PAT --store-password-in-clear-text --name github "https://nuget.pkg.github.com/Gooozmen/index.json"
# dotnet nuget push "build\PROJECT_NAME.1.0.0.nupkg" --api-key YOUR_GITHUB_PAT --source "github"