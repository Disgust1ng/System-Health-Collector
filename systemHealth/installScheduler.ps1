# ================================
# Install Task Scheduler Job
# ================================

$taskName = "SystemHealthCollector"
$scriptPath = "E:\git\systemHealth\collectMetrics.ps1"

# Action: run PowerShell with your script
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# Trigger: every 10 minutes
$trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 10) `
    -RepetitionDuration (New-TimeSpan -Days 365)

# Settings: basic, safe defaults
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

# Register the task
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Force

Write-Host "Scheduled task '$taskName' created successfully." -ForegroundColor Green
