foreach ($file in Get-ChildItem) {
    if ($file.Extension -ne '.ps1') { continue }

    . $file.FullName

    Write-Host ("`n`n" + ('# ' * ($Global:Host.UI.RawUI.BufferSize.Width/2)) + "`n`n")
}

Pause