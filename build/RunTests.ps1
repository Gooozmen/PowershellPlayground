$LoggerTestsPath = Resolve-Path ("..\Tests\LoggerTests.ps1")
$FunctionsTestsPath = Resolve-Path ("..\Tests\FunctionTests.ps1")

Invoke-Pester -Path $LoggerTestsPath -Verbose
Invoke-Pester -Path $FunctionsTestsPath -Verbose
