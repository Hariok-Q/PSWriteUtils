using module '..\PSWriteUtils.psm1'

Write-Host ''
Write-ColorTags -Text "    <:black, white>WriteStatus: Default settings"
Write-Status -Type 'info' -Message 'Information message' -Details "These are the details."
Write-Host ''
Write-Status -Type 'suCCess' -Message 'Success message' -Details "These are the details."
Write-Host ''
Write-Status -Type 'FAIL' -Message 'Fail message' -Details @"
These are
multiline details.
Another one.

"@

Write-Host ''
Write-ColorTags -Text "    <:black, white>WriteStatus: Changed settings"
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
Write-Status -Type 'info' -Message 'Information message' -Details "These are the details."
Write-Host ''
Write-Status -Type 'suCCess' -Message 'Success message' -Details "These are the details."
Write-Host ''
Write-Status -Type 'FAIL' -Message 'Fail message' -Details @"
These are
multiline details.
Another one.

"@


Write-Host ''
Write-ColorTags -Text "    <:black, white>WriteStatus: Type error"
try {
    Write-Status -Type 'NotAType' -Message 'some message?' -Details "These are the details (should not print)."
}
catch {
    Write-Host $Error[0].ToString() -ForegroundColor 'Red' -NoNewline
    Write-Host ''
}