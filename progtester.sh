#!/bin/bash

# progTester: a test script for ProgTest
# Copyright (C) 2021 Prokop Hanzl

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

VERSION='0.5.1'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHTYELLOW='\033[0;93m'
PURPLE='\033[0;94m'
BLUE='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
ITALIC='\033[0;03m'
NC='\033[0m'

PROG=0
DIR=testdata
QUIET=0
WRONGOUTDIR=0
TIMEOUT=0
OUTPUT='/tmp/progtester/tester'
SORTOUTPUT=0
CLOCK=0
TOTALTIME=0

SUCCESS=0
FAIL=0

test_inputs() {
	if [[ $OSTYPE == 'darwin'* ]]; then
		if ! [[ -x "$(command -v g++-11)" ]]; then
			echo -e "${RED}Error: g++-11 not installed.${NC} Try brew install g++."
			exit 5
		elif ! [[ -x "$(command -v gtimeout)" ]]; then
			echo -e "${RED}Error: coreutils not installed.${NC} Try brew install coreutils."
			exit 5
		fi
	fi
	if [[ ! -f "$PROG" ]]; then
		echo -e "${RED}Error: please specify valid source file.${NC}"
		exit 3
	elif [[ ! -d "$DIR" ]]; then
		echo -e "${RED}Error: invalid test data directory.${NC}"
		exit 4
	fi
}

echo_help() {
	echo -e "${BLUE}${BOLD}              progTester v$VERSION${NC} ${BOLD}by Prokop Hanzl${NC}"
	echo -e "${BOLD}       usage:${NC} progtester -s <source-code> [-t <testdata-dir>] [-v|-q]"
	echo                "                         [-w <wrongouts-dir>] [-k <seconds>] [-o <output>]"
	echo -e "${BOLD}requirements:${NC} test data must be in the format ${YELLOW}0000_in.txt ${GREEN}0000_out.txt${NC}"
	echo -e "${BOLD}dependencies:${NC} GNU coreutils - on macOS: brew install coreutils"
	echo                "              g++ (g++-11 on macOS - brew install g++)"
	echo -e "${BOLD}     options:${NC} ${BLUE}-h${NC} or ${BLUE}--help${NC} to show this screen"
	echo -e             "              ${BLUE}-s <source-code>${NC} or ${BLUE}--source <source-code>${NC} to specify the source"
	echo                "                 code file (required)"
	echo -e             "              ${BLUE}-t <testdata-dir>${NC} or ${BLUE}--testdata <testdata-dir>${NC} to specify the test"
	echo                "                 data directory (default: testdata/)"
	echo -e             "              ${BLUE}-v${NC} or ${BLUE}--verbose${NC} to run in verbose mode (default)"
	echo -e             "              ${BLUE}-q${NC} or ${BLUE}--quiet${NC} to run in quiet mode"
	echo -e             "              ${BLUE}-w <wrongouts-dir>${NC} or ${BLUE}--wrongouts <wrongouts-dir>${NC} to specify a"
	echo                "                 directory for wrong outputs"
	echo -e             "              ${BLUE}-k <seconds>${NC} or ${BLUE}--killafter <seconds>${NC} to specify a timeout"
	echo                "                 (in seconds) after which the program is killed. 0 for no"
	echo                "                 timeout (default)"
	echo -e             "              ${BLUE}-o <output>${NC} or ${BLUE}--output <output>${NC} to specify where to save the"
	echo                "                 output file"
	echo -e             "              ${BLUE}-u${NC} or ${BLUE}--unsorted-output${NC} to allow outputs to be in any order"
	echo -e             "              ${BLUE}-c${NC} or ${BLUE}--clock${NC} to show runtime for each input"
	echo
	echo -e "${BOLD}Copyright (C) 2021 Prokop Hanzl${NC}"
	echo    "This program is free software: you can redistribute it and/or modify it under"
	echo    "the terms of the GNU General Public License, version 3."
	echo
	echo -e "This script is made and maintained by ${BOLD}Prokop Hanzl${NC} at"
	echo -e "${GREEN}https://github.com/ProkopHanzl/progTester${NC}. Feel free to request features and"
	echo    "report bugs in the repository."
	exit 0
}

cleanup() {
	rm -r /tmp/progtester
}

compile_code() {
	if [[ $QUIET == 0 ]]; then
		echo -e "${LIGHTYELLOW}Compiling...${NC}"
	fi

	COMPILER=g++
	if [[ $OSTYPE == 'darwin'* ]]; then
		COMPILER=g++-11
	fi

	if ! $COMPILER "$PROG" -Wall -pedantic -O2 -o "$OUTPUT"; then
		>&2 echo -e "${RED}Error compiling.${NC}"
		cleanup
		exit 1
	fi
}

