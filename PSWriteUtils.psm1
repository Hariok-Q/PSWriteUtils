using namespace System.Text.RegularExpressions
using namespace System.Management.Automation

class PSWriteUtils {
    $Settings = @{
        FilesDefaults = @{
            Prefix = 'settings';
            Extension = 'json'
        };

        TextDefaults = @{
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
                    ForegroundColor = 'Default';
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
    hidden $AppliedSettings = @{}

    hidden static $ColorTagsRegex = [Regex]::new(
        '(?<Escape><)?(?<Total><: *(?<Foreground>\w*), *(?<Background>\w*) *>)',
        [RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase
    )
    hidden static $ColorSettingsRegex = [Regex]::new(
        '(?<Type>(?:(?:Fore)|(?:Back))ground)Color',
        [RegexOptions]::Compiled -bor [RegexOptions]::IgnoreCase
    )

    PSWriteUtils() {
        $this.ApplySettings()
    }

    PSWriteUtils([string]$SettingsFilePath) {
        $this.AppliedSettings = $this.CloneSettings()
        $this.LoadSettingsFile($SettingsFilePath)
        $this.ApplySettings()
    }

    PSWriteUtils([string]$SettingsDirectoryPath, [cultureinfo]$CultureInfo) {
        $this.AppliedSettings = $this.CloneSettings()
        $this.LoadSettingsDirectory($SettingsDirectoryPath, $CultureInfo)
        $this.ApplySettings()
    }

    hidden [hashtable] CloneSettings() {
        return [PSSerializer]::Deserialize([PSSerializer]::Serialize($this.Settings))
    }

    [void] ApplySettings() {
        $this.AppliedSettings = $this.CloneSettings()
        $this.RecursiveResolveSettingsColors($this.AppliedSettings)
        $Global:Host.UI.RawUI.ForegroundColor = $this.AppliedSettings.TextDefaults.ForegroundColor
        $Global:Host.UI.RawUI.BackgroundColor = $this.AppliedSettings.TextDefaults.BackgroundColor
    }

    [string] GetSettingsJson() {
        return (ConvertTo-Json -InputObject $this.Settings -Depth 32)
    }

    [void] LoadSettingsFile([string]$Path) {
        $this.RecursiveOverwriteSettings((Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable), $this.Settings)
    }

    [void] LoadLocaleSettingsFile([string]$SettingsDirectoryPath, [cultureinfo]$CultureInfo) {
        if(-not (Test-Path -LiteralPath $SettingsDirectoryPath)) {
            throw [ItemNotFoundException] "Could not find directory `"$SettingsDirectoryPath`"."
        }

        #     Tries to find the best match for the $CultureInfo name, going through each culture parent.
        #     Example: if $CultureInfo name is 'zh-Hans-HK', tries to find 'settings_zh-Hans-HK.json').
        # If it doesn't find it, tries to find the parent 'zh-Hans' as 'settings_zh-Hans.json'.
        # If it doesn't find it, tries to find the parent 'zh' as 'settings_zh.json'.
        $culture = $CultureInfo
        $settingsFileLocalizedSufix = $culture.Name
        while ($settingsFileLocalizedSufix) {
            $settingsFileLocalizedName = "$($this.AppliedSettings.FilesDefaults.Prefix)_${settingsFileLocalizedSufix}.$($this.AppliedSettings.FilesDefaults.Extension)"
            $settingsFileLocalizedFullname = Join-Path -Path $SettingsDirectoryPath -ChildPath $settingsFileLocalizedName

            if (Test-Path -LiteralPath $settingsFileLocalizedFullname) {
                $this.LoadSettingsFile($settingsFileLocalizedFullname)
                return
            }

            $culture = $culture.Parent
            $settingsFileLocalizedSufix = $culture.Name
        }

        #     If the exact $CultureInfo name or its parents weren't found, tries to find the first file
        # that shares a common parent.
        #     Example: if $CultureInfo name is 'zh-Hans-HK' and both it and its parents don't exist, but
        # 'zh-Hans-CN' exists, then it uses it because they share the common culture parent 'zh-Hans'.
        $culture = $CultureInfo.Parent
        $settingsFileLocalizedSufix = $culture.Name
        while ($settingsFileLocalizedSufix) {
            $settingsFileLocalizedName = "$($this.AppliedSettings.FilesDefaults.Prefix)_${settingsFileLocalizedSufix}-*.$($this.AppliedSettings.FilesDefaults.Extension)"
            $files = Get-ChildItem -LiteralPath $SettingsDirectoryPath -Filter $settingsFileLocalizedName

            if ($files) {
                $this.LoadSettingsFile($files[0].FullName)
                return
            }

            $culture = $culture.Parent
            $settingsFileLocalizedSufix = $culture.Name
        }

        throw [ItemNotFoundException] "Could not find any localized settings file compatible with `"$($CultureInfo.Name)`"."
    }

    [void] LoadSettingsDirectory([string]$SettingsDirectoryPath, [cultureinfo]$CultureInfo) {
        if (-not (Test-Path -LiteralPath $SettingsDirectoryPath)) {
            throw [ItemNotFoundException] "Could not find directory `"$SettingsDirectoryPath`"."
        }

        $foundAnyFile = $false
        $settingsPath = Join-Path -Path $SettingsDirectoryPath -ChildPath "$($this.AppliedSettings.FilesDefaults.Prefix).$($this.AppliedSettings.FilesDefaults.Extension)"
        if (Test-Path -LiteralPath $settingsPath) {
            $foundAnyFile = $true
            $this.LoadSettingsFile($settingsPath)
        }

        try {
            $this.LoadLocaleSettingsFile($SettingsDirectoryPath, $CultureInfo)
        }
        catch [ItemNotFoundException] {
            if (-not $foundAnyFile) {
                throw [ItemNotFoundException] "Could not find any compatible settings file in directory `"$SettingsDirectoryPath`"."
            }
        }
    }

    hidden [void] RecursiveOverwriteSettings([hashtable]$OriginSettingsNode, [hashtable]$DestinationSettingsNode) {
        foreach ($key in $OriginSettingsNode.Keys) {
            if ($DestinationSettingsNode.Keys -notcontains $key) { continue }
            if ($OriginSettingsNode[$key] -is [hashtable]) {
                $this.RecursiveOverwriteSettings($OriginSettingsNode[$key], $DestinationSettingsNode[$key])
                continue
            }

            $DestinationSettingsNode[$key] = $OriginSettingsNode[$key]
        }
    }

    hidden [void] RecursiveResolveSettingsColors([hashtable]$SettingsNode) {
        $keys = [array]$SettingsNode.Keys
        for ($i = 0; $i -lt $keys.Count; $i++) {
            $key = $keys[$i]
            $value = $SettingsNode[$key]

            if ($value -is [hashtable]) {
                $this.RecursiveResolveSettingsColors($value)
                continue
            }

            $regexMatch = [PSWriteUtils]::ColorSettingsRegex.Match($key)
            if (-not $regexMatch.Success) { continue }

            $SettingsNode[$key] = $this.ResolveSettingsColorName($value.ToString(), $regexMatch.Groups['Type'].Value)
        }
    }

    hidden [string] ResolveSettingsColorName([string]$ColorName, [string]$Type) {
        if (@('Foreground', 'Background') -notcontains $Type) {
            throw [System.Management.Automation.MethodException] "Invalid color Type `"$Type`". It must be `"Foreground`" or `"Background`"."
        }
        $AcceptedColors = @('Default') + [System.ConsoleColor].GetEnumNames()
        if ($AcceptedColors -notcontains $ColorName) {
            throw [System.Management.Automation.MethodException] "Invalid Color `"$ColorName`". It must be one of the following: Default, $($AcceptedColors -join ', ')."
        }

        if ($ColorName -eq 'Default') {
            if ($Type -eq 'Foreground') {
                if ($this.Settings.TextDefaults.ForegroundColor -eq 'Default') {
                    return $Global:Host.UI.RawUI.ForegroundColor
                }
                return $this.Settings.TextDefaults.ForegroundColor
            }
            else {    # $Type = 'Background'
                if ($this.Settings.TextDefaults.BackgroundColor -eq 'Default') {
                    return $Global:Host.UI.RawUI.BackgroundColor
                }
                return $this.Settings.TextDefaults.BackgroundColor
            }
        }

        Return $ColorName
    }





    [void] WriteColorTags([string] $Text, [bool] $NoNewLine) {
        $tagMatches = [PSWriteUtils]::ColorTagsRegex.Matches($Text)

        $position = 0
        $colors = @{
            'Foreground' = $this.AppliedSettings.TextDefaults.ForegroundColor;
            'Background' = $this.AppliedSettings.TextDefaults.BackgroundColor
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
                    $colors[$colorType] = $this.AppliedSettings.TextDefaults["${colorType}Color"]
                }
                else {
                    $colors[$colorType] = $tag.Groups[$colorType].Value
                }

                if ([System.ConsoleColor].GetEnumNames() -notcontains $colors[$colorType]) {
                    throw [System.Management.Automation.MethodException] "Invalid color name `"$($colors[$colorType])`" at index $($tag.Index): `"$($tag.Groups[0])`"."
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
            throw [System.Management.Automation.MethodException] "Invalid Type `"$Type`". It must be one of the following strings: `"Info`", `"Success`", `"Fail`"."
        }

        $padding = (@(
            $this.AppliedSettings.WriteStatus.Type.Info.Text.Length,
            $this.AppliedSettings.WriteStatus.Type.Success.Text.Length,
            $this.AppliedSettings.WriteStatus.Type.Fail.Text.Length
        ) | Measure-Object -Maximum).Maximum
        $Message = $Message.Trim()
        $Details = $Details.Trim()

        $typeString = $this.AppliedSettings.WriteStatus.Type[$Type].Text
        if ($Message) {
            $typeString = $typeString + ':'
            $padding++
            $Message = ' ' + $Message
        }
        $typeString = $typeString.PadRight($padding)

        Write-Host (' ' * $this.AppliedSettings.WriteStatus.Indentation) -NoNewline
        Write-Host $typeString `
            -ForegroundColor $this.AppliedSettings.WriteStatus.Type[$Type].ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteStatus.Type[$Type].BackgroundColor -NoNewline
        Write-Host $Message `
            -ForegroundColor $this.AppliedSettings.WriteStatus.Message.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteStatus.Message.BackgroundColor
        if ($Details) {
            foreach ($line in ($Details -split "\r?\n")) {
                Write-Host (' ' * $this.AppliedSettings.WriteStatus.Details.Indentation) -NoNewline
                Write-Host $line `
                    -ForegroundColor $this.AppliedSettings.WriteStatus.Details.ForegroundColor `
                    -BackgroundColor $this.AppliedSettings.WriteStatus.Details.BackgroundColor
            }
        }
    }

    [void] WriteOption([string] $Key, [string] $Name, [string] $CurrentValue, [bool] $IgnoreInvalid, [int] $Indentation) {
        $valid = $IgnoreInvalid -or ([bool] $CurrentValue)
        $validitySettingsName = 'Valid'
        if (-not $valid) {
            $validitySettingsName = 'Invalid'
            $CurrentValue = $this.AppliedSettings.WriteOption[$validitySettingsName].Value.Text
        }

        if ($Indentation -lt 0) {
            $Indentation = $this.AppliedSettings.WriteOption.Indentation
        }

        Write-Host (' ' * $Indentation) -NoNewline
        Write-Host '[' `
            -ForegroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].KeyBrackets.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].KeyBrackets.BackgroundColor -NoNewline
        Write-Host $Key `
            -ForegroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].Key.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].Key.BackgroundColor -NoNewline
        Write-Host ']' `
            -ForegroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].KeyBrackets.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].KeyBrackets.BackgroundColor -NoNewline
        Write-Host " $Name " `
            -ForegroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].General.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].General.BackgroundColor -NoNewline
        Write-Host $CurrentValue `
            -ForegroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].Value.ForegroundColor `
            -BackgroundColor $this.AppliedSettings.WriteOption[$validitySettingsName].Value.BackgroundColor
    }

    [void] WriteCountdown([string] $Message, [int] $Seconds, [int] $Indentation) {
        if (-not $Message) {
            $Message = $this.AppliedSettings.WriteCountdown.Message.Text
        }
        if ($Seconds -lt 1) {
            $Seconds = $this.AppliedSettings.WriteCountdown.Seconds.Amount
        }
        if ($Indentation -lt 0) {
            $Indentation = $this.AppliedSettings.WriteCountdown.Indentation
        }

        foreach ($i in $Seconds..1) {
            Write-Host ("`r" + (' ' * $Indentation)) -NoNewline
            Write-Host $Message `
                -ForegroundColor $this.AppliedSettings.WriteCountdown.Message.ForegroundColor `
                -BackgroundColor $this.AppliedSettings.WriteCountdown.Message.BackgroundColor -NoNewline
            Write-Host $i.ToString().PadRight($Seconds.ToString().Length) `
                -ForegroundColor $this.AppliedSettings.WriteCountdown.Seconds.ForegroundColor `
                -BackgroundColor $this.AppliedSettings.WriteCountdown.Seconds.BackgroundColor -NoNewline
            Start-Sleep -Seconds 1
        }
    
        Write-Host ("`r" + ' ' * ($Indentation + $Message.Length + $Seconds.ToString().Length + 1) + "`r") -NoNewline
    }
}







