#!/bin/bash
# ------------------------------------------
# Created by wdl1908 on 10/03/2011
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
# V0.1a BUGFIX cp dirs
# V0.2 MOD Analysis, Compile fail detection
# ------------------------------------------
set +x # do not print executed commands and arguments (set -x will show all commands - useful for debugging)

exec 2>&1

DIR="`dirname $0`"

if [ "$DIR" = "." ] ; then
	DIR="`pwd`"
fi

DIR_tools="$DIR/tools"
DIR_MOD="$DIR/framework-res-MOD"
DIR_MODDED="$DIR/framework-res-MODDED"
DIR_STOCK="$DIR/framework-res-STOCK"
DIR_WORKSPACE="$DIR/WorkSpace"
DIR_UNPACKED="$DIR/WorkSpace/framework-res-UNPACKED"
DIR_COMPILED="$DIR/WorkSpace/framework-res-COMPILED"
DIR_DECOMPILED="$DIR/WorkSpace/framework-res-DECOMPILED"
LOGFILE="$DIR_WORKSPACE/log.txt"
FILESTOREMOVE="$DIR_WORKSPACE/files-to-remove.txt"
FILESINCOMPILED="$DIR_WORKSPACE/files-in-compiled.txt"
export PATH="$DIR_tools":$PATH

showerror() {
	echo ""; echo ""
	echo "   $1"
	echo ""
	exit 1
}

checkenv() {
	echo -n "Checking environment..."
	# Create all dirs
	if [ ! -d "$DIR_tools" ] ; then         mkdir -p "$DIR_tools"; fi
	if [ ! -d "$DIR_MOD" ] ; then           mkdir -p "$DIR_MOD"; fi
	if [ ! -d "$DIR_MODDED" ] ; then        mkdir -p "$DIR_MODDED"; fi
	if [ ! -d "$DIR_STOCK" ] ; then         mkdir -p "$DIR_STOCK"; fi
	if [ ! -d "$DIR_UNPACKED" ] ; then      mkdir -p "$DIR_UNPACKED"; fi
	if [ ! -d "$DIR_COMPILED" ] ; then      mkdir -p "$DIR_COMPILED"; fi
	if [ ! -d "$DIR_DECOMPILED" ] ; then    mkdir -p "$DIR_DECOMPILED"; fi
	echo "Done."
}

cleanenv() {
	echo -n "Clearing environment..."
	# Better safe than sorry test if dir exists before removing.
	if [ -d "$DIR_UNPACKED" ] ; then      rm -rf "$DIR_UNPACKED";   mkdir -p "$DIR_UNPACKED"; fi
	if [ -d "$DIR_COMPILED" ] ; then      rm -rf "$DIR_COMPILED";   mkdir -p "$DIR_COMPILED"; fi
	if [ -d "$DIR_DECOMPILED" ] ; then    rm -rf "$DIR_DECOMPILED"; mkdir -p "$DIR_DECOMPILED"; fi
	if [ -f "$LOGFILE" ] ; then           rm -f "$LOGFILE"; fi
	if [ -f "$FILESTOREMOVE" ] ; then     rm -f "$FILESTOREMOVE"; fi
	if [ -f "$FILESINCOMPILED" ] ; then   rm -f "$FILESINCOMPILED"; fi
	rm -f "$DIR_MODDED/framework-res.apk"
	rm -f "$DIR_WORKSPACE/"*-files.txt
	echo "Done."
}

download() {
	URL="$1"
	FILENAME="`basename "$1"`"
	TARNAME="`basename $FILENAME .bz2`"
	echo -n "   Downloading $FILENAME..."
	wget "$URL"  > /dev/null 2>&1
	if [ ! -f "$FILENAME" ] ; then echo "FAILED to download $URL"; exit; fi
	echo -n "Unpacking..."
	bunzip2 "$FILENAME"
	tar xf "$TARNAME"
	rm "$TARNAME"
	echo "Done."
}

