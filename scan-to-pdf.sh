
if [[ $# -eq 0 ]]; then
	echo
	echo 'Usage: scan-to-pdf <file name (omit extension)> <path (optional)>'
	echo ' file name: the PDF file name to be generated.'
	echo ' path: the path to save pdf. If not informed, it is set to current directory.'
	echo
	exit 0
fi

A4_X=210
A4_Y=297

# scanimage -L
#DEVICE="utsushi:esci:usb:/sys/devices/pci0000:00/0000:00:14.0/usb2/2-3/2-3.3/2-3.3:1.0"
#DEVICE=$(scanimage -L | grep -i 'xp-240_series' | cut -d"'" -f1 | cut -d'`' -f2)
DEVICE=$(scanimage -L | grep -i 'epson xp-240' | cut -d"'" -f1 | cut -d'`' -f2)
USER_PATH="$2"
DEFAULT_PATH='.'
PDF_PATH="${USER_PATH:-$DEFAULT_PATH}"/$1.pdf

scanimage -x $A4_X -y $A4_Y --device $DEVICE --format=png | convert png:- $PDF_PATH

