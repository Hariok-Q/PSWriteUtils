using module '..\PSWriteUtils.psm1'

Write-Host ''
Write-ColorTags -Text "    <:black, white>WriteCountdown: Default settings"
Write-Countdown -Message "" -Seconds -1 -Indentation -1
Write-Countdown -Message "This is not the default message..." -Seconds 3 -Indentation 0
Write-Countdown -Message "" -Seconds 3 -Indentation -1
Write-Countdown -Message "" -Seconds -1 -Indentation 8