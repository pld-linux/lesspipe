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
	case ""$1"" in
	*.tar) tar tvvf "$1" 2>/dev/null ;; # View contents of .tar and .tgz files
	*.tgz) tar tzvvf "$1" 2>/dev/null ;;
	*.tar.gz) tar tzvvf "$1" 2>/dev/null ;;
	*.tar.Z) tar tzvvf "$1" 2>/dev/null ;;
	*.tar.z) tar tzvvf "$1" 2>/dev/null ;;
	*.tar.bz2) bzcat "$1" | tar tvvf - 2>/dev/null ;;
	*.Z) gzip -dc "$1"  2>/dev/null ;; # View compressed files correctly
	*.z) gzip -dc "$1"  2>/dev/null ;;
	*.gz) gzip -dc "$1"  2>/dev/null ;;
	*.bz2) bzip2 -dc "$1" 2>/dev/null ;;
	*.zip) unzip -l "$1" 2>/dev/null ;;
	*.1|*.2|*.3|*.4|*.5|*.6|*.7|*.8|*.9|*.l|*.n|*.man) FILE=`file -L "$1"` ; # groff src
		FILE=`echo $FILE | cut -d ' ' -f 2`
		if [ "$FILE" = "troff" ]; then
			groff -s -p -t -e -Tlatin1 -mandoc "$1"
		fi ;;
	*) FILE=`file -L "$1"` ; # Check to see if binary, if so -- view with 'strings'
  esac
}

lesspipe "$1"
