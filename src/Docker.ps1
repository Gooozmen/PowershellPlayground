$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

function Run-DockerCompose
(
    [string] $EnvFile,
    [string] $DockerComposePath
)
{
    $currentLocation = Get-Location
    $currentTarget = "docker compose up"
    Set-CustomLocation($DockerComposePath)
    Pull-Image
    docker-compose --env-file $EnvFile up -d --remove-orphans --force-recreate

    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
        Set-CustomLocation($currentLocation)
    }
}

function Build-ContainerImage
(
    [string] $ContainerServiceName,
    [string] $ImageVersion,
    [string] $DockerFilePath,
    [string] $Username
)
{
    $currentLocation = Get-Location
    $currentTarget = "build container image"
    Set-CustomLocation($DockerFilePath)
    $usernameNormalized = $Username.ToLower()
    $cmd = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , $ImageVersion)
    docker build -t $cmd .
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
        Set-CustomLocation($currentLocation)
    }
}

function Push-ContainerImage([string] $Username,[string] $ContainerServiceName ,[string] $ImageVersion)
{
    $usernameNormalized = $Username.ToLower()
    $versionedImageCmd = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , $ImageVersion)
    $latestImageCmd = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , "latest")
    Publish-Image($versionedImageCmd)
    Publish-Image($latestImageCmd)
}

function Publish-Image([string] $Command)
{
    $currentTarget = "publish container image"
    docker push $Command
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Get-ContainerImage
{
    $currentTarget = "pull container image"
    docker-compose pull
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}



function Docker-Login([string] $Username,[string] $Token)
{
    $currentTarget = "Docker Login"
    $Token | docker login ghcr.io -u $Username --password-stdin
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    } 
    else{
        Log-Success -Target $currentTarget
    }
}

#TODO: Move generic function to a functions file
function Set-CustomLocation([string] $Path)
{
    Log-Info("Set Custom Location","Applying Working Directory To: $Path")
    Set-Location $Path
}