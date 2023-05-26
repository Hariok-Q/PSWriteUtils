# PSWriteUtils

PSWriteUtils is a PowerShell module that adds some cmdlets to make writing text to the console window easier and faster.

The most important cmdlet is `Write-ColorTags`, but it also exposes `Write-Status`, `Write-Options` and `Write-Countdown`.



## `Write-ColorTags`

`Write-ColorTags` allows writing tags in the format `<:foregroundColor, backgroundColor>` on the text body in order to change the color of the printed text.

All of the text that comes after the tag will print in the specified color. In order to change back to default, use `<:,>` (empty values means default). You can also use `<:red,>` to change only the foreground, or `<:, red>` to change only the background. 

To escape the tag, use double left angle brackets `<<` instead of single (`<<:foreground, background>`).

Example:

```powershell
Write-ColorTags -Text @"
This text is in default color, but <:black, red>from now on we're using black foreground with red background.
Even after line breaks.
If we want to reset to <:,>default, we can simply write <<:,> (because <:cyan,>empty tags<:,> reset to default colors.)
@"
```



## Write-Status

Writes a status message in the formats:

```
INFO: information message.
Optional details of the information message.

FAIL: fail message.
Optional details of the fail message.

SUCCESS: success message.
Optional details of the success message.
```

The `TYPE` string (`INFO`, `FAIL` or `SUCCESS`) is colored accordingly.

Example:

```powershell
Write-Status -Type Fail -Message 'copying files failed.' -Details @"
The following file already exists at the destination:
    testFile.txt
"@
```



## Write-Option

Writes colored options for the user to choose from (useful when creating text interfaces).

Example:

```powershell
Write-Option -Key '1' -Name "File to be copied:     " -CurrentValue 'C:\testFile.txt'
Write-Option -Key '2' -Name "Destination folder:    "
Write-Host ''
Write-Option -Key 'C' -Name "Continue" -IgnoreInvalid
Write-Option -Key 'C' -Name "Exit" -IgnoreInvalid
```

Notice that `Write-Option` may have a `CurrentValue` parameter. If no value is passed to the `-CurrentValue` parameter, then `<INVALID>` is shown, unless the `-IgnoreInvalid` switch is specified.



## Write-Countdown

Writes a countdown that changes in-line.

Example:

```powershell
Write-Countdown -Message "Waiting..." -Seconds 5
```

