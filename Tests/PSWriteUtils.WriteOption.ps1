using module '..\PSWriteUtils.psm1'

$WrUt = [PSWriteUtils]::new()
$WrUt.WriteColorTags("    <:black, white> Write-Option: Default settings ", $false)
$WrUt.WriteOption(1, "Key 1", "This is the VALUE", $false, -1)
$WrUt.WriteOption(2, "Key 2", "This is the VALUE", $false, 4)
$WrUt.WriteOption('AB', "Key AB", '', $false, 8)
$WrUt.WriteOption('AB', "Key AB", '', $true, 0)

Write-Host ''
$WrUt.WriteColorTags("    <:black, white> Write-Option: Changed settings ", $false)
$WrUt.Settings.WriteOption.Valid.Key.ForegroundColor = 'darkblue'
$WrUt.Settings.WriteOption.Valid.Key.BackgroundColor = 'darkgray'
$WrUt.Settings.WriteOption.Valid.KeyBrackets.ForegroundColor = 'blue'
$WrUt.Settings.WriteOption.Valid.KeyBrackets.BackgroundColor = 'darkgray'
$WrUt.Settings.WriteOption.Invalid.Key.ForegroundColor = 'darkred'
$WrUt.Settings.WriteOption.Invalid.Key.BackgroundColor = 'darkgray'
$WrUt.Settings.WriteOption.Invalid.KeyBrackets.ForegroundColor = 'red'
$WrUt.Settings.WriteOption.Invalid.KeyBrackets.BackgroundColor = 'darkgray'
$WrUt.Settings.WriteOption.Valid.General.ForegroundColor = 'BLACK'
$WrUt.Settings.WriteOption.Valid.General.BackgroundColor = 'WhiTe'
$WrUt.Settings.WriteOption.Valid.Value.ForegroundColor = 'Green'
$WrUt.Settings.WriteOption.Valid.Value.BackgroundColor = 'DarkGray'
$WrUt.Settings.WriteOption.Invalid.Value.ForegroundColor = 'Red'
$WrUt.Settings.WriteOption.Invalid.Value.BackgroundColor = 'DarkGray'
$WrUt.Settings.WriteOption.Invalid.Value.Text = '<----->'
$WrUt.Settings.WriteOption.Indentation = 5
$WrUt.ApplySettings()
$WrUt.WriteOption(1, "Key 1", "This is the VALUE", $false, -1)
$WrUt.WriteOption(2, "Key 2", "This is the VALUE", $false, 4)
$WrUt.WriteOption('AB', "Key AB", '', $false, 8)
$WrUt.WriteOption('AB', "Key AB", '', $true, 0)