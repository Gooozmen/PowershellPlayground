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

function Push-NuGetPackage([string]$PackagePath,[string]$RepositoryUrl,[string]$GitHubToken,[string]$ApiKey = "GITHUB")
{
    $currentTarget = "Push-NuGetPackage"
    # Check if the NuGet CLI is installed
    if (-not (Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Log-Error -Target $currentTarget -Message "NuGet CLI not found. Please install it from https://www.nuget.org/downloads and ensure it's in your PATH."
        return
    }

    # Validate parameters
    if (-not (Test-Path $PackagePath)) {
        Log-Error -Target $currentTarget -Message "Package file not found at path: $PackagePath"
        return
    }
    if ([string]::IsNullOrWhiteSpace($RepositoryUrl) -or [string]::IsNullOrWhiteSpace($GitHubToken)) {
        Write-Error 
        Log-Error -Target $currentTarget -Message "Repository URL and GitHub token are required."
        return
    }

    # Push the package
    try {
        Log-Info -Target $currentTarget -Message "Pushing package to GitHub repository..."
        & nuget push $PackagePath `
                    -Source $RepositoryUrl `
                    -ApiKey $GitHubToken `
                    -NonInteractive

        if ($LASTEXITCODE -ne 0) {
            Log-Error -Target $currentTarget
        exit 1
        }
        else{
            Log-Success -Target $currentTarget
        }
    }
    catch {
        Log-Error -Target $currentTarget

    }

    dotnet nuget push "..\Artifacts\Toolkit.1.0.0.nupkg" --api-key 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 --source "github"
dotnet nuget add source --username Gooozmen --password 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 --store-password-in-clear-text --name github "https://nuget.pkg.github.com/Gooozmen/index.json"
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

 




