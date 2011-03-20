#!/bin/bash
# ------------------------------------------
# Created by wdl1908 on 12/03/2011
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# V0.1 Initial version
# ------------------------------------------
set +x # do not print executed commands and arguments (set -x will show all commands - useful for debugging)

exec 2>&1

DIR="`dirname $0`"

if [ "$DIR" = "." ] ; then
	DIR="`pwd`"
fi

DIR_MOD="$DIR/framework-res-MOD"

checkenv() {
	echo -n "Checking environment..."
	# Create all dirs
	if [ ! -d "$DIR_MOD" ] ; then           mkdir -p "$DIR_MOD"; fi
	echo "Done."
}

cleanenv() {
	echo -n "Clearing environment..."
	# Better safe than sorry test if dir exists before removing.
	if [ -d "$DIR_MOD" ] ; then                   rm -rf "$DIR_MOD";   mkdir -p "$DIR_MOD"; fi
	echo "Done."
}

makebasedirs() {
	echo -n "Making base drawable dirs..."
	mkdir -p "$DIR_MOD"/res/drawable
	mkdir -p "$DIR_MOD"/res/drawable-hdpi
	mkdir -p "$DIR_MOD"/res/drawable-mdpi
	echo "Done."
}

checkenv
cleanenv
makebasedirs

