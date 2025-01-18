BeforeAll { 
    $loggers = (Resolve-Path "..\src\Loggers.ps1")
    . $loggers 
}

Describe "Show-Notification" {
    It "Debe mostrar una notificación con los parámetros correctos" {
        $message = "Test message"
        $level = "Info"
        $icon = "C:\Windows\System32\shell32.dll"
        $title = "Test Title"

        # Llama a la función y verifica si no genera errores
        { Show-Notification -message $message -level $level -icon $icon -title $title } | Should -Not -Throw
    }
}

Describe "Show-Info" {
    It "Should call Show-Notification with Info level" {
        # Mock the Show-Notification function
        Mock Show-Notification {}

        # Call the Show-Info function
        Show-Info -message "Info message" -icon "icon.ico" -title "Info Title"

        # Validate the Mock call
        Assert-MockCalled Show-Notification -Exactly 1 -Scope It
    }
}

Describe "Show-Info" {
    It "Should call Show-Notification with correct parameters" {
        # Mock the Show-Notification function
        Mock Show-Notification {}

        # Call the Show-Info function
        Show-Info -message "Info message" -icon "icon.ico" -title "Info Title"

        # Validate that Show-Notification was called with the correct parameters
        Assert-MockCalled Show-Notification -Exactly 1 -Scope It -ParameterFilter {
            $message -eq "Info message" -and
            $icon -eq "icon.ico" -and
            $title -eq "Info Title" -and
            $level -eq "Info"
        }
    }
}
