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

function Import-PsakeModule{
    Import-Module (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.psm1") -force
    Write-Output "Psake Module Imported"
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

# Chocolatey-Install
# Nuget-Install
# Clean-Folders -PathsArray @("..\Dependencies","..\Artifacts")
Install-Dependencies
Import-PsakeModule

# dotnet nuget add source --username OWNER --password YOUR_GITHUB_PAT --store-password-in-clear-text --name github "https://nuget.pkg.github.com/Gooozmen/index.json"
# dotnet nuget push "build\PROJECT_NAME.1.0.0.nupkg" --api-key YOUR_GITHUB_PAT --source "github"