# Get current time
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ---------- CPU ----------
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpu = [math]::Round($cpu, 2)

# ---------- Memory ----------
$os = Get-CimInstance Win32_OperatingSystem

$totalRamMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
$freeRamMB  = [math]::Round($os.FreePhysicalMemory / 1024, 0)
$usedRamMB  = $totalRamMB - $freeRamMB

# ---------- Disk ----------
$disk = Get-PSDrive -PSProvider FileSystem | Select-Object `
    Name,
    @{Name="FreeGB";Expression={[math]::Round($_.Free / 1GB, 1)}},
    @{Name="TotalGB";Expression={[math]::Round(($_.Free + $_.Used) / 1GB, 1)}}

# ---------- Uptime ----------
$lastBoot = $os.LastBootUpTime
$uptime = (Get-Date) - $lastBoot
$uptimeText = "$($uptime.Days) days $($uptime.Hours) hours"

# ---------- Output object ----------
$metrics = [PSCustomObject]@{
    Time        = $timestamp
    CPU_Percent = $cpu
    RAM_Used_MB = $usedRamMB
    RAM_Total_MB = $totalRamMB
    Uptime      = $uptimeText
}

# ---------- Write to CSV ----------
$csv = ".\metrics.csv"

if (-not (Test-Path $csv)) {
    $metrics | Export-Csv $csv -NoTypeInformation
} else {
    $metrics | Export-Csv $csv -Append -NoTypeInformation
}

# ---------- Display ----------
Write-Host "System Metrics @ $timestamp" -ForegroundColor Green
Write-Host "CPU Usage: $cpu %"
Write-Host "RAM Used: $usedRamMB MB / $totalRamMB MB"
Write-Host "Uptime: $uptimeText"
Write-Host ""

Write-Host "Disk Space:" -ForegroundColor Cyan
$disk | Format-Table -AutoSize
