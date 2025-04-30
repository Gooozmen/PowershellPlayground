$solution = Resolve-Path "$PSScriptRoot\Solution.ps1"
$aws = Resolve-Path "$PSScriptRoot\Aws.ps1"
$testing = Resolve-Path "$PSScriptRoot\Testing.ps1"
$zip = Resolve-Path "$PSScriptRoot\Zip.ps1"
$nuget = Resolve-Path "$PSScriptRoot\Nuget.ps1"
$docker = Resolve-Path "$PSScriptRoot\Docker.ps1"

. $aws
. $solution
. $testing
. $zip
. $nuget
. $docker

task Build -depends NugetRestore{
    Build-solution -SolutionPath $SolutionPath -Configuration $configuration
}

task Clean{
    Clean-solution -SolutionPath $SolutionPath
}

task NugetRestore{
    Restore-solution -SolutionPath $SolutionPath
}

task S3-PostFile -depends S3-DeleteFile{
    S3-FileUpload -BucketName $BucketName  -FilePath $ProjectArtifact -S3Key $S3Key -Region $Region -AccessKey $AccessKey -SecretKey $SecretKey
}

task S3-DeleteFile{
    Delete-S3File -BucketName $BucketName -FileKey $FileKey -Region $Region -ProfileName $ProfileName
}

task Publish-Solution{
    Upload-Solution -SolutionPath $SolutionPath -OutputPath $OutputPath -Configuration $Configuration
    Zip-Folder -SourceFolder $SourceFolder -OutputFolder $DestinationFolder
}

task Execute-DotnetTests -depends Build{
    Invoke-DotnetTests -TestDllPath $TestDllPath -ResultsDirectory $TestsLogOutput
}

task Execute-TestsNoBuild{
    Invoke-DotnetTests -TestDllPath $TestDllPath -ResultsDirectory $TestsLogOutput
}

task Build-DockerContainer {
    Build-Container($Identifier)
}

task Start-DockerContainer{s
    Start-Container($EnvFile,$Identifier,$Port)
}

task Push-DockerImage -depends Build-DockerContainer{
    
    Docker-Login($Username, $Token)
    Tag-ContatinerImage($Username,$Identifier,$ImageVersion)
    Push-ContainerImage($Username,$Identifier,$ImageVersion)
}