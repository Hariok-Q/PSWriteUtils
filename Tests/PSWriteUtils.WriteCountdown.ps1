using module '..\PSWriteUtils.psm1'

$WrUt = [PSWriteUtils]::new()
$WrUt.WriteColorTags("    <:black, white> Write-Countdown: Default settings ", $false)
$WrUt.WriteCountdown("", -1, -1)
$WrUt.WriteCountdown("This is not the default message...", 3, 0)
$WrUt.WriteCountdown("", 3, -1)
$WrUt.WriteCountdown("", -1, 8)