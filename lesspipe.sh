#!/bin/sh
#
# Copyright 1997, 1998 Patrick Volkerding, Moorhead, Minnesota USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This is a preprocessor for 'less'.  It is used when this environment
# variable is set:   LESSOPEN="|lesspipe.sh %s"

# attempt to reveal info about initrd image
initrd() {
	local ft=$(file "$1") dec tmp ft2

	case "$ft" in
	*LZMA?compressed?data*)
		dec="lzma -dc"
		;;
	*gzip?compressed?data*)
		dec="gzip -dc"
		;;
	*data*)
		dec="xz -dc"
		;;
	esac

	[ "$ft" ] || return 1
	tmp=$(mktemp -d) || return 1
	$dec "$1" > $tmp/initrd.img || {
		rm -rf $tmp
		return 1
	}

	ft2=$(file $tmp/initrd.img)
	echo "$ft:${ft2#$tmp/initrd.img:}"
	case "$ft2" in
	*cpio?archive*)
		install -d $tmp/initrd
		(cd $tmp/initrd && cpio -dimu --quiet < $tmp/initrd.img)
		;;
	*romfs?filesystem*)
		install -d $tmp/initrd
		mount -ro loop $tmp/initrd.img $tmp/initrd
		;;
	*)
		rm -rf $tmp
		return 0
		;;
	esac

	(cd $tmp/initrd; ls -lR)

	# also display linuxrc
	if [ -f $tmp/initrd/linuxrc ]; then
		echo ""
		echo "/linuxrc program:"
		cat $tmp/initrd/linuxrc
	fi

	mountpoint -q $tmp/initrd && umount $tmp/initrd

	rm -rf $tmp
	return 0
}

# display library info
# DT_NEEDED, SONAME etc
library_info() {
	local file="$1"

	objdump -p "$file"
}

lesspipe() {
	case "$1" in
	# possible initrd images
	*initrd-*.gz)
		initrd "$1" && return 0
	;;

	# archives
	*.7z) 7z l "$1" ;;
	*.a) ar tvf "$1" ;;
	*.tar.bz|*.tbz) bzip -d < "$1" | tar tvvf - ;;
	*.bz) bzip -d < "$1" ;;
	*.tar.bz2|*.tbz2) bzip2 -dc -- "$1" | tar tvvf - ;;
	*.bz2) bzip2 -dc -- "$1" ;;
	*.cab|*.CAB) cabextract -l -- "$1" ;;
	*.cpi|*.cpio) cpio -itv < "$1" ;;
	*.cpio.gz) gzip -dc -- "$1" | cpio -itv ;;
	*.deb) dpkg -c "$1" ;;
	*.tar.gz|*.tar.[Zz]|*.tgz) tar tzvvf "$1" ;;
	*.gz|*.[Zz]) gzip -dc -- "$1" ;;
	*.tar.lzma|*.tar.xz) tar tJvvf "$1" ;;
	*.lzma|*.xz) xz -dc -- "$1" || lzma -dc -- "$1" ;;
	*.phar) phar info -f "$1"; phar list -f "$1" ;;
	*.rar) unrar -p- vb -- "$1" ;;
	*.rpm) rpm -qpivl --changelog -- "$1" ;;
	*.tar|*.ova|*.gem) tar tvvf "$1" ;;
	*.sqf) unsquashfs -d . -ll "$1" ;;
	*.zip|*.jar|*.xpi|*.[hj]pi|*.pk3|*.skz|*.gg|*.ipa|*.whl|*.crx) 7z l "$1" || unzip -l "$1" ;;
	# .war could be Zip (limewire) or tar.gz file (konqueror web archives)
	*.war) 7z l "$1" || unzip -l "$1" || tar tzvvf "$1" ;;
	# other file types not handled via mailcap (no mimetype)
	*.rrd) rrdtool info "$1" ;;
	# SSL certs
	*.csr) openssl req -noout -text -in "$1" ;;
	*.crl) openssl crl -noout -text -in "$1" ;;
	*.crt) openssl x509 -noout -text -in "$1" ;;
	*.p7s) openssl pkcs7 -noout -text -in "$1" -print_certs -inform DER ;;
	# gnupg armored files
	*.asc) command -v gpg >/dev/null && { gpg -nv --homedir=/dev/null "$1" || : ; } || gpg2 -nv --homedir=/dev/null "$1" ;;
	*.gpg) gpg -d "$1" ;;
	*.so) library_info "$1" ;;
	*.ts) dvbsnoop -s ts -hideproginfo -nohexdumpbuffer -tssubdecode -n 1000 -if "$1" ;;
	# Possible manual pages
	*.1|*.2|*.3|*.4|*.5|*.6|*.7|*.8|*.9|*.l|*.n|*.man)
		FILE=$(file -L "$1" | cut -d ' ' -f 2) # groff src
		[ "$FILE" = 'troff' ] && groff -s -p -t -e -Tlatin1 -mandoc "$1" || return 1
		;;
	# possible sqlite3
	*.db|*.sqlite3)
		FILE=$(file -bL "$1" | cut -d , -f 1)
		[ "$FILE" = 'SQLite 3.x database' ] && sqlite3 "$1" .dump || return 1
		;;
	*)
		case $TERM in
		xterm|xterm-color|xterm*88color|xterm*256color)
			output=xterm256;;
		*)
			output=ansi;;
		esac
		DISPLAY= run-mailcap --no-pager "$1" || {
			echo "$LESS" | grep -qi r || ps -p $PPID,$(ps -p $PPID -oppid=) -oargs= | grep -qiw -- -r && highlight --validate-input --no-trailing-nl --out-format=$output --style=darkblue "$1";
		}
	# Check to see if binary, if so -- view with 'strings'
	# FILE=$(file -L "$1")
	esac
}

if [ -d "$1" ]; then
	/bin/ls -alF -- "$1"
elif [ -f "$1" ]; then
	lesspipe "$1" 2> /dev/null
fi
