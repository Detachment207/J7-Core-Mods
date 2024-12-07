"Starting script..." | Out-File "C:\Server Scripts\Status.log" -Append

$UpdateNeeded = 0
$PublishNeeded = 0

# Navigate to the repository directory
cd C:\J7\J7-Mods

# Get the git status output
$gitPath = "C:\Program Files\Git\bin\git.exe"
$UpdateNeeded = & $gitPath status

# Check if the output contains "Your branch is up to date"
if ($UpdateNeeded -like "*Your branch is up to date.*") {
    $UpdateNeeded = 0
} else {
    $UpdateNeeded = 1
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