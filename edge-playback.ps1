Param( [string]$InputText, [string]$InputFilePath )

Clear-Host

# Define the text
$AllVoices = edge-tts --list-voices
# Split the text into individual lines
$lines = $AllVoices -split "`r`n"
# Initialize an empty array to store the names
$MatchedVoices = @()

# Define the array of strings to exclude
$ExcludedVoices = @('en-US-AnaNeural', 'en-GB-MaisieNeural')

# Loop through each line and check if it starts with "Name: en-"
foreach ($line in $lines) {
    if ($line -match "^Name: en-(us|gb|au|ca|nz)") {
        # Extract the name and add it to the array
        $name = $line -replace "Name: ", ""
        $MatchedVoices += $name
    }
}

# Remove the excluded voices from the array
$MatchedVoices = $MatchedVoices | Where-Object { $_ -notin $ExcludedVoices }

# Pick a random name from the array
$RandomVoice = $MatchedVoices | Get-Random
# Display the random name
$RandomVoice
Write-Host

if ($InputText) {
    $text = [uri]::UnescapeDataString($InputText)
    $text = $text.replace('edge-tts:', '')
}
elseif ($InputFilePath) {
    $FilePath = $InputFilePath
    $text = Get-Content -Path $FilePath
}
else {
    $FilePath = "$($PSScriptRoot)\edge-playback.txt"
    $text = Get-Content -Path $FilePath
}

$text = $text -replace '“|”', '"'
$text = $text -replace "’", "'"


Write-Host $text
Write-Host
$text = [string]::join(". ", ($text.Split("`n")))

# edge-playback --rate=+10% --voice $RandomVoice --text $text
Set-Location -Path $PSScriptRoot
edge-tts --rate=+10% --voice $RandomVoice --text $text --write-media edge-playback.mp3 --write-subtitles edge-playback.vtt
mpv edge-playback.mp3 --profile=edge-playback --load-auto-profiles=no --load-scripts=no
Remove-Item edge-playback.mp3
Remove-Item edge-playback.vtt