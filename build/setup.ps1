function NugetCommandLineInstall{
    choco install nuget.commandline -y
}

function ChocolateyInstall{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

function InstallDependencies{
    nuget install psake -Source "nuget.org" -OutputDirectory ..\Dependencies
}

function ImportPsake{
    Import-Module (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.psm1") -force
    Write-Output "Psake Module Imported"
}

function CleanFolders{
    $folderPath = "..\Dependencies\"

    # Check recursively
    if (Get-ChildItem -Path $folderPath -Recurse -ErrorAction SilentlyContinue) {
        # Remove only subfolders, not files
        Get-ChildItem -Path $folderPath -Directory | Remove-Item -Recurse -Force
    } else {
        Write-Output "The folder is empty."
    }
}

ChocolateyInstall
NugetCommandLineInstall
CleanFolders
InstallDependencies
ImportPsake

