$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

#solution
function Clean-Solution([string]$SolutionPath)
{
    $currentTarget = "Clean-Solution"
    Log-Info -Target $currentTarget -Message "Cleaning solution: $SolutionPath"
    dotnet clean $SolutionPath
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
    
}

function Restore-Solution([string]$SolutionPath)
{
    $currentTarget = "Restore-Solution"
    Log-Info -Target $currentTarget -Message "Restoring NuGet packages for: $SolutionPath"
    dotnet restore $SolutionPath
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Build-Solution([string]$SolutionPath,[string]$Configuration = "Release")
{
    $currentTarget = "Build-Solution"
    Log-Info -Target $currentTarget -Message "Building solution: $SolutionPath with Configuration: $Configuration"
    dotnet build $SolutionPath --configuration $Configuration --no-restore
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Upload-Solution([string]$SolutionPath,[string]$OutputPath,[string]$Configuration = "Release")
{
    $currentTarget = "Publish-Solution"
    dotnet publish $SolutionPath -c $Configuration -o $OutputPath
    Log-Info -Target $currentTarget -Message "Publishing solution: $SolutionPath to Output Path: $OutputPath"
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

#zip
function Zip-Folder([string]$SourceFolder,[string]$OutputFolder){
    $7zip = "7z.exe"
    $currentTarget = "Zip Folder"
    Write-Host "Source: $SourceFolder"
    Write-Host "Destination: $OutputFolder"

    & "$7zip" a -tzip $OutputFolder "$SourceFolder\*"

    if (Test-Path $OutputFolder) {
        Log-Info -Target $currentTarget -Message "ZIP file created successfully: $OutputFolder"
    } 
    else {
        Log-Error -Target $currentTarget 
    }
}

#Package
function Create-NugetPackage([string]$Output,[string]$Version){
    $target = "CreateNugetPackage"
    $AbsoluteOutput = Resolve-Path $Output
    & nuget.exe pack Component.nuspec /OutputDirectory $AbsoluteOutput -Properties "version=$Version" -Force
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
    }
}

function Push-NuGetPackage([string]$PackagePath)
{
    $currentTarget = "Push-NuGetPackage"
    $AbsolutePackagePath = Resolve-Path $PackagePath
    
    # Push the package
    try {
        Log-Info -Target $currentTarget -Message "Pushing package to GitHub repository..."
        & nuget push $PackagePath -Source "github"

        if ($LASTEXITCODE -ne 0) {
            Log-Error -Target $currentTarget
            exit 1
        }
    }
    catch {
        Log-Error -Target $currentTarget

    }
}  

#Xunit
function Invoke-DotnetTests([string]$TestDllPath,
                            [string]$ResultsDirectory)
{
    $currentTarget = "Invoke DotnetTests"
    $OutputDirectory =  Resolve-Path "..\Artifacts"
    try {
        $command = "$BaseCommand $TestDllPath --logger 'trx;LogFileName=TestResults.trx' --results-directory $ResultsDirectory"

        Log-Info -Target $currentTarget -Message "Running xUnit tests for $TestDllPath..."
        Log-Info -Target $currentTarget -Message "Command: $command "
        
        & dotnet test $TestDllPath --logger 'trx;LogFileName=TestResults.trx' --results-directory $ResultsDirectory
        Get-TestResults

        if ($LASTEXITCODE -ne 0) {
            Log-Error -Target $currentTarget -Message "Tests failed. Check the results in $ResultsDirectory"
            Exit 1
        }
        
        
    } catch {
        Log-Error -Target $currentTarget -Message "An error occurred while running xUnit tests: $_"
        Exit 1
    }
}

function Get-TestResults
{
    $currentTarget = "Get-TestResults"
    Log-Info -Target $currentTarget -Message "Running File Verification for TestResults.trx"
    if(Resolve-Path ("..\Artifacts\TestResults.trx")){
        Log-Success -Target $currentTarget -Message "Test result is present at Artifacts folder"
    }
    Log-Error -Target $currentTarget -Message "File is not present at Destination Folder"
}


#AWS
function S3-FileUpload([string]$BucketName,[string]$FilePath,[string]$S3Key,[string]$Region,[string]$AccessKey,[string]$SecretKey)
{
    $currentTarget = "Aws-S3 Upload"
    try {
        Import-Module AWS.Tools.S3

        Initialize-AWSDefaultConfiguration -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region

        if (-not (Test-Path -Path $FilePath)) {
            Write-Error "$FilePath does not exists"
            exit 1
        }

        Write-Host "Starting to upload file to $BucketName"
        Write-S3Object -BucketName $BucketName -File $FilePath -Key $S3Key
        Write-Host "Upload file to $BucketName completed"

    }
    catch {
        Write-Error $_
    }
}

function Delete-S3File([string]$BucketName,[string]$FileKey,[string]$Region,[string]$ProfileName = $null)
{
    $currentTarget = "Delete-S3File"
    try {
        # Initialize AWS credentials and region
        if ($ProfileName) {
            Initialize-AWSDefaultConfiguration -Region $Region -ProfileName $ProfileName
        } else {
            Initialize-AWSDefaultConfiguration -Region $Region
        }
        Remove-S3Object -BucketName $BucketName -Key $FileKey -Force
        Log-Info -Target $currentTarget -Message "File '$FileKey' successfully deleted from bucket '$BucketName'."
    }
    catch {
        Log-Error -Target $currentTarget -Message "An error occurred while deleting the file: $_"
    }
}