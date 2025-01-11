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
            $ItemsQuantity = (Get-ChildItem -Path $ItemsQuantity -Directory).Count
            if($ItemsQuantity -gt 0){
                Write-Host "Removing items in $AbsolutePath"
                Remove-Item -Recurse "$_\**"
            }
            else{
                Write-Host "No existing directories in $AbsolutePath"
            }
        }
        else{
            Write-Host "$_ doesnt exist"
        }
    }
}

function Import-PsakeModule {
    # Resolve the psake module path and import it
    $modulePath = Resolve-Path "..\Dependencies\psake*\tools\psake\psake.psm1"
    Import-Module $modulePath -Force -ErrorAction Stop
    Verify-PsakeImport
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

function Invoke-PsakeSession{
    & (Resolve-Path "..\Dependencies\psake*\tools\psake\psake.ps1") .\psakefile.ps1 CreateNugetPackage
}

function Add-PackageSource([string] $Command){
    $Username = $env:NUGET_USERNAME
    $Password = $env:NUGET_PASSWORD

    if (-not $Username -or -not $Password) {
        Write-Error "Environment variables NUGET_USERNAME or NUGET_PASSWORD are not set."
        return
    }

    nuget sources $Command -Name "github" -Source "https://nuget.pkg.github.com/Gooozmen/index.json" -username $Username -password $Password
}

function Verify-PackageSource{
    $sources = nuget sources list
    if($sources -like "*https://nuget.pkg.github.com/Gooozmen/index.json*"){
        Add-PackageSource -Command "update"
        Write-Host "Github source was updated"
    }
    else{
        Add-PackageSource -Command "add"
        Write-Host "Github source was added"
    }
}

# Clean-Folders -PathsArray @("..\Dependencies")
Install-Dependencies
Verify-PackageSource
Import-PsakeModule