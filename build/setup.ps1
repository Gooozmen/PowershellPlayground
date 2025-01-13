function Install-NugetCli{
    choco install nuget.commandline -y
}
function Install-ChocolateyCli{
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
function Install-PsakeFramework{
    nuget install psake -Source "nuget.org" -OutputDirectory ..\Dependencies
}
function Install-PackageManagment{
    Install-Module -Name PackageManagement -Force -Scope CurrentUser
    Import-Module PackageManagement -Force
}
function Ensure-ModuleInstalled ([string]$ModuleName){
    # Check if the module is already installed
    $moduleInstalled = Get-Module -Name $ModuleName -ListAvailable
    if ($moduleInstalled) {return $true} 
    else {return $false}
}
function Test-PathExistence ([string]$Path){
    if (Test-Path -Path $Path) { return $true }
    return $false
}
#Aws
function Install-AwsTools{
    if(Ensure-ModuleInstalled -ModuleName "AWS.Tools.Installer" -eq $false){
        Write-Host "Installing Aws Tools"
        Install-Module -Name AWS.Tools.Installer -Force -Scope CurrentUser -AllowClobber -Verbose
    }
    if(Ensure-ModuleInstalled -ModuleName "AWS.Tools.S3" -eq $false){
        Install-AwsS3
    }
}
function Install-AwsS3{
    Write-Host "Installing Aws S3"
    Install-AWSToolsModule -Name AWS.Tools.S3 -Force -Scope CurrentUser -Verbose
}

function Remove-FoldersContent([string[]]$PathsArray){
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
    Test-PsakeImport 
}

function Test-PsakeImport {
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
    Write-Output "Username $Username"
    Write-Output "PASS $Password"


    if (-not $Username -or -not $Password) {
        Write-Error "Environment variables NUGET_USERNAME or NUGET_PASSWORD are not set."
        return
    }

    nuget sources $Command -Name "github" -Source "https://nuget.pkg.github.com/Gooozmen/index.json" -username $Username -password $Password
}

function Set-PackageSource{
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
Install-PsakeFramework
Install-AwsTools
Set-PackageSource
Import-PsakeModule
