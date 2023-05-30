using namespace System.Text.RegularExpressions

class PSWriteUtils {
    $Settings = @{
        ConsoleDefault = @{
            ForegroundColor = 'Gray';
            BackgroundColor = 'Default'
        };

        WriteOption = @{
            Indentation = 0;
            Valid = @{
                General = @{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Default'
                };
                Key = @{
                    ForegroundColor = 'Yellow';
                    BackgroundColor = 'Default'
                };
                KeyBrackets = @{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Default'
                };
                Value = @{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Default'
                }
            };
            Invalid = @{
                General = @{
                    ForegroundColor = 'DarkGray';
                    BackgroundColor = 'Default'
                };
                Key = @{
                    ForegroundColor = 'Red';
                    BackgroundColor = 'Default'
                };
                KeyBrackets = @{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Default'
                };
                Value = @{
                    ForegroundColor = 'DarkGray';
                    BackgroundColor = 'Default';
                    Text = '<INVALID>'
                }
            }
        };

        WriteStatus = @{
            Indentation = 0;
            Message = @{
                ForegroundColor = 'White';
                BackgroundColor = 'Black'
            };
            Type = @{
                Info = @{
                    Text = 'INFO';
                    ForegroundColor = 'Blue';
                    BackgroundColor = 'Black'
                };
                Success = @{
                    Text = 'SUCCESS';
                    ForegroundColor = 'Green';
                    BackgroundColor = 'Black'
                };
                Fail = @{
                    Text = 'FAIL';
                    ForegroundColor = 'Red';
                    BackgroundColor = 'Black'
                }
            };
            Details = @{
                Indentation = 4;
                ForegroundColor = 'Gray';
                BackgroundColor = 'Default'
            }
        };

        WriteCountdown = @{
            Indentation = 0;
            Message = @{
                Text = 'Waiting... ';
                ForegroundColor = 'White';
                BackgroundColor = 'Default'
            };
            Seconds = @{
                Amount = 5;
                ForegroundColor = 'Cyan';
                BackgroundColor = 'Default'
            }
        }
    }
    $ColorTagsRegex = [Regex]::new(
        '(?<escape><)?(?<total><: *(?<foreground>\w*), *(?<background>\w*) *>)',
        [RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase
    )

    PSWriteUtils() {
        $this.InitializeSettings($this.Settings)
    }

    [void] InitializeSettings([hashtable]$Settings) {
        $keys = [array]$Settings.Keys
        for ($i = 0; $i -lt $keys.Count; $i++) {
            $key = $keys[$i]
            $value = $Settings[$key]
            if ($value -is [hashtable]) {
                $this.InitializeSettings($value)
                continue
            }

            if ($value -eq 'default') {
                if ($key -like "*foreground*") {
                    $Settings[$key] = (Get-Host).UI.RawUI.ForegroundColor
                }
                elseif ($key -like "*background*") {
                    $Settings[$key] = (Get-Host).UI.RawUI.BackgroundColor
                }
            }
        }
    }

    [void] WriteColorTags([string] $Text, [bool] $NoNewLine) {
        $tagMatches = $this.ColorTagsRegex.Matches($Text)

        $position = 0
        $foregroundColor = $this.Settings.ConsoleDefault.ForegroundColor
        $backgroundColor = $this.Settings.ConsoleDefault.BackgroundColor
        foreach ($tag in $tagMatches) {
            Write-Host $Text.Substring($position, $tag.Index - $position) -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline
            $position = $tag.Index + $tag.Length

            if ($tag.Groups['escape'].Value) {
                Write-Host $tag.Groups['total'].Value -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline
                continue
            }

            if ((-not $tag.Groups['foreground'].Value) -or ($tag.Groups['foreground'].Value -eq 'default')) {
                $foregroundColor = $this.Settings.ConsoleDefault.ForegroundColor
            }
            else {
                $foregroundColor = $tag.Groups['foreground'].Value
            }

            if ((-not $tag.Groups['background'].Value) -or ($tag.Groups['background'].Value -eq 'default')) {
                $backgroundColor = $this.Settings.ConsoleDefault.BackgroundColor
            }
            else {
                $backgroundColor = $tag.Groups['background'].Value
            }
        }
        Write-Host $Text.Substring($position, $Text.Length - $position) -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline:$NoNewLine
    }

    [void] WriteStatus([string] $Type, [string] $Message, [string] $Details) {
        $padding = (@(
            $this.Settings.WriteStatus.Type.Info.Text.Length,
            $this.Settings.WriteStatus.Type.Success.Text.Length,
            $this.Settings.WriteStatus.Type.Fail.Text.Length
        ) | Measure-Object -Maximum).Maximum
        $Message = $Message.Trim()
        $Details = $Details.Trim()

        $typeString = ''
        $foregroundColor = ''
        $backgroundColor = ''
        switch ($Type) {
            'Info' {
                $typeString = $this.Settings.WriteStatus.Type.Info.Text
                $foregroundColor = $this.Settings.WriteStatus.Type.Info.ForegroundColor
                $backgroundColor = $this.Settings.WriteStatus.Type.Info.BackgroundColor
                Break
            }

            'Success' {
                $typeString = $this.Settings.WriteStatus.Type.Success.Text
                $foregroundColor = $this.Settings.WriteStatus.Type.Success.ForegroundColor
                $backgroundColor = $this.Settings.WriteStatus.Type.Success.BackgroundColor
                Break
            }

            'Fail' {
                $typeString = $this.Settings.WriteStatus.Type.Fail.Text
                $foregroundColor = $this.Settings.WriteStatus.Type.Fail.ForegroundColor
                $backgroundColor = $this.Settings.WriteStatus.Type.Fail.BackgroundColor
                Break
            }

            Default {
                throw [System.Management.Automation.MethodException] "Invalid Type value. It must be one of the following strings: 'Info', 'Success', 'Fail'."
            }
        }

        if ($Message) {
            $typeString = $typeString + ':'
            $padding++
            $Message = ' ' + $Message
        }
        $typeString = $typeString.PadRight($padding)

        Write-Host (' ' * $this.Settings.WriteStatus.Indentation) -NoNewline
        Write-Host $typeString -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline
        Write-Host $Message -ForegroundColor $this.Settings.WriteStatus.Message.ForegroundColor -BackgroundColor $this.Settings.WriteStatus.Message.BackgroundColor
        if ($Details) {
            foreach ($line in ($Details -split "\r?\n")) {
                Write-Host (' ' * $this.Settings.WriteStatus.Details.Indentation) -NoNewline
                Write-Host $line -ForegroundColor $this.Settings.WriteStatus.Details.ForegroundColor -BackgroundColor $this.Settings.WriteStatus.Details.BackgroundColor
            }
        }
    }

    [void] WriteOption([string] $Key, [string] $Name, [string] $CurrentValue, [bool] $IgnoreInvalid) {
        $valid = $IgnoreInvalid -or ([bool] $CurrentValue)

        if (-not $valid) {
            $keyForeground = $this.Settings.WriteOption.Invalid.Key.ForegroundColor
            $keyBackground = $this.Settings.WriteOption.Invalid.Key.BackgroundColor
            $keyBracketsForeground = $this.Settings.WriteOption.Invalid.KeyBrackets.ForegroundColor
            $keyBracketsBackground = $this.Settings.WriteOption.Invalid.KeyBrackets.BackgroundColor
            $generalForeground = $this.Settings.WriteOption.Invalid.General.ForegroundColor
            $generalBackground = $this.Settings.WriteOption.Invalid.General.BackgroundColor
            $CurrentValue = $this.Settings.WriteOption.Invalid.Value.Text
            $CurrentValueForeground = $this.Settings.WriteOption.Invalid.Value.ForegroundColor
            $CurrentValueBackground = $this.Settings.WriteOption.Invalid.Value.BackgroundColor
        }
        else {
            $keyForeground = $this.Settings.WriteOption.Valid.Key.ForegroundColor
            $keyBackground = $this.Settings.WriteOption.Valid.Key.BackgroundColor
            $keyBracketsForeground = $this.Settings.WriteOption.Valid.KeyBrackets.ForegroundColor
            $keyBracketsBackground = $this.Settings.WriteOption.Valid.KeyBrackets.BackgroundColor
            $generalForeground = $this.Settings.WriteOption.Valid.General.ForegroundColor
            $generalBackground = $this.Settings.WriteOption.Valid.General.BackgroundColor
            $CurrentValueForeground = $this.Settings.WriteOption.Valid.Value.ForegroundColor
            $CurrentValueBackground = $this.Settings.WriteOption.Valid.Value.BackgroundColor
        }
        Write-Host (' ' * $this.Settings.WriteOption.Indentation) -NoNewline
        Write-Host '[' -ForegroundColor $keyBracketsForeground -BackgroundColor $keyBracketsBackground -NoNewline
        Write-Host $Key -ForegroundColor $keyForeground -BackgroundColor $keyBackground -NoNewline
        Write-Host ']' -ForegroundColor $keyBracketsForeground -BackgroundColor $keyBracketsBackground -NoNewline
        Write-Host " $Name " -ForegroundColor $generalForeground -BackgroundColor $generalBackground -NoNewline
        Write-Host $CurrentValue -ForegroundColor $CurrentValueForeground -BackgroundColor $CurrentValueBackground
    }

    [void] WriteCountdown([string] $Message, [int] $Seconds) {
        if (-not $Message) {
            $Message = $this.Settings.WriteCountdown.Message.Text
        }
        if ($Seconds -lt 1) {
            $Seconds = $this.Settings.WriteCountdown.Seconds.Amount
        }

        foreach ($i in $Seconds..1) {
            Write-Host ("`r" + (' ' * $this.Settings.WriteCountdown.Indentation)) -NoNewline
            Write-Host $Message -ForegroundColor $this.Settings.WriteCountdown.Message.ForegroundColor -BackgroundColor $this.Settings.WriteCountdown.Message.BackgroundColor -NoNewline
            Write-Host $i.ToString().PadRight($Seconds.ToString().Length) -ForegroundColor $this.Settings.WriteCountdown.Seconds.ForegroundColor -BackgroundColor $this.Settings.WriteCountdown.Seconds.BackgroundColor -NoNewline
            Start-Sleep -Seconds 1
        }
    
        Write-Host ("`r" + ' ' * ($this.Settings.WriteCountdown.Indentation + $Message.Length + $Seconds.ToString().Length + 1) + "`r") -NoNewline
    }

}

$PSWriteUtils = [PSWriteUtils]::new()
Export-ModuleMember -Function * -Alias * -Variable PSWriteUtils