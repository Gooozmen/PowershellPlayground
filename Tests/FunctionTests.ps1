BeforeAll { 
    $solution = (Resolve-Path "..\src\solution.ps1")
    $loggers = (Resolve-Path "..\src\Loggers.ps1")

    . $solution
    . $loggers
}

Describe "Clean-Solution" {
    It "Should log success when dotnet clean succeeds" {
        Mock Log-Info {}
        Mock Log-Success {}
        Mock Log-Error {}
        Mock dotnet { return 0 } -ParameterFilter { $args[0] -eq "clean" }

        Clean-Solution -SolutionPath "test.sln"

        Assert-MockCalled Log-Info -Exactly 1 -Scope It
        Assert-MockCalled Log-Success -Exactly 1 -Scope It
        Assert-MockCalled Log-Error -Exactly 0 -Scope It
    }
}