do_timeout() {
	TIME1=$(gdate +%s%3N)
	if [[ $OSTYPE == 'darwin'* ]]; then
		gtimeout $TIMEOUT $OUTPUT < $IN_FILE > /tmp/progtester/myout
	else
		timeout $TIMEOUT $OUTPUT < $IN_FILE > /tmp/progtester/myout
	fi
	TIMEOUTRET=$?
	TIME2=$(gdate +%s%3N)
}

compare_outs() {
	if [[ $SORTOUTPUT == 1 ]]; then
		cat $REF_FILE | sort > /tmp/progtester/sortedRef
		cat /tmp/progtester/myout | sort > /tmp/progtester/sortedMyOut
		diff /tmp/progtester/sortedRef /tmp/progtester/sortedMyOut > /dev/null
	else
		diff $REF_FILE /tmp/progtester/myout > /dev/null
	fi
}

print_time() {
	MS="000$1"
	>&2 echo -e "    ${GRAY}> time elapsed: ${PURPLE}$(($1 / 1000)).${MS: -3}s${NC}"
}

test_code() {
	if [[ $QUIET == 0 ]]; then
		echo -e "${LIGHTYELLOW}Testing...${NC}"
	fi
	for IN_FILE in "$DIR"/*_in.txt; do
		REF_FILE=`echo -n $IN_FILE | sed -e 's/_in\(.*\)$/_out\1/'`
		
		do_timeout
		if [ $TIMEOUTRET == 124 ]; then
			if [[ $QUIET == 0 ]]; then
				>&2 echo -e "${RED}FAIL: ${NC}$IN_FILE"
				>&2 echo -e "    ${GRAY}> ${YELLOW}killed after ${PURPLE}${TIMEOUT}s${NC}"
			fi
			((FAIL++))
		else
			if ! compare_outs; then

				if [[ $QUIET == 0 ]]; then
					>&2 echo -e "${RED}${BOLD}FAIL: ${NC}${BOLD}$IN_FILE${NC}"
				fi
				((FAIL++))

				if [[ "$WRONGOUTDIR" != 0 ]]; then
					mkdir -p "$WRONGOUTDIR"

					SHORTREF="${REF_FILE//$DIR/}"
					>&2 echo "Input:" > "$WRONGOUTDIR$SHORTREF"
					>&2 cat $IN_FILE >> "$WRONGOUTDIR$SHORTREF"
					>&2 echo >> "$WRONGOUTDIR$SHORTREF"
					
					>&2 echo "Expected output:" >> "$WRONGOUTDIR$SHORTREF"
					>&2 cat $REF_FILE >> "$WRONGOUTDIR$SHORTREF"
					>&2 echo >> "$WRONGOUTDIR$SHORTREF"

					>&2 echo "Your output:" >> "$WRONGOUTDIR$SHORTREF"
					>&2 cat /tmp/progtester/myout >> "$WRONGOUTDIR$SHORTREF"

					if [[ $QUIET == 0 ]]; then
						>&2 echo -e "    ${GRAY}> see ${PURPLE}$WRONGOUTDIR$SHORTREF${NC}"
					fi
				fi

			else
				if [[ $QUIET == 0 ]]; then
					echo -e "${GREEN}${BOLD}OK: ${NC}${BOLD}$IN_FILE${NC}"
				fi
				((SUCCESS++))
			fi

			if [[ $QUIET == 0 ]] && [[ $CLOCK == 1 ]]; then
				print_time $((TIME2-$TIME1))
			fi
		fi
	done
}

print_stats() {
	TOTAL=$(($FAIL+$SUCCESS))
	echo -e "${BLUE}$SUCCESS/$TOTAL${NC} ($SUCCESS successes and $FAIL failures)"
	if [[ $QUIET == 1 ]] && [[ $WRONGOUTDIR != 0 ]]; then
		echo -e "See ${PURPLE}$WRONGOUTDIR${NC} for wrong output data"
	fi
}

while getopts ":hs:t:qvw:k:o:uc" OPT; do
	case $OPT in
		h)	echo_help
			;;
		s)	PROG=$OPTARG
			;;
		t)	DIR=$OPTARG
			;;
		q)	QUIET=1
			;;
		v)	QUIET=0
			;;
		w)	WRONGOUTDIR=$OPTARG
			;;
		k)	TIMEOUT=$OPTARG
			;;
		o)	OUTPUT=./$OPTARG
			;;
		u)	SORTOUTPUT=1
			;;
		c)	CLOCK=1
			;;
	esac
done

test_inputs

mkdir -p /tmp/progtester

compile_code
test_code
print_stats

cleanup

if [[ $TOTAL == $SUCCESS ]]; then
	exit 0
else
	exit 2
fi