checktools() {
	echo -n "Checking apktools..."
	if [ ! -f "$DIR_tools/apktool" ] ; then
		echo "NOT FOUND."
		cd "$DIR_tools"
		download "http://android-apktool.googlecode.com/files/apktool1.3.2.tar.bz2"
		download "http://android-apktool.googlecode.com/files/apktool-install-linux-2.2_r01-1.tar.bz2"
		cd "$DIR"
	else
		echo "Done."
	fi
}

checkprograms() {
	echo -n "Checking programs..."
	for PROGRAM in java 7za wget bunzip2
	do
		if [ ! -f "`which "$PROGRAM"`" ] ; then
			showerror "FAILED: '$PROGRAM' is missing or is not in your PATH!"
		fi
	done
	echo "Done."
}

unpackframework() {
	echo -n "Unpacking framework-res.apk..."
	if [ -f "$DIR_STOCK/framework-res.apk" ] ; then
		7za x -o"$DIR_UNPACKED" "$DIR_STOCK/framework-res.apk" >> "$LOGFILE"
		echo "Done."
	else
		showerror "FAILED: framework-res.apk not found in directory framework-res-STOCK"
	fi
}

decompileframework() {
	echo -n "Uncompiling framework-res.apk..."
	if [ -f "$DIR_STOCK/framework-res.apk" ] ; then
		echo ""
		java -jar "$DIR_tools/apktool.jar" d -f "$DIR_STOCK/framework-res.apk" "$DIR_DECOMPILED" >> "$LOGFILE"
		echo "Done."
	else
		showerror "FAILED: framework-res.apk not found in directory framework-res-STOCK"
	fi
}

printyesno() {
	VAR=$1
	NR=$2
	WARNING=$3
	if [ "$NR" = "0" ] ; then
		echo "[NO]"
		export $VAR=0
	else
		echo "[YES] ($NR) $WARNING"
		export $VAR=1
	fi
}

printtypes() {
	FILE=$1
	VAR=$2
	EXT=$3
	WARNING=$4
	echo -n "   MOD contains '$EXT' files: "
	cat "$FILE" | grep -E "\.$EXT" | sed 's/\.\/.*\///g' | sed 's/\.'$EXT'//' > "$DIR_WORKSPACE/"$VAR-$EXT-files.txt
	NR=`cat "$DIR_WORKSPACE/"$VAR-$EXT-files.txt | wc -l`
	printyesno $VAR $NR "$WARNING"
}

analyzemod() {
	echo "Analizing MOD..."
	cd "$DIR_MOD"
	find . -type f > "$FILESTOREMOVE"
	printtypes "$FILESTOREMOVE" "PNGEXIST" "png"
	printtypes "$FILESTOREMOVE" "XMLEXIST" "xml" "Need to recompile"
	printtypes "$FILESTOREMOVE" "PNG9EXIST" "9.png" "I hope you did your homework (See Patch9)"
	grep -x -f "$DIR_WORKSPACE/XMLEXIST-xml-files.txt" "$DIR_WORKSPACE/PNGEXIST-png-files.txt" > "$DIR_WORKSPACE/xml-png-samename-files.txt"
	echo -n "   MOD contains 'png', 'xml' files with same name: "
	printyesno "PNGXMLEXIST" `cat "$DIR_WORKSPACE/xml-png-samename-files.txt" | wc -l` "BAD (some of the animations may not work)"
	cd "$DIR"
}

