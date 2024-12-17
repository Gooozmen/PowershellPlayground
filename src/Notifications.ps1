function ShowNotification([string]$message, [string]$level, [string]$icon, [string]$title)
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

function ShowInfo([string]$message, [string]$icon, [string]$title)
{
    ShowNotification -message $message -icon $icon -title $title -level "Info"
}

function ShowWarning([string]$message, [string]$icon, [string]$title)
{
    ShowNotification -message $message -icon $icon -title $title -level "Warning"
}

function ShowError([string]$message, [string]$icon, [string]$title)
{
    ShowNotification -message $message -icon $icon -title $title -level "Error"
}
