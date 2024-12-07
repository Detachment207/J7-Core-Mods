"Starting script..." | Out-File "C:\Server Scripts\Status.log" -Append

$gitPath = "C:\Program Files\Git\bin\git.exe"

$UpdateNeeded = 0
$PublishNeeded = 0

cd C:\J7\J7-Mods
$UpdateNeeded = & $gitPath status

cd C:\J7\J7-Mods\Other-Core-Mods
$UpdateNeeded = $UpdateNeeded & $gitPath status

cd C:\J7\J7-Mods\Member-Core-Mods
$UpdateNeeded = $UpdateNeeded & $gitPath status

cd C:\J7\J7-Mods\Large-Core-Mods
$UpdateNeeded = $UpdateNeeded & $gitPath status

# Check if the output contains "Your branch is up to date"
if ($UpdateNeeded -like "*changes*") {
    $UpdateNeeded = 1
} else {
    $UpdateNeeded = 0
}

if ($UpdateNeeded -eq 1) {
    # Pull the latest changes from the repository
    $UpdateStatus = git pull origin main
    "UpdateStatus content: $UpdateStatus" | Out-File "C:\Server Scripts\Status.log" -Append

    # Check if the repository is already up to date
    if ($UpdateStatus -contains "Already up to date.") {
        "No updates needed after pull." | Out-File "C:\Server Scripts\Status.log" -Append
    } else {
        git pull origin main
        $UpdateNeeded = 0
        $PublishNeeded = 1
    }
}

$command = "C:\Server Scripts\RecentlyModifiedDirectoryFinder.ps1"

Start-Process -FilePath "Powershell.exe" -ArgumentList "-Command '$command'; pause" -Wait