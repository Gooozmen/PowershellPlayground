$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

function Build-Container([string] $Identifier,[string] $DockerFilePath)
{
    $currentTarget = "build container"
    docker build -t $Identifier -f $DockerFilePath .
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Start-Container([string] $EnvFile,[string] $Identifier,[int]$Port)
{
    $currentTarget = "start container"
    docker run -p "${Port}:${Port}" --env-file $EnvFile $Identifier
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Push-ContainerImage([string] $Username,[string] $Identifier,[string] $ImageVersion)
{
    $currentTarget = "push container"
    docker push ghcr.io/$Username/"{$Identifier}:{$ImageVersion}"
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Tag-ContatinerImage([string] $Username,[string] $Identifier,[string] $ImageVersion)
{
    $currentTarget = "tag container"
    $usernameNormalized = $Username.ToLower()
    docker tag poc ghcr.io/$usernameNormalized/"{$Identifier}:{$ImageVersion}"
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