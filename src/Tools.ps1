task Build -depends NugetRestore{
    Build-solution -SolutionPath $SolutionPath -Configuration $configuration
}

task Clean{
    Clean-solution -SolutionPath $SolutionPath
}

task NugetRestore{
    Restore-solution -SolutionPath $SolutionPath
}

task S3-PostFile{
    S3-FileUpload -BucketName $BucketName  -FilePath $ProjectArtifact -S3Key $S3Key -Region $Region -AccessKey $AccessKey -SecretKey $SecretKey
}

task Publish-Solution{
    Upload-Solution -SolutionPath $SolutionPath -OutputPath $OutputPath -Configuration $Configuration
    Zip-Folder -SourceFolder $SourceFolder -OutputFolder $DestinationFolder
}

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



#notification banner
function Show-Notification([string]$message, [string]$level, [string]$icon, [string]$title)
{

    # Load required assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create the NotifyIcon object
    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $objNotifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Resolve-Path $icon))
    $objNotifyIcon.BalloonTipIcon = $level
    $objNotifyIcon.BalloonTipText = $message
    $objNotifyIcon.BalloonTipTitle = $title
    $objNotifyIcon.Visible = $true

    # Show the notification
    $objNotifyIcon.ShowBalloonTip(15000)

    # Handle cleanup events
    Register-ObjectEvent $objNotifyIcon -EventName BalloonTipClosed -Action {
        $EventSubscriber | Unregister-Event
        $sender.Dispose()
    } | Out-Null

    Register-ObjectEvent $objNotifyIcon -EventName BalloonTipClicked -Action {
        $EventSubscriber | Unregister-Event
        $sender.Dispose()
    } | Out-Null
}

function Show-Info([string]$message, [string]$icon, [string]$title)
{
    Show-Notification -message $message -icon $icon -title $title -level "Info"
}

function Show-Warning([string]$message, [string]$icon, [string]$title)
{
    Show-Notification -message $message -icon $icon -title $title -level "Warning"
}

function Show-Error([string]$message, [string]$icon, [string]$title)
{
    Show-Notification -message $message -icon $icon -title $title -level "Error"
}

#notificacion log message
function Log-Info([string]$Target,[string]$Message)
{
    $finalMessage = "$Target - $Message - INFO"
    Write-Host $finalMessage -ForegroundColor Cyan
}

function Log-Success([string]$Target,[string]$Message ="Completed succesfully")
{
    $finalMessage = "$Target - $Message - SUCCESS"
    Write-Host $finalMessage -ForegroundColor Green
}

function Log-Error([string]$Target,[string]$Message ="An error has occurred")
{
    $finalMessage = "$Target - $message - ERROR"
    Write-Host $finalMessage -ForegroundColor Red
}

function Log-Warning([string]$Target,[string]$Message = "")
{
    $finalMessage = "$Target - $Message - WARNING"
    Write-Host $finalMessage -ForegroundColor Yellow
}
