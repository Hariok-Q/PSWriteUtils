#region DEFAULT VARIABLE DEFINITIONS

#region Default Colors
$DefaultForegroundColor = (Get-Host).UI.RawUI.ForegroundColor
$DefaultBackgroundColor = (Get-Host).UI.RawUI.BackgroundColor
#endregion

#region Write-Status
$StatusMessageForegroundColor = 'White'
$StatusDetailsForegroundColor = $defaultForegroundColor
$StatusBackgroundColor = 'Black'

$StatusInfoText = 'INFO'
$StatusInfoForegroundColor = 'Blue'

$StatusSuccessText = 'SUCESSO'
$StatusSuccessForegroundColor = 'Green'

$StatusFailText = 'FALHA'
$StatusFailForegroundColor = 'Red'
#endregion


#region Write-Option
$ValidOptionKeyColor = 'Yellow'
$ValidOptionNameColor = $defaultForegroundColor
$ValidOptionValueColor = $defaultForegroundColor

$InvalidOptionKeyColor = 'Red'
$InvalidOptionNameColor = $defaultForegroundColor
$InvalidOptionValueText = '<INVÁLIDO>'
$InvalidOptionValueColor = 'DarkGray'
#endregion


#region Write-Countdown
$CountdownMessageForegroundColor = 'White'
$CountdownSecondsForegroundColor = 'Cyan'
#endregion

#endregion

class WriteUtils {
    $Settings = [PSCustomObject]@{
        ConsoleDefault = [PSCustomObject]@{
            ForegroundColor = 'Gray';
            BackgroundColor = 'Black'
        };

        WriteOption = [PSCustomObject]@{
            Indentation = 0;
            Valid = [PSCustomObject]@{
                General = [PSCustomObject]@{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Black'
                };
                Key = [PSCustomObject]@{
                    ForegroundColor = 'Yellow';
                    BackgroundColor = 'Black'
                };
                KeyBrackets = [PSCustomObject]@{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Black'
                };
                Value = [PSCustomObject]@{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Black'
                }
            };
            Invalid = [PSCustomObject]@{
                General = [PSCustomObject]@{
                    ForegroundColor = 'DarkGray';
                    BackgroundColor = 'Black'
                };
                Key = [PSCustomObject]@{
                    ForegroundColor = 'Red';
                    BackgroundColor = 'Black'
                };
                KeyBrackets = [PSCustomObject]@{
                    ForegroundColor = 'Gray';
                    BackgroundColor = 'Black'
                };
                Value = [PSCustomObject]@{
                    ForegroundColor = 'DarkGray';
                    BackgroundColor = 'Black';
                    Text = '<INVALID>'
                }
            }
        };

        WriteStatus = [PSCustomObject]@{
            Indentation = 0;
            Message = [PSCustomObject]@{
                ForegroundColor = 'White';
                BackgroundColor = 'Black'
            };
            Type = [PSCustomObject]@{
                Info = [PSCustomObject]@{
                    Text = 'INFO';
                    ForegroundColor = 'Blue';
                    BackgroundColor = 'Black'
                };
                Success = [PSCustomObject]@{
                    Text = 'SUCCESS';
                    ForegroundColor = 'Green';
                    BackgroundColor = 'Black'
                };
                Fail = [PSCustomObject]@{
                    Text = 'FAIL';
                    ForegroundColor = 'Red';
                    BackgroundColor = 'Black'
                }
            };
            Details = [PSCustomObject]@{
                Indentation = 4;
                ForegroundColor = 'Gray';
                BackgroundColor = 'Black'
            }
        };

        WriteCountdown = [PSCustomObject]@{
            Indentation = 0;
            Message = [PSCustomObject]@{
                Text = 'Waiting... ';
                ForegroundColor = 'White';
                BackgroundColor = 'Black'
            };
            Seconds = [PSCustomObject]@{
                ForegroundColor = 'Cyan';
                BackgroundColor = 'Black'
            }
        }
    }

    WriteUtils() {
    }
}



