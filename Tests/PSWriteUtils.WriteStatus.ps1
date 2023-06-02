using module '..\PSWriteUtils.psm1'

$WrUt.WriteColorTags("    <:black, white> Write-Status: Default settings ", $false)
$WrUt.WriteStatus('info', 'Information message', "These are the details.")
Write-Host ''
$WrUt.WriteStatus('suCCess', 'Success message', "These are the details.")
Write-Host ''
$WrUt.WriteStatus('FAIL', 'Fail message', @"
These are
multiline details.
Another one.

"@)

Write-Host ''
$WrUt.WriteColorTags("    <:black, white> Write-Status: Changed settings ", $false)
$WrUt.Settings.WriteStatus.Indentation = 4
$WrUt.Settings.WriteStatus.Message.ForegroundColor = 'gray'
$WrUt.Settings.WriteStatus.Message.BackgroundColor = 'darkgray'
$WrUt.Settings.WriteStatus.Type.Info.Text = 'InFoRmAtIoN'
$WrUt.Settings.WriteStatus.Type.Info.ForegroundColor = 'darkcyan'
$WrUt.Settings.WriteStatus.Type.Info.BackgroundColor = 'white'
$WrUt.Settings.WriteStatus.Type.Success.Text = 'SuCcEsS'
$WrUt.Settings.WriteStatus.Type.Success.ForegroundColor = 'darkgreen'
$WrUt.Settings.WriteStatus.Type.Success.BackgroundColor = 'white'
$WrUt.Settings.WriteStatus.Type.Fail.Text = 'fAiL'
$WrUt.Settings.WriteStatus.Type.Fail.ForegroundColor = 'darkred'
$WrUt.Settings.WriteStatus.Type.Fail.BackgroundColor = 'white'
$WrUt.Settings.WriteStatus.Details.Indentation = 8
$WrUt.Settings.WriteStatus.Details.ForegroundColor = 'blue'
$WrUt.Settings.WriteStatus.Details.BackgroundColor = 'darkblue'
$WrUt.ApplySettings()
$WrUt.WriteStatus('info', 'Information message', "These are the details.")
Write-Host ''
$WrUt.WriteStatus('suCCess', 'Success message', "These are the details.")
Write-Host ''
$WrUt.WriteStatus('FAIL', 'Fail message', @"
These are
multiline details.
Another one.

"@)


Write-Host ''
$WrUt.WriteColorTags("    <:black, white> Write-Status: Type error ", $false)
try {
    $WrUt.WriteStatus('NotAType', 'some message?', "This should not print.")
}
catch {
    Write-Host $Error[0].ToString() -ForegroundColor 'Red' -NoNewline
    Write-Host ''
}