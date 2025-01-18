BeforeAll { 
    $functions = (Resolve-Path "..\src\Functions.ps1")
    . $functions
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
