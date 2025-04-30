$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

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