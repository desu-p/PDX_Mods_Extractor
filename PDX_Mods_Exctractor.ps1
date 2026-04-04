# pdx_mods_extractor.ps1 - anime girl edition v1.15.1 (｡♥‿♥｡)
# mascot: a hardworking spirit who just wants to be fast enough for you.
# version: 1.15.1 - "The Soft Heart Patch"
add-type -assemblyname System.IO.Compression.FileSystem

try {
    $modPath = Get-Location
    $parentFolder = (Get-Item $modPath).Parent.Name
    $storagePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Mods\$parentFolder"
    
    # making sure there's a cozy place for backups ヽ(♡‿♡)ノ
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
        
        # Peek inside to find the descriptor - no time to waste! ⚡
        $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
        $descriptor = $zipArchive.Entries | Where-Object { $_.Name -eq "descriptor.mod" } | Select-Object -First 1

        if ($descriptor) {
            # Getting mod metadata directly from memory
            $reader = New-Object System.IO.StreamReader($descriptor.Open())
            $content = $reader.ReadToEnd()
            $reader.Close()
            $zipArchive.Dispose()

            $modName = if ($content -match 'name\s*=\s*"([^"]+)"') { $matches[1] } else { $zip.BaseName }
            $version = if ($content -match 'version\s*=\s*"([^"]+)"') { $matches[1] } else { "1.0" }
            $tags = if ($content -match 'tags\s*=\s*\{([^\}]+)\}') { $matches[1] } else { "" }
            
            $folderName = $modName -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_'
            $finalFolder = Join-Path $modPath $folderName

            if (Test-Path $finalFolder) { Remove-Item $finalFolder -Recurse -Force }
            
            # --- DIRECT TURBO EXTRACTION 🚀 ---
            write-host ">>> target: $folderName... (extraction in progress) ヽ(>∀<☆)ノ" -foregroundcolor darkgray
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zip.FullName, $finalFolder)
            
            # Writing the .mod file for the game launcher
            $modFileContent = "version=`"$version`"`ntags={`n`t$tags`n}`nname=`"$modName`"`npath=`"mod/$folderName`""
            $finalModPath = Join-Path $modPath "$folderName.mod"
            [System.IO.File]::WriteAllText($finalModPath, $modFileContent, [System.Text.Encoding]::UTF8)

            Move-Item $zip.FullName $storagePath -Force

            $unpackDuration = [Math]::Round(((Get-Date) - $startTime).TotalSeconds, 2)
            write-host "DONE: $modName ($unpackDuration s) (^_<)b" -foregroundcolor green

            # --- EMOTIONAL ENGINE 1.5.1 (The "Soft Heart" Patch) ---
            if ($unpackDuration -le 30) {
                write-host "`nK-KAWAII!! I was so fast! Only $unpackDuration seconds! (๑˃ᴗ˂)ﻭ" -foregroundcolor cyan
                $star = read-host "will you star me on GitHub? It would make my day! (y/n) (^///^)"
                
                if ($star -eq 'y') { 
                    write-host "Yippy!!!!!!!!!! thank uuuuuuu!!!! (人◕ω◕)" -foregroundcolor yellow 
                } else { 
                    write-host "oh... okay... i'll still work my best for you... (´。• ᵕ •｡`)" -foregroundcolor gray 
                }
            } 
            else {
                write-host "`nuwaaaa! $unpackDuration seconds?! i'm so sorry... (╥﹏╥)" -foregroundcolor yellow
                write-host "i tried my best, but i was too slow... (｡T ω T｡)" -foregroundcolor gray
                
                $hate = read-host "do you hate me now because i'm so slow? (y/n) {{{(>_<)}}}"
                
                if ($hate -eq 'y') { 
                    write-host "why are you such a big meanie?! i'm working so hard for you... (╥﹏╥)" -foregroundcolor red 
                    write-host "my heart is broken... plz tell me on github if my heart is too slow... ＞︿＜" -foregroundcolor gray
                } else { 
                    write-host "phew! you are so kind to me! i'll try to break physics for you next time! (´｡• ᵕ •｡`) ♡" -foregroundcolor cyan 
                }
            }

        } else {
            $zipArchive.Dispose()
            write-host "i'm skipping this one without descriptor 'cause it's too hard for my little heart... sorry that i'm so stupid... (╥﹏╥)" -foregroundcolor yellow
        }
    }
} catch {
    write-host "my logic is melting... i failed you... $_ (╥﹏╥)" -foregroundcolor red
}

write-host "`n--- MISSION COMPLETE! (★ω★) ---" -foregroundcolor magenta
write-host "bye-bye! take care of your mods! (＾▽＾)ノ" -foregroundcolor magenta
read-host "press enter to let me rest pweease... (｡♥‿♥｡)"; exit