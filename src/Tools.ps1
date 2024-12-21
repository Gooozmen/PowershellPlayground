Include ".\Functions.ps1"

task Build -depends NugetRestore{
    Build-solution -SolutionPath $SolutionPath -Configuration $configuration
}

task Clean{
    Clean-solution -SolutionPath $SolutionPath
}

task NugetRestore{
    Restore-solution -SolutionPath $SolutionPath
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

function Publish-Solution ([string]$SolutionPath,[string]$OutputPath,[string]$Configuration = "Release")
{
    $currentTarget = "Publish-Solution"
    Log-Info -Target $currentTarget -Message "Publishing solution: $SolutionPath to Output Path: $OutputPath"
    if ($LASTEXITCODE -ne 0) {
        Log-Error -Target $currentTarget
        exit 1
    }
    else{
        Log-Success -Target $currentTarget
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
    $GitHubToken = "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"
    $AbsolutePackagePath = Resolve-Path $PackagePath
    
    # Push the package
    try {
        Log-Info -Target $currentTarget -Message "Pushing package to GitHub repository..."
        & nuget push $PackagePath -Source $RepositoryUrl -ApiKey $GitHubToken

        if ($LASTEXITCODE -ne 0) {
            Log-Error -Target $currentTarget
            exit 1
        }
    }
    catch {
        Log-Error -Target $currentTarget

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
