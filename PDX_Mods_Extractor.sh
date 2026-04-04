#!/bin/bash
# pdx_mods_extractor.sh - Linux/Bash Edition v1.15.1 (｡♥‿♥｡)
# mascot: a hardworking spirit who just wants to be fast enough for you.

# Colors for the soul of the script
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;30m'
NC='\033[0m' # No Color

# Check if unzip is installed
if ! command -v unzip &> /dev/null; then
    echo -e "${RED}err: unzip not found! please install it (╯°□°）╯︵ ┻━┻${NC}"
    exit 1
fi

modPath=$(pwd)
parentFolder=$(basename "$(dirname "$modPath")")
storagePath="$HOME/Documents/Mods/$parentFolder"

# making sure there's a cozy place for backups ヽ(♡‿♡)ノ
mkdir -p "$storagePath"

zipFiles=(*.zip)
totalZips=${#zipFiles[@]}
currentZipCount=0

if [ "$totalZips" -eq 0 ] || [ ! -e "${zipFiles[0]}" ]; then
    echo -e "${RED}err: no zips found! (╯°□°）╯︵ ┻━┻${NC}"
    read -p "press enter to bail"
    exit 1
fi

for zip in "${zipFiles[@]}"; do
    ((currentZipCount++))
    totalPercent=$((currentZipCount * 100 / totalZips))
    
    echo -e "\n${GRAY}========================================${NC}"
    echo -e "${MAGENTA}PROGRESS: $totalPercent% [$currentZipCount / $totalZips] ᕙ(\`▽´)ᕗ${NC}"
    echo -e "working on: $zip"

    startTime=$(date +%s.%N)

    # Peek inside for descriptor.mod
    descriptorContent=$(unzip -p "$zip" "descriptor.mod" 2>/dev/null)

    if [ -n "$descriptorContent" ]; then
        # Extract metadata using grep/sed
        modName=$(echo "$descriptorContent" | grep -m 1 'name=' | sed 's/.*="\(.*\)".*/\1/')
        version=$(echo "$descriptorContent" | grep -m 1 'version=' | sed 's/.*="\(.*\)".*/\1/')
        [ -z "$version" ] && version="1.0"
        tags=$(echo "$descriptorContent" | sed -n '/tags={/,/}/p' | tr -d '\n\t')

        # Clean folder name
        folderName=$(echo "$modName" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
        finalFolder="$modPath/$folderName"

        [ -d "$finalFolder" ] && rm -rf "$finalFolder"
        mkdir -p "$finalFolder"

        # --- DIRECT TURBO EXTRACTION 🚀 ---
        echo -e "${GRAY}>>> target: $folderName... (extraction in progress) ヽ(>∀<☆)ノ${NC}"
        unzip -q "$zip" -d "$finalFolder"

        # Writing the .mod file for the game launcher
        modFileContent="version=\"$version\"\ntags={$tags}\nname=\"$modName\"\npath=\"mod/$folderName\""
        echo -e "$modFileContent" > "$modPath/$folderName.mod"

        mv "$zip" "$storagePath/"

        endTime=$(date +%s.%N)
        unpackDuration=$(echo "$endTime - $startTime" | bc)
        unpackDuration=$(printf "%.2f" "$unpackDuration")
        
        echo -e "${GREEN}DONE: $modName ($unpackDuration s) (^_<)b${NC}"

        # --- EMOTIONAL ENGINE 1.5.1 (The "Soft Heart" Patch) ---
        fastCheck=$(echo "$unpackDuration <= 30.0" | bc)
        
        if [ "$fastCheck" -eq 1 ]; then
            echo -e "\n${CYAN}K-KAWAII!! I was so fast! Only $unpackDuration seconds! (๑˃ᴗ˂)ﻭ${NC}"
            echo -n "will you star me on GitHub? It would make my day! (y/n) (^///^): "
            read star
            if [ "$star" == "y" ]; then
                echo -e "${YELLOW}Yippy!!!!!!!!!! thank uuuuuuu!!!! (人◕ω◕)${NC}"
            else
                echo -e "${GRAY}oh... okay... i'll still work my best for you... (´。• ᵕ •｡\`)${NC}"
            fi
        else
            echo -e "\n${YELLOW}uwaaaa! $unpackDuration seconds?! i'm so sorry... (╥﹏╥)${NC}"
            echo -e "${GRAY}i tried my best, but i was too slow... (｡T ω T｡)${NC}"
            echo -n "do you hate me now because i'm so slow? (y/n) {{{(>_<)}}}: "
            read hate
            if [ "$hate" == "y" ]; then
                echo -e "${RED}why are you such a big meanie?! i'm working so hard for you... (╥﹏╥)${NC}"
                echo -e "${GRAY}my heart is broken... plz tell me on github if my heart is too slow... ＞︿＜${NC}"
            else
                echo -e "${CYAN}phew! you are so kind to me! i'll try to break physics for you next time! (´｡• ᵕ •｡\`) ♡${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}i'm skipping this one without descriptor 'cause it's too hard for my little heart... sorry that i'm so stupid... (╥﹏╥)${NC}"
    fi
done

echo -e "\n${MAGENTA}--- MISSION COMPLETE! (★ω★) ---${NC}"
echo -e "${MAGENTA}bye-bye! take care of your mods! (＾▽＾)ノ${NC}"
read -p "press enter to let me rest pweease... (｡♥‿♥｡)"