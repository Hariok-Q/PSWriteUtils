foreach ($file in Get-ChildItem) {
    if ($file.Extension -ne '.ps1') { continue }
    if ($file.BaseName -like "*Run All*") { continue }

    . $file.FullName

    Write-Host ("`n`n`n`n" + ('# ' * ($Global:Host.UI.RawUI.BufferSize.Width/2)) + "`n`n")
}

Pause