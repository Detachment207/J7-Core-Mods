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

if ($PublishNeeded -eq 1) {
    "Publishing..." | Out-File "C:\Server Scripts\Status.log" -Append
    $PublishNeeded = 0

    $ArrayOfDirectories = Get-ChildItem -Path "C:\J7\J7-Mods" -Directory | Where-Object { $_.Name -ne 'Hashes' }
    $n = $ArrayOfDirectories.Count
    $i = 0

    Do {
        $currentDir = $ArrayOfDirectories[$i]
        $dirName = $currentDir.Name
        $fullPath = $currentDir.FullName

        #if ($dirName -like "*Large-Core-Mods*") {
        #    $fullPath = Join-Path $fullPath "AusSof"
        #    $dirName = "$dirName\AusSof"
        #}

        # Log directory being processed
        "Processing directory: $dirName" | Out-File "C:\Server Scripts\Status.log" -Append

        if ($UpdateStatus -like "*$dirName*") {
            "Matched directory: $dirName in UpdateStatus" | Out-File "C:\Server Scripts\Status.log" -Append

            $detailsFile = Join-Path $fullPath "Details.txt"
            if (-Not (Test-Path $detailsFile)) {
                "Details.txt not found in $fullPath, skipping..." | Out-File "C:\Server Scripts\Status.log" -Append
                $i++
                continue
            }

            $modID = Get-Content -Path $detailsFile
            "PublisherCmd update /id:$modID /changeNote:'Change Made by someone' /path:$fullPath /nologo /nosummary" | Out-File "C:\Server Scripts\Status.log" -Append

            $cmd = "C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\Publisher\PublisherCmd.exe"
            $cmdArgs = @("update", "/id:$modID", "/changeNote:'Change Made by someone'", "/path:$fullPath", "/nologo", "/nosummary")

            try {
                # Execute the Publisher command
                $cmdOutput = Start-Process -FilePath $cmd -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru
                $exitCode = $cmdOutput.ExitCode

                "PublisherCmd Exit Code for $dirName  $exitCode" | Out-File "C:\Server Scripts\PublisherCmdOutput.log" -Append

                if ($exitCode -ne 0) {
                    "Error: PublisherCmd failed for $dirName with exit code $exitCode" | Out-File "C:\Server Scripts\PublisherCmdOutput.log" -Append
                } else {
                    "Success: PublisherCmd executed successfully for $dirName" | Out-File "C:\Server Scripts\PublisherCmdOutput.log" -Append
                }
            } catch {
                "Exception while executing PublisherCmd for $dirName  $_" | Out-File "C:\Server Scripts\PublisherCmdOutput.log" -Append
            }
        } else {
            "Directory $dirName not found in UpdateStatus, skipping..." | Out-File "C:\Server Scripts\Status.log" -Append
        }

        $i++
    } While ($i -lt $n)
}
