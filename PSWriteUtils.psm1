using namespace System.Text.RegularExpressions
using namespace System.Management.Automation

class PSWriteUtils {
    $Settings = @{
        Defaults = @{
            ForegroundColor = 'Gray';
            BackgroundColor = 'Default'
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

        WriteOption = @{
            Indentation = 0;
            Valid = @{
                General = @{
                    ForegroundColor = 'Default';
                    BackgroundColor = 'Default'
                };
                Key = @{
                    ForegroundColor = 'Yellow';
                    BackgroundColor = 'Default'
                };
                KeyBrackets = @{
                    ForegroundColor = 'Default';
                    BackgroundColor = 'Default'
                };
                Value = @{
                    ForegroundColor = 'Default';
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
                    ForegroundColor = 'Default';
                    BackgroundColor = 'Default'
                };
                Value = @{
                    ForegroundColor = 'DarkGray';
                    BackgroundColor = 'Default';
                    Text = '<INVALID>'
                }
            }
        };

        WriteCountdown = @{
            Indentation = 0;
            Message = @{
                Text = 'Waiting... ';
                ForegroundColor = 'Default';
                BackgroundColor = 'Default'
            };
            Seconds = @{
                Amount = 5;
                ForegroundColor = 'Cyan';
                BackgroundColor = 'Default'
            }
        }
    }
    hidden $ResolvedSettings = @{}

    hidden static $ColorTagsRegex = [Regex]::new(
        '(?<Escape><)?(?<Total><: *(?<Foreground>\w*), *(?<Background>\w*) *>)',
        [RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase
    )
    hidden static $ColorSettingsRegex = [Regex]::new(
        '(?<Type>(?:(?:Fore)|(?:Back))ground)Color',
        [RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase
    )


    PSWriteUtils() {
        $this.ResolveSettings()
    }

    [void] ResolveSettings() {
        $this.ResolvedSettings = [PSSerializer]::Deserialize([PSSerializer]::Serialize($this.Settings))
        $this.RecursiveResolveSettingsColors($this.ResolvedSettings)
        $Global:Host.UI.RawUI.ForegroundColor = $this.ResolvedSettings.Defaults.ForegroundColor
        $Global:Host.UI.RawUI.BackgroundColor = $this.ResolvedSettings.Defaults.BackgroundColor
    }

    hidden [void] RecursiveResolveSettingsColors([hashtable]$ResolvedSettings) {
        $keys = [array]$ResolvedSettings.Keys
        for ($i = 0; $i -lt $keys.Count; $i++) {
            $key = $keys[$i]
            $value = $ResolvedSettings[$key]

            if ($value -is [hashtable]) {
                $this.RecursiveResolveSettingsColors($value)
                continue
            }

            $regexMatch = [PSWriteUtils]::ColorSettingsRegex.Match($key)
            if (-not $regexMatch.Success) { continue }

            $ResolvedSettings[$key] = $this.ResolveSettingsColorName($value.ToString(), $regexMatch.Groups['Type'].Value)
        }
    }

    hidden [string] ResolveSettingsColorName([string]$ColorName, [string]$Type) {
        if (@('Foreground', 'Background') -notcontains $Type) {
            throw [System.Management.Automation.MethodException] "Invalid color Type '$Type'. It must be 'Foreground' or 'Background'."
        }
        $AcceptedColors = @('Default') + [System.ConsoleColor].GetEnumNames()
        if ($AcceptedColors -notcontains $ColorName) {
            throw [System.Management.Automation.MethodException] "Invalid Color '$ColorName'. It must be one of the following: Default, $($AcceptedColors -join ', ')."
        }

        if ($ColorName -eq 'Default') {
            if ($Type -eq 'Foreground') {
                if ($this.Settings.Defaults.ForegroundColor -eq 'Default') {
                    return $Global:Host.UI.RawUI.ForegroundColor
                }
                return $this.Settings.Defaults.ForegroundColor
            }
            else {    # $Type = 'Background'
                if ($this.Settings.Defaults.BackgroundColor -eq 'Default') {
                    return $Global:Host.UI.RawUI.BackgroundColor
                }
                return $this.Settings.Defaults.BackgroundColor
            }
        }

        Return $ColorName
    }

    [void] WriteColorTags([string] $Text, [bool] $NoNewLine) {
        $tagMatches = [PSWriteUtils]::ColorTagsRegex.Matches($Text)

        $position = 0
        $colors = @{
            'Foreground' = $this.ResolvedSettings.Defaults.ForegroundColor;
            'Background' = $this.ResolvedSettings.Defaults.BackgroundColor
        }

        foreach ($tag in $tagMatches) {
            Write-Host $Text.Substring($position, $tag.Index - $position) `
                -ForegroundColor $colors['Foreground'] `
                -BackgroundColor $colors['Background'] -NoNewline
            $position = $tag.Index + $tag.Length

            if ($tag.Groups['Escape'].Value) {
                Write-Host $tag.Groups['Total'].Value `
                    -ForegroundColor $colors['Foreground'] `
                    -BackgroundColor $colors['Background'] -NoNewline
                continue
            }


            foreach ($colorType in $colors.Clone().Keys) {
                if ((-not $tag.Groups[$colorType].Value) -or ($tag.Groups[$colorType].Value -eq 'Default')) {
                    $colors[$colorType] = $this.ResolvedSettings.Defaults["${colorType}Color"]
                }
                else {
                    $colors[$colorType] = $tag.Groups[$colorType].Value
                }

                if ([System.ConsoleColor].GetEnumNames() -notcontains $colors[$colorType]) {
                    throw [System.Management.Automation.MethodException] "Invalid color name '$($colors[$colorType])' at index $($tag.Index): '$($tag.Groups[0])'."
                }
            }
        }
        Write-Host $Text.Substring($position, $Text.Length - $position) `
            -ForegroundColor $colors['Foreground'] `
            -BackgroundColor $colors['Background'] -NoNewline

        #   Workaround for known Powershell bug #18984 (https://github.com/PowerShell/PowerShell/issues/18984)
        Write-Host '' -NoNewline:$NoNewLine
    }

    [void] WriteStatus([string] $Type, [string] $Message, [string] $Details) {
        if (@('Info', 'Success', 'Fail') -notcontains $Type) {
            throw [System.Management.Automation.MethodException] "Invalid Type '$Type'. It must be one of the following strings: 'Info', 'Success', 'Fail'."
        }

        $padding = (@(
            $this.ResolvedSettings.WriteStatus.Type.Info.Text.Length,
            $this.ResolvedSettings.WriteStatus.Type.Success.Text.Length,
            $this.ResolvedSettings.WriteStatus.Type.Fail.Text.Length
        ) | Measure-Object -Maximum).Maximum
        $Message = $Message.Trim()
        $Details = $Details.Trim()

        $typeString = $this.ResolvedSettings.WriteStatus.Type[$Type].Text
        if ($Message) {
            $typeString = $typeString + ':'
            $padding++
            $Message = ' ' + $Message
        }
        $typeString = $typeString.PadRight($padding)

        Write-Host (' ' * $this.ResolvedSettings.WriteStatus.Indentation) -NoNewline
        Write-Host $typeString `
            -ForegroundColor $this.ResolvedSettings.WriteStatus.Type[$Type].ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteStatus.Type[$Type].BackgroundColor -NoNewline
        Write-Host $Message `
            -ForegroundColor $this.ResolvedSettings.WriteStatus.Message.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteStatus.Message.BackgroundColor
        if ($Details) {
            foreach ($line in ($Details -split "\r?\n")) {
                Write-Host (' ' * $this.ResolvedSettings.WriteStatus.Details.Indentation) -NoNewline
                Write-Host $line `
                    -ForegroundColor $this.ResolvedSettings.WriteStatus.Details.ForegroundColor `
                    -BackgroundColor $this.ResolvedSettings.WriteStatus.Details.BackgroundColor
            }
        }
    }

    [void] WriteOption([string] $Key, [string] $Name, [string] $CurrentValue, [bool] $IgnoreInvalid, [int] $Indentation) {
        $valid = $IgnoreInvalid -or ([bool] $CurrentValue)
        $validitySettingsName = 'Valid'
        if (-not $valid) {
            $validitySettingsName = 'Invalid'
            $CurrentValue = $this.ResolvedSettings.WriteOption[$validitySettingsName].Value.Text
        }

        if ($Indentation -lt 0) {
            $Indentation = $this.ResolvedSettings.WriteOption.Indentation
        }

        Write-Host (' ' * $Indentation) -NoNewline
        Write-Host '[' `
            -ForegroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].KeyBrackets.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].KeyBrackets.BackgroundColor -NoNewline
        Write-Host $Key `
            -ForegroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].Key.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].Key.BackgroundColor -NoNewline
        Write-Host ']' `
            -ForegroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].KeyBrackets.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].KeyBrackets.BackgroundColor -NoNewline
        Write-Host " $Name " `
            -ForegroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].General.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].General.BackgroundColor -NoNewline
        Write-Host $CurrentValue `
            -ForegroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].Value.ForegroundColor `
            -BackgroundColor $this.ResolvedSettings.WriteOption[$validitySettingsName].Value.BackgroundColor
    }

    [void] WriteCountdown([string] $Message, [int] $Seconds, [int] $Indentation) {
        if (-not $Message) {
            $Message = $this.ResolvedSettings.WriteCountdown.Message.Text
        }
        if ($Seconds -lt 1) {
            $Seconds = $this.ResolvedSettings.WriteCountdown.Seconds.Amount
        }
        if ($Indentation -lt 0) {
            $Indentation = $this.ResolvedSettings.WriteCountdown.Indentation
        }

        foreach ($i in $Seconds..1) {
            Write-Host ("`r" + (' ' * $Indentation)) -NoNewline
            Write-Host $Message `
                -ForegroundColor $this.ResolvedSettings.WriteCountdown.Message.ForegroundColor `
                -BackgroundColor $this.ResolvedSettings.WriteCountdown.Message.BackgroundColor -NoNewline
            Write-Host $i.ToString().PadRight($Seconds.ToString().Length) `
                -ForegroundColor $this.ResolvedSettings.WriteCountdown.Seconds.ForegroundColor `
                -BackgroundColor $this.ResolvedSettings.WriteCountdown.Seconds.BackgroundColor -NoNewline
            Start-Sleep -Seconds 1
        }
    
        Write-Host ("`r" + ' ' * ($Indentation + $Message.Length + $Seconds.ToString().Length + 1) + "`r") -NoNewline
    }

}

$PSWriteUtils = [PSWriteUtils]::new()
Export-ModuleMember -Function * -Alias * -Variable 'PSWriteUtils'