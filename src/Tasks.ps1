$functions = Resolve-Path "$PSScriptRoot\Functions.ps1"
. $functions

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