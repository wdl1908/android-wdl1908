#!/bin/bash

mkicon () {
	BASEICON="$1"
	ICON="$2"
	PNG=`basename "$2" .svg`.png
	TEMPFILE0="$ICON".tmp0.svg
	TEMPFILE1="$ICON".tmp1.svg

	cat "$BASEICON" | tr "\n" " " > "$TEMPFILE0"

	shift
	shift

	while (( "$#" )); do
		LABEL=$1
		FROM=$2
		TO=$3

		cat "$TEMPFILE0" | sed "s/\(style=[^<>]*\)$FROM\([^<>]*label=\\\"\#$LABEL\)/\1$TO\2/g" > "$TEMPFILE1"
		cp "$TEMPFILE1" "$TEMPFILE0"
		shift
		shift
		shift
	done

	cp "$TEMPFILE0" "$ICON"
	inkscape --without-gui --file="$ICON" --export-png="$PNG"
	rm -f $TEMPFILE0 $TEMPFILE1
}
