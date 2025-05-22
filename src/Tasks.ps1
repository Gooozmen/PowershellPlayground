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


# DOTNET .SLN TASKS (BUILD, TEST, CLEAN)
task Build -depends NugetRestore{
    Build-solution -SolutionPath $SolutionPath -Configuration $configuration
}

task Clean{
    Clean-solution -SolutionPath $SolutionPath
}

task NugetRestore{
    Restore-solution -SolutionPath $SolutionPath
}

task Execute-DotnetTests -depends Build{
    Invoke-DotnetTests -TestDllPath $TestDllPath -ResultsDirectory $TestsLogOutput
}

task Execute-TestsNoBuild{
    Invoke-DotnetTests -TestDllPath $TestDllPath -ResultsDirectory $TestsLogOutput
}

# AWS TASKS (UPLOAD, DELETE)
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

# TASKS FOR DOCKER (BUILD, PUSH, COMPOSE)
task Build-DockerContainer {
    Build-ContainerImage -ContainerServiceName $ContainerServiceName -DockerFilePath $DockerFilePath -ImageVersion $ImageVersion -Username $Username 
}

task Push-DockerImage -depends Build-DockerContainer{
    Docker-Login -Username $Username -Token $Token
    Push-ContainerImage -Username $Username -ContainerServiceName $ContainerServiceName -ImageVersion $ImageVersion
}

task Start-DockerContainer{
    Run-DockerCompose -EnvFile $EnvFile -DockerComposePath $DockerComposePath
}