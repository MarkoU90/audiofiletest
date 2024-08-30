#!/bin/sh

##################################################
# Wavpack file integrity tester                  #
# 2023-2024 - Marko Uibo                         #
# LICENSE: MIT                                   #
# THIS SCRIPT IS PROVIDED AS-IS WITHOUT ANY      #
# WARRANTY OF SUITABILITY! USE AT YOUR OWN RISK! #
##################################################

##################################################
# Constants
WAVPACK_TEST_V="27082024"   # Tool version

RED="\033[0;31m"            # Text color - red
GREEN="\033[0;32m"          # Text color - green
NC="\033[0m"                # No text color

##################################################
# Parameter check
if [ $# != 1 ]
    then printf "Wavpack file testing tool V: ${WAVPACK_TEST_V}\n"
         printf "${RED}Missing arguments!${NC}\n"
         printf "Usage: wavpacktest.sh <directory_containing_Wavpack_files>\n"
         printf "Example: wavpacktest.sh ./mnt/myMusic\n"
         exit 1
fi

##################################################
# General setup

# First we need to know if we have Wavpack
if ! [ -x "$(command -v wvunpack)" ]
    then printf "Wavpack file testing tool V: ${WAVPACK_TEST_V}\n";
         printf "${RED}ERROR: wavpack is not installed or is not in bin path${NC}\n"
         printf "Please install wavpack and/or add it to bin path.\n"
         exit 1
fi

WAVPACK_VER="$(wvunpack --version)"     # Installed wavpack version
RUN_DATE="$(date +%I-%M-%d%m%Y)"        # Runtime date

##################################################
# LOG and TEMP file setup
LOGFILE="wavpacktest-${RUN_DATE}.log"

# We need to be sure to have log file or we just waste time.
if ! touch $LOGFILE 2> /dev/null
    then printf "Wavpack file testing tool V: ${WAVPACK_TEST_V}\n"
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
trap "rm ${TEMPFILE} && rm ${FILELIST}" EXIT
trap "printf '\nAborted by user.\n'; printf 'LOG-file: $(realpath "$LOGFILE")\n'; exit 1" INT

##################################################
# Main script
printf "Wavpack file testing tool V: ${WAVPACK_TEST_V}\n" | tee -a "$LOGFILE"
printf "Using $WAVPACK_VER\n" | tee -a "$LOGFILE"
printf "Searching files...\n"

# Is directory conainig files actually readable?
if ! [ -r $1 ]
    then printf "${RED}ERROR: Directory $1 can't be accessed!${NC}\n";
         printf "It is recommended to check permissions of directory containing Wavpack files.\n"
         exit 1
fi

# We need a sorted list of wavpack files.
find "$1" -name "*.wv" | sort > $FILELIST
NUM_OF_FILES="$(cat $FILELIST | wc -l)"

printf "Number of files found: ${NUM_OF_FILES}\n" | tee -a "$LOGFILE"
printf "Faulty files appear in log file\n"
printf "Faulty files\n-------------------------------" >> $LOGFILE

# Testing logic
while read -r LINE
do
    FILENAME=$(echo "$LINE" | sed "s|$(dirname "$LINE")|...|")
    printf "Testing file: $FILENAME"
    wvunpack -v "$LINE" > $TEMPFILE 2>&1
    if [ $? -eq "0" ]
        then printf "\r${GREEN}Testing file: $FILENAME OK${NC}\n"
        else printf "\r${RED}Testing file: $FILENAME FAIL${NC}\n";
             echo "$LINE" >> "$LOGFILE";
             cat "$TEMPFILE" >> "$LOGFILE"
             BAD_FILES_FOUND="$(expr ${BAD_FILES_FOUND} + 1 )"
    fi
    FILES_TESTED="$(expr ${FILES_TESTED} + 1 )"
done < $FILELIST

# Just for information
printf "LOG-file: $(realpath "$LOGFILE")\n"
printf "Files tested: ${FILES_TESTED}\n"
if [ ${BAD_FILES_FOUND} -gt "0" ]
    then printf "${RED}Bad files found: ${BAD_FILES_FOUND} ${RED}Please check log!${NC}\n"
fi
printf "Done!\n"
