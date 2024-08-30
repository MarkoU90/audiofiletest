
# Audiofiletest

Audiofiletest is collection of scripts to verify integrity of FLAC and Wavpack audio files using codec inbuilt mechanisms. For FLAC files **flac -t** is used and for Wavpack files **wvunpack -v** is used.

FLAC and Wavpack files are tested separately by **flactest.sh** and **wavpacktest.sh**

### Requirements

- FLAC - https://xiph.org/flac/
- WwavPack - https://www.wavpack.com/

Audiofiletest scripts were tested on **BASH** and **DASH** shells.

### Installation

- Save **flactest.sh** and **wavpacktest.sh** to some convinient location.
- Run **chmod u+x** for both scripts to make them executable.

### Usage

There are two possible ways to invoke test scripts.

If scripts are installed to **/usr/bin** or other directory on bin search path, then they can be invoked directly as normal shell commands.

If scripts are placed somewhere else, then suitable path preffix must be used, for example **/home/user/myscripts/flactest.sh** or **./myscripts/wavpacktest.sh**

Both scripts take directory containing FLAC or Wavpack files as argument. For example **./flactest.hs /mnt/NAS/mymusic/**

Testing scripts need only **read** access to directory containing sound files. LOG files are created to current working directory. If LOG file can't be created, error is shown and script exits
without testing.


### Copyright

2023-2024 - Marko Uibo

LICENSE: **MIT**
