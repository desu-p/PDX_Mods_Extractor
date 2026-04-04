# pdx_mods_extractor.ps1 - anime girl edition (｡♥‿♥｡)
add-type -assemblyname System.IO.Compression.FileSystem

try {
    $modPath = Get-Location
    $parentFolder = (Get-Item $modPath).Parent.Name
    $storagePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Mods\$parentFolder"
    
    # checking if we have a place for backups ヽ(♡ Infer ♡)ノ
    if (!(Test-Path $storagePath)) {
        New-Item -ItemType Directory -Path $storagePath -Force | Out-Null
    }

    $zipFiles = Get-ChildItem -Path $modPath -Filter "*.zip"
    $totalZips = $zipFiles.Count
    $currentZipCount = 0

    if ($totalZips -eq 0) { 
        write-host "err: no zips found! (╯°□°）╯︵ ┻━┻" -foregroundcolor red
        read-host "press enter to bail"; exit
    }

    foreach ($zip in $zipFiles) {
        $currentZipCount++
        $totalPercent = [Math]::Round(($currentZipCount / $totalZips) * 100)
        
        write-host "`n========================================" -foregroundcolor gray
        write-host "PROGRESS: $totalPercent% [$currentZipCount / $totalZips] ᕙ(`▽´)ᕗ" -foregroundcolor magenta
        write-host "working on: $($zip.Name)" -foregroundcolor white
        
        $startTime = Get-Date
        $tempDir = Join-Path $modPath "temp_$($zip.BaseName)"
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        # --- ULTRA FAST UNPACKING ⚡ ---
        write-host ">>> unpacking... (fast mode active) ヽ(>∀<☆)ノ" -foregroundcolor darkgray
        
        $unpackStart = Get-Date
        # no more sleeping, let's goooooooo! 🚀
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $tempDir)
        $unpackEnd = Get-Date
        $unpackDuration = ($unpackEnd - $unpackStart).TotalSeconds

        # searching for descriptor... hope it's there (・_・;)
        $descFile = Get-ChildItem -Path $tempDir -Filter "descriptor.mod" -Recurse -Depth 1 | Select-Object -First 1

        if ($descFile) {
            $modContentRoot = $descFile.Directory.FullName
            $content = [System.IO.File]::ReadAllText($descFile.FullName)
            
            $modName = if ($content -match 'name\s*=\s*"([^"]+)"') { $matches[1] } else { $zip.BaseName }
            $version = if ($content -match 'version\s*=\s*"([^"]+)"') { $matches[1] } else { "1.0" }
            $tags = if ($content -match 'tags\s*=\s*\{([^\}]+)\}') { $matches[1] } else { "" }
            
            $folderName = $modName -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_'
            $finalFolder = Join-Path $modPath $folderName

            if (Test-Path $finalFolder) { Remove-Item $finalFolder -Recurse -Force }
            New-Item -ItemType Directory -Path $finalFolder | Out-Null
            
            Move-Item "$modContentRoot\*" $finalFolder -Force

            $picFile = Get-ChildItem -Path $finalFolder -Include "*.png","*.jpg" | Select-Object -First 1
            $picLine = if ($picFile) { "`npicture=`"$($picFile.Name)`"" } else { "" }

            # --- GENERATING .MOD FILE ---
            $modFileContent = "version=`"$version`"`ntags={`n`t$tags`n}`nname=`"$modName`"`n$picLine`npath=`"mod/$folderName`""
            $finalModPath = Join-Path $modPath "$folderName.mod"
            [System.IO.File]::WriteAllText($finalModPath, $modFileContent, [System.Text.Encoding]::UTF8)

            Move-Item $zip.FullName $storagePath -Force
            
            write-host "DONE: $modName ($([Math]::Round($unpackDuration, 2))s) (^_<)b" -foregroundcolor green

            # --- EMOTIONAL ENGINE 3.0 ---
            if ($unpackDuration -gt 30) {
                write-host "`nsorry, i was trying to make it faster, sorry ＞︿＜" -foregroundcolor yellow
                $choice = read-host "will you hate my script? (y/n) {{{(>_<)}}}"
                if ($choice -eq 'y') {
                    write-host "my heart is broken... why do you so big meanie? (╥﹏╥)" -foregroundcolor red
                } elseif ($choice -eq 'n') {
                    write-host "phew, you are so kind! (´｡• ᵕ •｡`) ♡" -foregroundcolor cyan
                }
            } else {
                write-host "`nwow, that was fast! i'm on fire today! (๑˃ᴗ˂)ﻭ" -foregroundcolor cyan
                $starChoice = read-host "will you star me on github? (y/n) (^///^)"
                if ($starChoice -eq 'y') {
                    write-host "yippy!!!!!!!!!! thank uuuuuuu!!!! (^人^)" -foregroundcolor yellow
                } elseif ($starChoice -eq 'n') {
                    write-host "why? but okay... i'll still work good... （＞人＜；）" -foregroundcolor gray
                }
            }
        } else {
            write-host "skip: no descriptor found (・_・;)" -foregroundcolor yellow
        }

        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    }
} catch {
    write-host "fatal error: $_ (╥﹏╥)" -foregroundcolor red
}

write-host "`n--- MISSION COMPLETE! (★ω★) ---" -foregroundcolor magenta
read-host "press enter to close"
