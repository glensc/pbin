#!/bin/sh

# Pastes from STDIN or file from commandline argument to Stikked pastebin
# Default server: paste.mate-desktop.org
# URL: https://github.com/glensc/pbin

# Copyright (C) 2014-2018 Elan Ruusamäe

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set -e
PROGRAM=${0##*/}
verbose=""
result=""

if [ -z "$PASTE_URL" ];then
    # can be overriden from env
    : ${PASTE_URL='http://paste.mate-desktop.org/api/create'}
    #: ${PASTE_APIKEY='apikey'}
fi

# filter url for printing (remove password)
print_url() {
	local url="$1"

	echo "$url" | sed -e 's;://[^@]*@;://;'
}

# paste. take input from stdin
pastebin() {
    
if [ ! -z $verbose ];then    
	# show params
	sed -e '/^$/d' >&2 <<-EOF
		${PASTE_APIKEY+apikey: "$PASTE_APIKEY"}
		${title+title: "$title"}
		${name+name: "$name"}
		${private+private: "$private"}
		${language+language: "$language"}
		${expire+expire: "$expire"}
		${reply+reply: "$reply"}
	EOF

	# do paste
	curl "$PASTE_URL${PASTE_APIKEY+?apikey=${PASTE_APIKEY}}" \
		${title+-F title="$title"} \
		${name+-F name="$name"} \
		${private+-F private="$private"} \
		${language+-F lang="$language"} \
		${expire+-F expire="$expire"} \
		${reply+-F reply="$reply"} \
		-F 'text=<-'
else
	# do paste
	curl -s "$PASTE_URL${PASTE_APIKEY+?apikey=${PASTE_APIKEY}}" \
		${title+-F title="$title"} \
		${name+-F name="$name"} \
		${private+-F private="$private"} \
		${language+-F lang="$language"} \
		${expire+-F expire="$expire"} \
		${reply+-F reply="$reply"} \
		-F 'text=<-'
fi

}

# try to resolve mime-type to language
mime_to_lang() {
	local mime="$1"

	awk -F ':' -vm="$mime" 'm==$1 {print $2}' <<-EOF
	application/javascript:javascript
	application/xml:xml
	text/html:html5
	text/x-c:c
	text/x-c++:cpp
	text/x-diff:diff
	text/x-lua:lua
	text/x-php:php
	text/x-python:python
	text/x-ruby:ruby
	text/x-shellscript:bash
	EOF
}

# detect filetype. outputs nothing if no file binary or no detected
detect_mimetype() {
	local file="$1" out

	out=$(file -L --mime-type "$file" 2>/dev/null || :)
	echo "${out#*: }"
}

usage() {
	echo "Usage: $PROGRAM [options] < [input_file]

Options:
  -v, --verbose   Verbose mode; does not use xsel or xclip
  -a, --apikey    API key for the server
  -t, --title     title of this paste
  -n, --name      author of this paste
  -p, --private   should this paste be private
  -l, --language  language this paste is in
  -e, --expire    paste expiration in minutes
  -r, --reply     reply to existing paste
"
}

set_defaults() {
	unset title
	unset private
	unset language
	unset expire
	unset reply

	# default to user@hostname
	name=${SUDO_USER:-$USER}@${HOSTNAME:-$(hostname)}
}

set_defaults

# parse command line args
t=$(getopt -o h,v,t:,n:,p,l:,e:,r:,b:,a: --long help,verbose,title:,name:,private,language:,expire:,reply:,apikey: -n "$PROGRAM" -- "$@")
eval set -- "$t"

while :; do
	case "$1" in
	-v|--verbose)
        verbose=1

	;;
	-h|--help)
		usage
		exit 0
	;;
	-t|--title)
		shift
		title="$1"
	;;
	-n|--name)
		shift
		name="$1"
	;;
	-p|--private)
		private=1
	;;
	-l|--language)
		shift
		language="$1"
	;;
	-e|--expire)
		shift
		expire="$1"
	;;
	-r|--reply)
		shift
		reply="$1"
	;;
	-b)
		shift
		PASTE_URL="$1"
	;;
	-a|--apikey)
		shift
		PASTE_APIKEY="$1"
	;;
	--)
		shift
		break
	;;
	*)
		echo >&2 "$PROGRAM: Internal error: [$1] not recognized!"
		exit 1
	;;
	esac
	shift
done

if [ ! -z $verbose ];then
    printf "Paste endpoint: %s\n" "$(print_url "$PASTE_URL")"
fi

# if we have more commandline arguments, set these as title
if [ "${title+set}" != "set" ]; then
	title="$*"
fi

# set language from first filename
if [ -n "$1" ] && [ "${language+set}" != "set" ]; then
	mime=$(detect_mimetype "$1")

	if [ -n "$mime" ]; then
		language=$(mime_to_lang "$mime")
	fi
fi

# take filenames from commandline, or from stdin
if [ $# -gt 0 ]; then
	paste=$(cat "$@")
else
	paste=$(cat)
fi


if [ -z $verbose ];then
    result=$(printf "%s" "$paste" | pastebin )
    xclip_bin=$(which xclip)
    xsel_bin=$(which xsel)
    if [ -f ${xclip_bin} ];then 
        echo "${result}" | xclip -i
    fi
    if [ -f ${xsel_bin} ];then 
        echo "${result}" | xsel -i -b
    fi
    echo "${result}" 
else
    printf "%s" "$paste" | pastebin 
fi


