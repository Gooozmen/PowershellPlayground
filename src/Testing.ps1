$loggers = Resolve-Path "$PSScriptRoot\Loggers.ps1"
. $loggers

function Invoke-DotnetTests([string]$TestDllPath,
                            [string]$ResultsDirectory)
{
    $currentTarget = "Invoke DotnetTests"
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
        Log-Success -Target $currentTarget -Message "Tests completed successfully. Results saved to $ResultsDirectory"
        
        
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
    else {
        Log-Error -Target $currentTarget -Message "Test result is not present at Artifacts folder"
    }
}