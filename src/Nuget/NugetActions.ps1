function GetMsbuildLocation{
    $path = "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
}
# ChocolateyInstall
NugetCommandLineInstall

function RestoreNugetPackages {
    param(
        [string]$solutionPath
    )
    nuget restore $solutionPath -Source "https://api.nuget.org/v3/index.json" -Verbosity detailed
}

function ClearNugetCache{
    nuget locals all -clear
}