$SettingsDirectoryPath = Join-Path -Path $PSScriptRoot -ChildPath 'config'
if (Test-Path -LiteralPath $SettingsDirectoryPath) {
    $PSWriteUtils = [PSWriteUtils]::new((Join-Path -Path $PSScriptRoot -ChildPath 'config'), $Global:Host.CurrentCulture)
}
else {
    $PSWriteUtils = [PSWriteUtils]::new()
}




function Write-ColorTags {
    param(
        [string] $Text,
        [switch] $NoNewLine
    )

    $PSWriteUtils.WriteColorTags($Text, $NoNewLine)
}

function Write-Status {
    param(
        [Parameter(Mandatory)][ValidateSet('Info', 'Success', 'Fail')]
        [string] $Type,

        [string] $Message,

        [string] $Details
    )

    $PSWriteUtils.WriteStatus($Type, $Message, $Details)
}

function Write-Option {
    param(
        [Parameter(Mandatory)]
        [string] $Key,

        [Parameter(Mandatory)]
        [string] $Name,

        [string] $CurrentValue,

        [switch] $IgnoreInvalid,

        [int] $Indentation = 4
    )

    $PSWriteUtils.WriteOption($Key, $Name, $CurrentValue, $IgnoreInvalid, $Indentation)
}

function Write-Countdown {
    param(
        [string] $Message,
        [int] $Seconds = 5,
        [int] $Indentation
    )

    $PSWriteUtils.WriteCountdown($Message, $Seconds, $Indentation)
}




Export-ModuleMember -Function * -Alias * -Variable 'PSWriteUtils'