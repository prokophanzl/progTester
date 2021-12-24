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

VERSION='0.4.1'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

PROG=0
DIR=testdata
QUIET=0
WRONGOUTDIR=0
TIMEOUT=0
OUTPUT='/tmp/progtester/tester'

SUCCESS=0
FAIL=0

test_inputs() {
	if [[ ! -f "$PROG" ]]; then
		echo -e "${RED}Error: please specify valid source file."
		exit 3
	elif [[ ! -d "$DIR" ]]; then
		echo -e "${RED}Error: invalid test data directory."
		exit 4
	fi
}

echo_help() {
	echo -e "${BLUE}              progTester v$VERSION${NC} by ${BOLD}Prokop Hanzl${NC}"
	echo -e "${BOLD}       usage:${NC} progtester -s <source-code> -t <testdata-dir>"
	echo -e "${BOLD}requirements:${NC} test data must be in the format ${YELLOW}0000_in.txt ${GREEN}0000_out.txt${NC}"
	echo -e "${BOLD}dependencies:${NC} GNU coreutils"
	echo           "              on macOS: brew install coreutils"
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
	echo
	echo -e "${BOLD}Copyright (C) 2021 Prokop Hanzl${NC}"
	echo    "This program is free software: you can redistribute it and/or modify it under"
	echo    "the terms of the GNU General Public License, version 3."
	exit 0
}

cleanup() {
	rm -r /tmp/progtester
}

compile_code() {
	if [[ $QUIET -eq 0 ]]; then
		echo -e "${YELLOW}Compiling...${NC}"
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
	if [[ $OSTYPE == 'darwin'* ]]; then
		gtimeout $TIMEOUT $OUTPUT < $IN_FILE > /tmp/progtester/myout
	else
		timeout $TIMEOUT $OUTPUT < $IN_FILE > /tmp/progtester/myout
	fi
}

test_code() {
	if [[ $QUIET -eq 0 ]]; then
		echo -e "${YELLOW}Testing...${NC}"
	fi
	for IN_FILE in "$DIR"/*_in.txt; do
		REF_FILE=`echo -n $IN_FILE | sed -e 's/_in\(.*\)$/_out\1/'`
		
		do_timeout
		if [ $? -eq 124 ]; then
			if [[ $QUIET -eq 0 ]]; then
					>&2 echo -e "${RED}FAIL: ${NC}$IN_FILE"
				fi
				((FAIL++))
			echo -e "    ${YELLOW}> killed after $TIMEOUT seconds${NC}"
		else
			if ! diff $REF_FILE /tmp/progtester/myout > /dev/null; then

				if [[ $QUIET -eq 0 ]]; then
					>&2 echo -e "${RED}FAIL: ${NC}$IN_FILE"
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

					if [[ $QUIET -eq 0 ]]; then
						>&2 echo -e "    ${YELLOW}> see $WRONGOUTDIR$SHORTREF${NC}"
					fi
				fi
			else
				if [[ $QUIET -eq 0 ]]; then
					echo -e "${GREEN}OK: ${NC}$IN_FILE"
				fi
				((SUCCESS++))
			fi
		fi
	done
}

print_stats() {
	TOTAL=$(($FAIL+$SUCCESS))
	echo -e "${BLUE}$SUCCESS/$TOTAL${NC} ($SUCCESS successes and $FAIL failures)"
	if [[ $QUIET -eq 1 ]] && [[ $WRONGOUTDIR != 0 ]]; then
		echo -e "${YELLOW}See $WRONGOUTDIR$SHORTREF for wrong output data${NC}"
	fi
}

while getopts ":hs:t:qvw:k:o:" OPT; do
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
	esac
done

test_inputs

mkdir -p /tmp/progtester

compile_code
test_code
print_stats

cleanup

if [[ $TOTAL -eq $SUCCESS ]]; then
	exit 0
else
	exit 2
fi
