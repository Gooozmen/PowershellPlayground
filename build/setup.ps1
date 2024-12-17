function NugetCommandLineInstall{
    choco install nuget.commandline -y
}

function ChocolateyInstall{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

ChocolateyInstall
NugetCommandLineInstall
# & nuget install psake -Source "https://api.nuget.org/v3/index.json" -Version 4.9.0 -OutputDirectory ..\Dependencies
nuget install psake -Source "https://api.nuget.org/v3/index.json" -OutputDirectory ..\Dependencies