function Write-ColorTags {
    Param(
        [string] $Text,
        [switch] $NoNewLine
    )

    $tokenPattern = '(?<escape><)?(?<total><: *(?<foreground>\w*), *(?<background>\w*) *>)'

    $tags = (Select-String -InputObject $Text -Pattern $tokenPattern -AllMatches).Matches

    $position = 0
    $foregroundColor = $DefaultForegroundColor
    $backgroundColor = $DefaultBackgroundColor
    foreach ($tag in $tags) {
        Write-Host $Text.Substring($position, $tag.Index - $position) -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline

        if ($tag.Groups['escape'].Value) {
            Write-Host $tag.Groups['total'].Value -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline
        }

        $position = $tag.Index + $tag.Length

        if ((-not $tag.Groups['foreground'].Value) -or ($tag.Groups['foreground'].Value.ToUpper() -eq 'DEFAULT')) {
            $foregroundColor = $DefaultForegroundColor
        }
        else {
            $foregroundColor = $tag.Groups['foreground'].Value
        }

        if ((-not $tag.Groups['background'].Value) -or ($tag.Groups['background'].Value.ToUpper() -eq 'DEFAULT')) {
            $backgroundColor = $DefaultBackgroundColor
        }
        else {
            $backgroundColor = $tag.Groups['background'].Value
        }
    }
    Write-Host $Text.Substring($position, $Text.Length - $position) -ForegroundColor $foregroundColor -BackgroundColor $backgroundColor -NoNewline:$NoNewLine
}

function Write-Status {
    param(
        [Parameter(Mandatory)][ValidateSet('Info', 'Success', 'Fail')]
        [string] $Type,

        [string] $Message,

        [string] $Details
    )

    $padding = (@($StatusInfoText.Length, $StatusSuccessText.Length, $StatusFailText.Length) | Measure-Object -Maximum).Maximum
    $typeString = ''
    $color = ''
    switch ($Type) {
        'Info' {
            $typeString = $StatusInfoText
            $color = $StatusInfoForegroundColor
            Break
        }

        'Success' {
            $typeString = $StatusSuccessText
            $color = $StatusSuccessForegroundColor
            Break
        }

        'Fail' {
            $typeString = $StatusFailText
            $color = $StatusFailForegroundColor
            Break
        }
    }

    if ($Message) {
        $typeString = $typeString + ':'
        $padding++
        $messageString = ' ' + $Message.Trim()
    }
    $typeString = $typeString.PadRight($padding)

    Write-Host $typeString -ForegroundColor $color -BackgroundColor $StatusBackgroundColor -NoNewline
    Write-Host $messageString -ForegroundColor $StatusMessageForegroundColor -BackgroundColor $StatusBackgroundColor
    if ($Details) {
        foreach ($line in ($Details -split "\r?\n")) {
            Write-Host (' '*4 + $line) -ForegroundColor $StatusDetailsForegroundColor
        }
    }
}

function Write-Option {
    param(
        [Parameter(Mandatory)]
        [string] $Key,

        [Parameter(Mandatory)]
        [string] $Name,

        [string] $CurrentValue,

        [int] $Indentation = 4,

        [switch] $IgnoreInvalid
    )

    $valid = $IgnoreInvalid -or ([bool] $CurrentValue)

    if (-not $valid) {
        $keyColor = $InvalidOptionKeyColor
        $nameColor = $InvalidOptionNameColor
        $CurrentValue = $InvalidOptionValueText
        $currentValueColor = $InvalidOptionValueColor
    }
    else {
        $keyColor = $ValidOptionKeyColor
        $nameColor = $ValidOptionNameColor
        $currentValueColor = $ValidOptionValueColor
    }
    Write-Host (' ' * $Indentation + '[') -ForegroundColor $nameColor -NoNewline
    Write-Host $Key -ForegroundColor $keyColor -NoNewline
    Write-Host "] $Name" -ForegroundColor $nameColor -NoNewline
    Write-Host $CurrentValue -ForegroundColor $currentValueColor
}

function Write-Countdown {
    Param(
        [int] $Seconds = 5,
        [string] $Message
    )

    if ($Message) {
        $Message = $Message + ' '
    }

    foreach ($i in $Seconds..1) {
        Write-Host "`r$Message" -ForegroundColor $CountdownMessageForegroundColor -NoNewline
        Write-Host $i.ToString().PadRight($Seconds.ToString().Length) -ForegroundColor $CountdownSecondsForegroundColor -NoNewline
        Start-Sleep -Seconds 1
    }

    Write-Host ("`r" + ' ' * ($Message.Length + $Seconds.ToString().Length + 1) + "`r") -NoNewline
}

