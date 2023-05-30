using module '..\PSWriteUtils.psm1'

Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteStatus: Default settings", $false)
$PSWriteUtils.WriteStatus('info', 'Information message', "These are the details.")
Write-Host ''
$PSWriteUtils.WriteStatus('suCCess', 'Success message', "These are the details.")
Write-Host ''
$PSWriteUtils.WriteStatus('FAIL', 'Fail message', @"
These are
multiline details.
Another one.

"@)

Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteStatus: Changed settings", $false)
$PSWriteUtils.Settings.WriteStatus.Indentation = 4
$PSWriteUtils.Settings.WriteStatus.Message.ForegroundColor = 'gray'
$PSWriteUtils.Settings.WriteStatus.Message.BackgroundColor = 'darkgray'
$PSWriteUtils.Settings.WriteStatus.Type.Info.Text = 'InFoRmAtIoN'
$PSWriteUtils.Settings.WriteStatus.Type.Info.ForegroundColor = 'darkcyan'
$PSWriteUtils.Settings.WriteStatus.Type.Info.BackgroundColor = 'white'
$PSWriteUtils.Settings.WriteStatus.Type.Success.Text = 'SuCcEsS'
$PSWriteUtils.Settings.WriteStatus.Type.Success.ForegroundColor = 'darkgreen'
$PSWriteUtils.Settings.WriteStatus.Type.Success.BackgroundColor = 'white'
$PSWriteUtils.Settings.WriteStatus.Type.Fail.Text = 'fAiL'
$PSWriteUtils.Settings.WriteStatus.Type.Fail.ForegroundColor = 'darkred'
$PSWriteUtils.Settings.WriteStatus.Type.Fail.BackgroundColor = 'white'
$PSWriteUtils.Settings.WriteStatus.Details.Indentation = 8
$PSWriteUtils.Settings.WriteStatus.Details.ForegroundColor = 'blue'
$PSWriteUtils.Settings.WriteStatus.Details.BackgroundColor = 'darkblue'
$PSWriteUtils.WriteStatus('info', 'Information message', "These are the details.")
Write-Host ''
$PSWriteUtils.WriteStatus('suCCess', 'Success message', "These are the details.")
Write-Host ''
$PSWriteUtils.WriteStatus('FAIL', 'Fail message', @"
These are
multiline details.
Another one.

"@)


Write-Host ''
$PSWriteUtils.WriteColorTags("<:black, white>WriteStatus: Type error", $false)
try {
    $PSWriteUtils.WriteStatus('NotAType', 'some message?', "These are the details (should not print).")
}
catch {
    Write-Host $Error[0].ToString() -ForegroundColor 'Red' -NoNewline
    Write-Host ''
}