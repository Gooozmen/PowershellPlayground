# Test for Clean-Solution
# Load the functions to test
$functions = Resolve-Path "..\src\Functions.ps1"
Write-Host "Functions path $functions"
. $functions

# Verify if the function is loaded
if (-not (Get-Command Clean-Solution -ErrorAction SilentlyContinue)) {
    Write-Error "Function 'Clean-Solution' not found. Ensure it is defined in $functions."
    exit 1
}

# Mock the logging functions with proper parameter structure
Mock -CommandName Log-Info -MockWith {
    param($Target, $Message)
    Write-Host "Mock Log-Info called with Target: $Target, Message: $Message"
}

Mock -CommandName Log-Success -MockWith {
    param($Target, $Message)
    Write-Host "Mock Log-Success called with Target: $Target, Message: $Message"
}

Mock -CommandName Log-Error -MockWith {
    param($Target, $Message)
    Write-Host "Mock Log-Error called with Target: $Target, Message: $Message"
}

# Test for Clean-Solution
Describe "Clean-Solution" {
    It "Should call 'dotnet clean' with the correct SolutionPath" {
        Mock -CommandName dotnet -MockWith { $global:LASTEXITCODE = 0 }

        $solutionPath = "TestSolution.sln"
        Clean-Solution -SolutionPath $solutionPath

        Assert-MockCalled -CommandName dotnet "clean" $solutionPath -Exactly 1 -Scope It
        Assert-MockCalled -CommandName Log-Info -Target "Clean-Solution" -Message "Cleaning solution: $solutionPath"  -Exactly 1 -Scope It
    }

    It "Should log an error if 'dotnet clean' fails" {
        Mock -CommandName dotnet -MockWith { $global:LASTEXITCODE = 1 }

        $solutionPath = "TestSolution.sln"
        { Clean-Solution -SolutionPath $solutionPath } | Should -Throw

        Assert-MockCalled -CommandName Log-Error -Exactly 1 -Scope It -Arguments @("Clean-Solution", "An error has occurred")
    }
}


# # Test for Restore-Solution
# Describe "Restore-Solution" {
#     It "Should call 'dotnet restore' with the correct SolutionPath" {
#         Mock -CommandName dotnet -MockWith { $global:LASTEXITCODE = 0 }

#         $solutionPath = "TestSolution.sln"
#         Restore-Solution -SolutionPath $solutionPath

#         Assert-MockCalled -CommandName dotnet -Exactly 1 -Scope It -Parameters @{ Arguments = @("restore", $solutionPath) }
#         Assert-MockCalled -CommandName Log-Info -Exactly 1 -Scope It -Parameters @{ Target = "Restore-Solution"; Message = "Restoring NuGet packages for: $solutionPath" }
#         Assert-MockCalled -CommandName Log-Success -Exactly 1 -Scope It -Parameters @{ Target = "Restore-Solution"; Message = "Completed succesfully" }
#     }
# }

# # Test for Build-Solution
# Describe "Build-Solution" {
#     It "Should call 'dotnet build' with the correct arguments" {
#         Mock -CommandName dotnet -MockWith { $global:LASTEXITCODE = 0 }

#         $solutionPath = "TestSolution.sln"
#         $configuration = "Debug"
#         Build-Solution -SolutionPath $solutionPath -Configuration $configuration

#         Assert-MockCalled -CommandName dotnet -Exactly 1 -Scope It -Parameters @{
#             Arguments = @("build", $solutionPath, "--configuration", $configuration, "--no-restore")
#         }
#         Assert-MockCalled -CommandName Log-Info -Exactly 1 -Scope It -Parameters @{
#             Target = "Build-Solution"; Message = "Building solution: $solutionPath with Configuration: $configuration"
#         }
#         Assert-MockCalled -CommandName Log-Success -Exactly 1 -Scope It -Parameters @{ Target = "Build-Solution"; Message = "Completed succesfully" }
#     }
# }

# # Test for Upload-Solution
# Describe "Upload-Solution" {
#     It "Should call 'dotnet publish' with the correct arguments" {
#         Mock -CommandName dotnet -MockWith { $global:LASTEXITCODE = 0 }

#         $solutionPath = "TestSolution.sln"
#         $outputPath = "bin/Release"
#         $configuration = "Release"
#         Upload-Solution -SolutionPath $solutionPath -OutputPath $outputPath -Configuration $configuration

#         Assert-MockCalled -CommandName dotnet -Exactly 1 -Scope It -Parameters @{
#             Arguments = @("publish", $solutionPath, "-c", $configuration, "-o", $outputPath)
#         }
#         Assert-MockCalled -CommandName Log-Info -Exactly 1 -Scope It -Parameters @{
#             Target = "Publish-Solution"; Message = "Publishing solution: $solutionPath to Output Path: $outputPath"
#         }
#         Assert-MockCalled -CommandName Log-Success -Exactly 1 -Scope It -Parameters @{ Target = "Publish-Solution"; Message = "Completed succesfully" }
#     }
# }

# # Test for Zip-Folder
# Describe "Zip-Folder" {
#     It "Should call 7z.exe with the correct arguments" {
#         Mock -CommandName Test-Path -MockWith { $true }

#         $sourceFolder = "C:\SourceFolder"
#         $outputFolder = "C:\Destination\output.zip"

#         Mock -CommandName & -MockWith {
#             param($args)
#             if ($args -contains "-tzip") { $global:LASTEXITCODE = 0 } else { $global:LASTEXITCODE = 1 }
#         }

#         Zip-Folder -SourceFolder $sourceFolder -OutputFolder $outputFolder

#         Assert-MockCalled -CommandName & -Exactly 1 -Scope It -Parameters @{
#             Arguments = @("7z.exe", "a", "-tzip", $outputFolder, "$sourceFolder\*")
#         }
#         Assert-MockCalled -CommandName Log-Info -Exactly 1 -Scope It -Parameters @{
#             Target = "Zip Folder"; Message = "ZIP file created successfully: $outputFolder"
#         }
#     }
# }
