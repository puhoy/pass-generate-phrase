#!/usr/bin/env bash

set -e

this_dir=`dirname "${BASH_SOURCE[0]}"`

WORDLIST=${this_dir}/eff_large_wordlist.txt
WORDCOUNT=4
SEPARATOR="-"
COMMAND="generate-phrase"

random_word(){
    local wordlist="${1}"
    local line random wordcount word

    random=`od -An -N2 -i < /dev/urandom`

    wordcount=`cat ${wordlist} | wc -l`

    line=`expr $random % $wordcount`

    word=`tail -n+${line} ${wordlist} | head -n1 | grep -oE '[^[:space:]]+$'`

    printf "${word}"
}

# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

phrase_generate() {

    #echo phrase_generate

    local wordlistfile=${1}
    local count=${2}
    local separator=${3}

    words=()

    for (( i = 0 ; i < ${count} ; i++ )); do
        word=`random_word ${wordlistfile}`
        words+=(${word})
    done

    printf `join_by $separator ${words[*]}`
}


cmd_phrase_unknown_command() {
    printf "unknown command!"
}

cmd_phrase_version() {
    printf todo
}

cmd_phrase_generate() {
    local wordlist=${WORDLIST}
    local wordcount=${WORDCOUNT}
    local separator=${SEPARATOR}
    local force

    local opts
    opts="$($GETOPT -o c:l:s:f -l wordcount:,wordlist:,separator:,force -n "$PROGRAM" -- "$@")"
    local err=$?
    [[ $err -ne 0 ]] && die "Usage: $PROGRAM [--wordcount,-w wordcount] [--wordlist, -l wordlist] [--separator, -s separator] pass-name"

    eval set -- "$opts"

    while true;
    do case $1 in
    -c|--wordcount) wordcount=$2;  shift; shift;;
    -l|--wordlist) wordlist=$2;  shift; shift;;
    -s|--separator) separator=$2;  shift; shift;;
    -f|--force) force=1; shift ;;
    --) shift; break ;;

    esac done

    pass=`phrase_generate ${wordlist} ${wordcount} ${separator}`

  	local path="$1"
	check_sneaky_paths "$path"
	[[ -z "$path" ]] && { echo "Error: no pass-name specified"; exit 1; }
	mkdir -p -v "$PREFIX/$(dirname -- "$path")"
	set_gpg_recipients "$(dirname -- "$path")"
	local passfile="$PREFIX/$path.gpg"
	set_git "$passfile"

	[[ $inplace -eq 0 && $force -eq 0 && -e $passfile ]] && yesno "An entry already exists for $path. Overwrite it?"

	if [[ $inplace -eq 0 ]]; then
		echo "$pass" | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" || die "Password encryption aborted."
	else
		local passfile_temp="${passfile}.tmp.${RANDOM}.${RANDOM}.${RANDOM}.${RANDOM}.--"
		if { echo "$pass"; $GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +2; } | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile_temp" "${GPG_OPTS[@]}"; then
			mv "$passfile_temp" "$passfile"
		else
			rm -f "$passfile_temp"
			die "Could not reencrypt new password."
		fi
	fi

	local verb="Add"
	[[ $inplace -eq 1 ]] && verb="Replace"
	git_add_file "$passfile" "$verb generated password for ${path}."

	if [[ $clip -eq 1 ]]; then
		clip "$pass" "$path"
	elif [[ $qrcode -eq 1 ]]; then
		qrcode "$pass" "$path"
	else
		printf "\e[1mThe generated password for \e[4m%s\e[24m is:\e[0m\n\e[1m\e[93m%s\e[0m\n" "$path" "$pass"
	fi
}


cmd_phrase_usage() {
  cat <<-_EOF
Usage:

    $PROGRAM generate-phrase
        [--wordcount,-w wordcount]
        [--wordlist,-l /path/to/wordlist]
        [--separator,-s separator]
        pass-name

        generate a passphrase with WORDCOUNT (or 4) words,
        made from words in WORDLIST* (or the EFFs long wordlist**),
        separated by SEPARATOR (or "-")

        * a diceware list, each line like "11111 banana"
        **https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases

_EOF
  exit 0
}

case "$1" in
  help|--help|-h) shift; cmd_phrase_usage "$@" ;;
  *)                     cmd_phrase_generate "$@" ;;
esac
exit 0
