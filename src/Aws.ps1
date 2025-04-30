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