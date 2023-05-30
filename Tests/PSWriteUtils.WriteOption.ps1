using module '..\PSWriteUtils.psm1'

Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteOption: Default settings", $false)
$PSWriteUtils.WriteOption(1, "Key 1", "This is the VALUE", $false, -1)
$PSWriteUtils.WriteOption(2, "Key 2", "This is the VALUE", $false, 4)
$PSWriteUtils.WriteOption('AB', "Key AB", '', $false, 8)
$PSWriteUtils.WriteOption('AB', "Key AB", '', $true, 0)

Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteOption: Changed settings", $false)
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
$PSWriteUtils.WriteOption(1, "Key 1", "This is the VALUE", $false, -1)
$PSWriteUtils.WriteOption(2, "Key 2", "This is the VALUE", $false, 4)
$PSWriteUtils.WriteOption('AB', "Key AB", '', $false, 8)
$PSWriteUtils.WriteOption('AB', "Key AB", '', $true, 0)