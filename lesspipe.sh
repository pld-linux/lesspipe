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
#

# This is a preprocessor for 'less'.  It is used when this environment
# variable is set:   LESSOPEN="|lesspipe.sh %s"

lesspipe() {
	case "$1" in
	*.tar|*.phar) tar tvvf "$1" ;;
	*.tgz|*.tar.gz|*.tar.[Zz]) tar tzvvf "$1" ;;
	*.tbz2|*.tar.bz2) bzip2 -dc -- "$1" | tar tvvf - ;;
	*.[Zz]|*.gz) gzip -dc -- "$1" ;;
	*.bz) bzip -dc -- "$1" ;;
	*.bz2) bzip2 -dc -- "$1" ;;
	*.lzma) lzma d -so -- "$1" ;;
	*.zip|*.jar) 7z l "$1" || unzip -l "$1" ;;
	*.rpm) rpm -qpivl --changelog -- "$1" ;;
	*.rar) unrar -p- l -- "$1" ;;
	*.cpi|*.cpio) cpio -itv < "$1" ;;
	*.deb) dpkg -c "$1" ;;
	# .war could be Zip (limewire) or tar.gz file (konqueror web archives)
	*.war) 7z l "$1" || unzip -l "$1" || tar tzvvf "$1" ;;
	# SSL certs
	*.csr) openssl req -noout -text -in "$1" ;;
	*.crl) openssl crl -noout -text -in "$1" ;;
	*.crt) openssl x509 -noout -text -in "$1" ;;
	# Possible manual pages
	*.1|*.2|*.3|*.4|*.5|*.6|*.7|*.8|*.9|*.l|*.n|*.man) FILE=`file -L "$1"` ; # groff src
		FILE=`echo $FILE | cut -d ' ' -f 2`
		if [ "$FILE" = "troff" ]; then
			groff -s -p -t -e -Tlatin1 -mandoc "$1"
		fi ;;
	*) FILE=`file -L "$1"` ; # Check to see if binary, if so -- view with 'strings'
  esac
}

if [ -d "$1" ] ; then
	/bin/ls -alF -- "$1"
else
	lesspipe "$1" 2> /dev/null
fi
