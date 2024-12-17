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

function Import-Psake-Module{
    Import-Module ( "..\Dependencies\psake*\tools\psake\psake.psm1") -force
    Write-Output "Psake Module Imported"

}

function Clean-Folders{
    $folderPath = "..\Dependencies\"

    # Check recursively
    if (Get-ChildItem -Path $folderPath -Recurse -ErrorAction SilentlyContinue) {
        # Remove only subfolders, not files
        Get-ChildItem -Path $folderPath -Directory | Remove-Item -Recurse -Force
    } else {
        Write-Output "The folder is empty."
    }
}

Chocolatey-Install
Nuget-Install
Clean-Folders
Install-Dependencies
Import-Psake-Module

