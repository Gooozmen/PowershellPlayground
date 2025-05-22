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
    docker-compose --env-file $EnvFile up -d --remove-orphans --force-recreate

    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        Set-CustomLocation($currentLocation)
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
    write-host "Username------------- $usernameNormalized"

    $latest = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , "latest")
    Log-Info -Target $currentTarget -Message "Building image with tag: $latest"
    $versioned = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , $ImageVersion)
    Log-Info -Target $currentTarget -Message "Building image with tag: $versioned"
    docker build -t $latest .
    Tag-ContainerImage -latestImageTag $latest -versionedImageTag $versioned

    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
        Set-CustomLocation($currentLocation)
    }
}

function Tag-ContainerImage
(
    [string] $latestImageTag ,
    [string] $versionedImageTag
)
{
    docker tag $latestImageTag $versionedImageTag
}

function Push-ContainerImage([string] $Username,[string] $ContainerServiceName ,[string] $ImageVersion)
{
    $usernameNormalized = $Username.ToLower()
    $latestImageCmd = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , "latest")
    Publish-Image($latestImageCmd)
    $versionedImageCmd = [string]::Format("ghcr.io/{0}/{1}:{2}", $usernameNormalized, $ContainerServiceName , $ImageVersion)
    Publish-Image($versionedImageCmd)
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