analyzedecompiled() {
	echo "Analizing COMPILED..."
	cd "$DIR_DECOMPILED"
	find ./res/drawable* -type f > "$FILESINCOMPILED"
	printtypes "$FILESINCOMPILED" "PNGCOMPILEDEXIST" "png"
	printtypes "$FILESINCOMPILED" "XMLCOMPILEDEXIST" "xml"
	grep -x -f "$DIR_WORKSPACE/XMLCOMPILEDEXIST-xml-files.txt" "$DIR_WORKSPACE/PNGCOMPILEDEXIST-png-files.txt" > "$DIR_WORKSPACE/DECOMPILED-xml-png-samename-files.txt"
	echo -n "   MOD contains 'png', 'xml' files with same name: "
	printyesno "PNGXMLCOMPILEDEXIST" `cat "$DIR_WORKSPACE/DECOMPILED-xml-png-samename-files.txt" | wc -l` "BAD (some of the animations may not work)"
	if [ $PNGXMLCOMPILEDEXIST = "1" ] ; then
		echo -n "Found duplicate xml png files trying to fix..."
		grep -E ".png" "$FILESINCOMPILED" | grep -w -f "$DIR_WORKSPACE/DECOMPILED-xml-png-samename-files.txt" > "$DIR_WORKSPACE/duplicate-png-files.txt"
		cat "$DIR_WORKSPACE/duplicate-png-files.txt" | xargs -n 1 rm -f >> "$LOGFILE"
		NR=`cat "$DIR_WORKSPACE/duplicate-png-files.txt" | wc -l`
		echo "Removed ($NR) Done."
	fi
	cd "$DIR"
}

applymod() {
	echo -n "Applying MOD..."
	cp -rf "$DIR_MOD"/* "$DIR_DECOMPILED"
	echo "Done."
}

copymod() {
	echo -n "Applying MOD..."
	cp -rf "$DIR_MOD"/* "$DIR_COMPILED"
	echo "Done."
}

compileframework() {
	echo "Compiling framework-res.apk..."
	java -jar "$DIR_tools/apktool.jar" b "$DIR_DECOMPILED" "$DIR_MODDED/framework-res-compiled.apk" >> "$LOGFILE" 2>&1
	if [ ! -f "$DIR_MODDED/framework-res-compiled.apk" ] ; then
		showerror "COMPILE FAILED: framework-res.apk not found in directory framework-res-MODDED"
	else
		echo "Done."
	fi
}

unpackcompiled() {
	echo -n "Unpacking compiled framework-res.apk..."
	7za x -o"$DIR_COMPILED" "$DIR_MODDED/framework-res-compiled.apk" >> "$LOGFILE"
	rm -f "$DIR_MODDED/framework-res-compiled.apk"
	echo "Done."
}

copyunmodifiedfiles() {
	echo -n "Copy files from UNPACKED to COMPILED that are not modified..."
	cd "$DIR_MOD"
	find . -type f > "$FILESTOREMOVE"
	cd "$DIR_UNPACKED"
	cat "$FILESTOREMOVE" | xargs -n 1 rm -f >> "$LOGFILE"
	rm -f resources.arsc
	cp -vr "$DIR_UNPACKED"/* "$DIR_COMPILED" >> "$LOGFILE"
	cd "$DIR_COMPILED"
	cat "$DIR_WORKSPACE/duplicate-png-files.txt" | xargs -n 1 rm -f >> "$LOGFILE"
	cd "$DIR"
	echo "Done."
}

repackagecompiled() {
	echo -n "Repackaging COMPILED to framework-res.apk..."
	cd "$DIR_COMPILED"
	7za a -tzip "$DIR_MODDED/framework-res.apk" * -mx9 >> "$LOGFILE"
	7za d -tzip "$DIR_MODDED/framework-res.apk" resources.arsc >> "$LOGFILE"
	7za u -tzip "$DIR_MODDED/framework-res.apk" resources.arsc -mx0 >> "$LOGFILE"
	cd "$DIR"
	echo "Done."
}

copyframework() {
	echo -n "Copy UNPACKED to COMPILED..."
	cp -rf "$DIR_UNPACKED"/* "$DIR_COMPILED"
	echo "Done."
}

checkenv
checkprograms
checktools
cleanenv
analyzemod
if [[ "$PNGEXIST" = "0" && "$XMLEXIST" = "0" ]] ; then
	showerror "FAILED: MOD is empty"
	exit
fi
if [[ "$XMLEXIST" = "1" || "$PNG9EXIST" = "1" ]] ; then
	unpackframework
	decompileframework
	applymod
	analyzedecompiled
	compileframework
	unpackcompiled
	copyunmodifiedfiles
	repackagecompiled
else
	unpackframework
	copyframework
	copymod
	repackagecompiled
fi
exit
