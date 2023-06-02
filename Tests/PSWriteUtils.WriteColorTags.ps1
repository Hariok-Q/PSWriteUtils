using module '..\PSWriteUtils.psm1'

$WrUt = [PSWriteUtils]::new()
$WrUt.WriteColorTags(@"
    <:BLACK, WHITE > Write-ColorTags: Lorem ipsum <:Gray,>
Lorem ipsum dolor sit amet,
<:green,>consectetur adipiscing elit,
sed do eiusmod tempor <:green, blue>incididunt ut labore et dolore magna aliqua.
Dui accumsan sit amet nulla facilisi.
Egestas egestas fringilla phasellus<:default, DEFAULT>
faucibus scelerisque <:yellow, default>eleifend donec pretium.<:, yellow>
Pulvinar pellentesque habitant morbi tristique senectus.
Feugiat pretium nibh <:,>ipsum consequat nisl vel pretium lectus.
Eget nunc scelerisque<:,> viverra mauris in aliquam sem.
Quam viverra orci <<:red, white> sagittis eu volutpat odio facilisis mauris sit.
Diam sollicitudin <:red, white>tempor id eu nisl nunc mi ipsum faucibus. <:>
Sit amet risus nullam eget. <:,>
Consequat nisl vel pretium lectus quam id leo.
Purus sit amet luctus venenatis lectus magna fringilla urna porttitor.
Amet purus gravida quis blandit turpis cursus in.
Lacus viverra vitae congue eu consequat ac felis donec.
Proin libero nunc consequat interdum varius sit.
Orci phasellus egestas tellus rutrum tellus pellentesque eu tincidunt. A iaculis at erat pellentesque.
Viverra ipsum nunc aliquet bibendum enim facilisis gravida neque.
"@, $false)

Write-Host ''
$WrUt.WriteColorTags("    <:black, white> Write-ColorTags: Single line <:,>", $false)
$WrUt.WriteColorTags("We'll go to <:RED, Blue>United Kingdom<:,>, <:Green, yeLlOw>Brazil<:default, default> and <:BLUE, whITE>Argentina<:,>.", $false)
$WrUt.WriteColorTags("You can try escaping <<:red, white> tags like this <<:,>.", $false)

Write-Host ''
$WrUt.WriteColorTags("    <:  BLACk,white     > Write-ColorTags: NoNewLine <:,>", $false)
$WrUt.WriteColorTags("<:red,yellow>Line 1<:,> / ", $true)
$WrUt.WriteColorTags("<:blue,GREEN>Line 2<:,>", $true)
Write-Host ''