#!/bin/sh

##################################################
# FLAC file integrity tester                     #
# 2023-2024 - Marko Uibo                         #
# LICENSE: MIT                                   #
# THIS SCRIPT IS PROVIDED AS-IS WITHOUT ANY      #
# WARRANTY OF SUITABILITY! USE AT YOUR OWN RISK! #
##################################################

##################################################
# Constants
FLAC_TEST_V="27082024"      # Tool version

RED="\033[0;31m"            # Text color - red
GREEN="\033[0;32m"          # Text color - green
NC="\033[0m"                # No text color

##################################################
# Parameter check
if [ $# != 1 ]
    then printf "FLAC file testing tool V: $FLAC_TEST_V\n"
         printf "${RED}Missing arguments!${NC}\n"
         printf "Usage: flactest.sh <directory_containing_FLAC_files>\n"
         printf "Example: flactest.sh ./mnt/MyMusic\n"
         exit 1
fi

##################################################
# General setup

# First we need to know if we have FLAC
if ! [ -x "$(command -v flac)" ]
    then printf "FLAC file testing tool V: $FLAC_TEST_V\n"
         printf "${RED}ERROR: flac is not installed or is not in bin path${NC}\n"
         printf "Please install flac and/or add it to bin path.\n"
         exit 1
fi

FLAC_VER="$(flac -v)"             # Installed flac version
RUN_DATE="$(date +%I-%M-%d%m%Y)"  # Runtime date

##################################################
# LOG and TEMP file setup
LOGFILE="flactest-${RUN_DATE}.log"

# We need to be sure to have log file or we just waste time.
if ! touch $LOGFILE 2> /dev/null
    then printf "FLAC file testing tool V: $FLAC_TEST_V\n"
         printf "${RED}ERROR: Can't create LOG-file!${NC}\n"
         printf "It is recommended to check permissions of current working directory.\n"
         exit 1
fi

# TEMP-files creation should be robust!
TEMPFILE="$(mktemp)"    # This is for command output
FILELIST="$(mktemp)"    # This is for file list

# It is nice to have some counters.
FILES_TESTED=0        # Tested files counter
BAD_FILES_FOUND=0     # Bad files found

##################################################
# Cleanup and exit handling
trap "rm -f ${TEMPFILE} && rm -f ${FILELIST}" EXIT
trap "printf '\nAborted by user.\n'; printf 'LOG-file: $(realpath "$LOGFILE")\n'; exit 1" INT

##################################################
# Main script
printf "FLAC file testing tool V: ${FLAC_TEST_V}\n" | tee -a "$LOGFILE"
printf "Using ${FLAC_VER}\n" | tee -a "$LOGFILE"
printf "Searching files...\n"

# Is directory conainig files actually readable?
if ! [ -r $1 ]
    then printf "${RED}ERROR: Directory $1 can't be accessed!${NC}\n"
         printf "It is recommended to check permissions of directory containing FLAC files.\n"
         exit 1
fi

# We need a sorted list of flac files.
find "$1" -name "*.flac" | sort > $FILELIST
NUM_OF_FILES="$(cat $FILELIST | wc -l)"
printf "Number of files found: ${NUM_OF_FILES}\n" | tee -a "$LOGFILE"
printf "Faulty files appear in log file\n"
printf "Faulty files\n-------------------------------\n" >> $LOGFILE

# Testing logic
while read -r LINE
do
    FILENAME=$(echo "$LINE" | sed "s|$(dirname "$LINE")|...|")
    printf "Testing file: $FILENAME"
    flac -s -t -w "$LINE" > "$TEMPFILE" 2>&1
    if [ $? -eq "0" ]
        then printf "\r${GREEN}Testing file: $FILENAME OK${NC}\n"
        else printf "\r${RED}Testing file: $FILENAME FAIL${NC}\n";
             echo "$LINE" >> "$LOGFILE";
             cat "$TEMPFILE" >> "$LOGFILE"
             BAD_FILES_FOUND="$(expr ${BAD_FILES_FOUND} + 1 )"
    fi
    FILES_TESTED=$(expr ${FILES_TESTED} + 1)
done < $FILELIST

# Just for information
printf "LOG-file: $(realpath "$LOGFILE")\n"
printf "Files tested: ${FILES_TESTED}\n"
if [ ${BAD_FILES_FOUND} -gt 0 ]
    then printf "${RED}Bad files found:${NC} ${BAD_FILES_FOUND} ${RED}Please check log!${NC}\n"
fi
printf "Done!\n"
