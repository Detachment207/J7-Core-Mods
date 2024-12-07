$excludeFile = "C:\J7\J7-Mods\Service-Scripts\ExcludeWhenSearchingForLastWriteTIme.txt"
$excludes = Get-Content -Path $excludeFile


$currentTime = Get-Date
$timeRange = $currentTime.AddMinutes(-9)

$rootDir = "C:\j7\J7-Mods"
$RecentlyModifiedItems = Get-ChildItem -Path $rootDir -File -Recurse | Where-Object {-not ($_.FullName -match ($excludes -join '|'))} | Select-Object FullName, LastWriteTime | Where-Object {$_.LastWriteTime -gt $timeRange}


$RecentlyModifiedItems | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name ModifiedRecently -Value ($_.LastWriteTime -gt $timeRange) | Get-Unique
}

$RecentlyModifiedItems | ForEach-Object {
    $A = $_.FullName.substring($rootDir.Length+1)
    $B = $A.Indexof("\")
    $_.Fullname = $A.substring(0,$B)
}

#$RecentlyModifiedItems | Format-Table FullName

$RecentlyModifiedItems | ForEach-Object {
    $ModName = $_.FullName
    $ModPath = "$rootDir\$ModName"

    # Check if the mod directory exists
    if (Test-Path -Path $ModPath) {
        # Check for details.txt and read Mod ID
        $DetailsFile = Join-Path -Path $ModPath -ChildPath "details.txt"
        if (Test-Path -Path $DetailsFile) {
            $ModID = Get-Content -Path $DetailsFile

            if ($ModID -ne "") {
                # Path to the PublisherCmd.exe
                $PublisherPath = "C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools\Publisher\PublisherCmd.EXE"

                # Construct the command
                $command = "& `'$PublisherPath`' update /id:`'$ModID`' /changeNote:`'change note`' /path:`'$ModPath`'"

                # Run the command
                Start-Process -FilePath "Powershell.exe" -ArgumentList "-Command $command" -Wait
                
            } else {
                Write-Host "No ModID found in $DetailsFile" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Details file not found: $DetailsFile" -ForegroundColor Red
        }
    } else {
        Write-Host "Directory not found: $ModPath" -ForegroundColor Red
    }
}
