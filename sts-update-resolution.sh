#!/bin/bash

# I made this because I like playing Slay the Spire on the Steam Deck,
# and the game really, REALLY doesn't play nice if you use
# differing resolutions on the same device (e.g docked and undocked).
# Especially if the set res is higher than the display's.

#  Copyright 2024 Caleb Padron
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Check for both primary and SD card installs
CONFIGFILE=/home/deck/.local/share/Steam/steamapps/common/SlayTheSpire/info.displayconfig
if ! [[ -e $CONFIGFILE ]]; then
	CONFIGFILE=/run/media/mmcblk0p1/steamapps/common/SlayTheSpire/info.displayconfig
fi

# Check if file doesn't exist or can't read/write to it
[[ -e $CONFIGFILE && -r $CONFIGFILE && -w $CONFIGFILE ]] || exit 1

# Get display resolution
RES=$(xdpyinfo | grep -oP 'dimensions:\s+\K\S+')

# Separate width and height
WIDTH=$(echo "$RES" | sed 's/x.*//')
HEIGHT=$(echo "$RES" | sed 's/.*x//')

# The smallest possible resolution, according to the game
MIN_W="1024"
MIN_H="576"

# Make sure nothing is horribly wrong and W/H are actual resolution numbers
ISNUMBER='^[0-9]+$'
if ! [[ $WIDTH =~ $ISNUMBER && $HEIGHT =~ $ISNUMBER && $WIDTH -ge $MIN_W && $HEIGHT -ge $MIN_H ]]; then
	exit 2
fi

# Used to skip editing file if last resolution set is correct
CUR_W=$(sed -n '1s/\s.*//p' "$CONFIGFILE")
CUR_H=$(sed -n '2s/\s.*//p' "$CONFIGFILE")
# As a side note,
# With the utmost sincerity from the deepest regions of my heart,
# SCREW Microsoft's pointless and idiotic newline format.

# Final sanity check
# Don't mess with the config file if something smells fishy
# In case the config format has changed from an update or otherwise
if ! [[ $CUR_W =~ $ISNUMBER && $CUR_H =~ $ISNUMBER && $CUR_W -ge $MIN_W && $CUR_H -ge $MIN_H ]]; then
	exit 3
fi

# Only update config if resolution has changed
if [[ $WIDTH && $HEIGHT && $WIDTH != "$CUR_W" && $HEIGHT != "$CUR_H" ]]; then
	echo "Changing resolution to $WIDTH""x""$HEIGHT"
	sed -i '1s/'"$CUR_W"'/'"$WIDTH"'/m' $CONFIGFILE
	sed -i '2s/'"$CUR_H"'/'"$HEIGHT"'/m' $CONFIGFILE
fi
