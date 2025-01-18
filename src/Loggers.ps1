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