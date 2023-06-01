using module '..\PSWriteUtils.psm1'

Write-ColorTags -Text "    <:black, white> Write-Option: Default settings "
Write-Option -Key 1 -Name "Key 1" -CurrentValue "This is the VALUE" -Indentation -1
Write-Option -Key 2 -Name "Key 2" -CurrentValue "This is the VALUE" -Indentation 4
Write-Option -Key 'AB' -Name "Key AB" -CurrentValue '' -Indentation 8
Write-Option -Key 'AB' -Name "Key AB" -CurrentValue '' -Indentation 0 -IgnoreInvalid

Write-Host ''
Write-ColorTags -Text "    <:black, white> Write-Option: Changed settings "
$PSWriteUtils.Settings.WriteOption.Valid.Key.ForegroundColor = 'darkblue'
$PSWriteUtils.Settings.WriteOption.Valid.Key.BackgroundColor = 'darkgray'
$PSWriteUtils.Settings.WriteOption.Valid.KeyBrackets.ForegroundColor = 'blue'
$PSWriteUtils.Settings.WriteOption.Valid.KeyBrackets.BackgroundColor = 'darkgray'
$PSWriteUtils.Settings.WriteOption.Invalid.Key.ForegroundColor = 'darkred'
$PSWriteUtils.Settings.WriteOption.Invalid.Key.BackgroundColor = 'darkgray'
$PSWriteUtils.Settings.WriteOption.Invalid.KeyBrackets.ForegroundColor = 'red'
$PSWriteUtils.Settings.WriteOption.Invalid.KeyBrackets.BackgroundColor = 'darkgray'
$PSWriteUtils.Settings.WriteOption.Valid.General.ForegroundColor = 'BLACK'
$PSWriteUtils.Settings.WriteOption.Valid.General.BackgroundColor = 'WhiTe'
$PSWriteUtils.Settings.WriteOption.Valid.Value.ForegroundColor = 'Green'
$PSWriteUtils.Settings.WriteOption.Valid.Value.BackgroundColor = 'DarkGray'
$PSWriteUtils.Settings.WriteOption.Invalid.Value.ForegroundColor = 'Red'
$PSWriteUtils.Settings.WriteOption.Invalid.Value.BackgroundColor = 'DarkGray'
$PSWriteUtils.Settings.WriteOption.Invalid.Value.Text = '<----->'
$PSWriteUtils.Settings.WriteOption.Indentation = 5
$PSWriteUtils.ApplySettings()
Write-Option -Key 1 -Name "Key 1" -CurrentValue "This is the VALUE" -Indentation -1
Write-Option -Key 2 -Name "Key 2" -CurrentValue "This is the VALUE" -Indentation 4
Write-Option -Key 'AB' -Name "Key AB" -CurrentValue '' -Indentation 8
Write-Option -Key 'AB' -Name "Key AB" -CurrentValue '' -Indentation 0 -IgnoreInvalid