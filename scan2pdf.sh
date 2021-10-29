#!/bin/bash

valid_params=true
valid_scanner=true

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || ([ "$1" != "Gray" ] && [ "$1" != "Color" ]); then
	echo
	echo "Usage: $0 [Gray|Color] [name] [destination-path] [batch-count]"
	echo
	valid_params=false
fi

if $valid_params; then
	if [[ -z "${SCAN_DEVICE}" ]]; then
		scan_device=$(scanimage -L 2>/dev/null | grep -i epson | sed 's/.*`//' | sed "s/'.*//")
		if [[ -z "$scan_device" ]]; then
			echo "scan device 'epson' not found."
			echo
			valid_scanner=false
		else
			export SCAN_DEVICE="$scan_device"
		fi
	else
		scan_device=$SCAN_DEVICE 
	fi

	if $valid_scanner; then
		tmpdir=/home/daniel/tmp/scanner
		path=$3
		filename=$2
		mode=$1
		batchcount="${4:-1}"

		echo scan_device: $scan_device
		echo tmpdir: $tmpdir

		#scanimage -b --format png --batch-count 1 -d $scan_device -l 0 -t 0 -x 210 -y 297 --resolution 300 --mode $mode | convert png:- $path/$filename.pdf
		
		scanimage -b --format tiff --batch-count $batchcount --batch-prompt -d $scan_device -l 0 -t 0 -x 210 -y 297 --resolution 300 --mode $mode
		mkdir -p $tmpdir && mv out*.tif $tmpdir
		
		echo converting image to pdf
		convert $tmpdir/out*.tif $tmpdir/out.ps
		mkdir -p $path && ps2pdf $tmpdir/out.ps $path/$filename.pdf 

		echo removing temporary files
		rm -f $tmpdir/out*.{tif,ps}

		echo done @ $path/$filename.pdf 

		stay=true
		while $stay; do
			echo
			read -p "show, list or remove? [s/l/r]: " yn 
			case $yn in
				[Ss]* ) evince $path/$filename.pdf 2>/dev/null&;;
				[Ll]* ) ls -lah $path/$filename.pdf;;
				[Rr]* ) rm -f $path/$filename.pdf;;
				* ) stay=false;;
			esac
		done

		echo
	fi
fi

