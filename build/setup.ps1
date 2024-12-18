$ToolsPath = Resolve-Path ".\Tools.ps1"
. $ToolsPath

Install-Dependencies
Import-PsakeModule