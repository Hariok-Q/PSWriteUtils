using module '..\PSWriteUtils.psm1'

Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteCountdown: Default settings", $false)
$PSWriteUtils.WriteCountdown("This is not the default message...", 3, 0)
$PSWriteUtils.WriteCountdown("", 3, -1)
$PSWriteUtils.WriteCountdown("", -1, 8)