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

VERSION='0.6.2'

# ======================== TEXT FORMATTING PRESETS ========================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
LIGHTYELLOW='\033[0;93m'
PURPLE='\033[0;94m'
BLUE='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# ======================== DEFAULT VALUES ========================

PROG=0 # source code
DIR=testdata # test data directory
QUIET=0 # quiet mode
WRONGOUTDIR=0 # wrong output directory
TIMEOUT=0 # timeout for --kill-after
OUTPUT='/tmp/progtester/tester' # compiler output
SORTOUTPUT=0 # --unsorted-output toggle
CLOCK=0 # --clock toggle

# ======================== SMALL FUNCTIONS ========================

ismac() {
	[[ $OSTYPE == 'darwin'* ]] && return 0 || return 1
}

error() {
	>&2 echo -e "${RED}ERROR: ${LIGHTYELLOW}$2${NC}"
	exit "$1"
}

vecho() { # verbose echo - echo only in verbose mode
	[[ $QUIET == 0 ]] && echo -e "$1"
}

qecho() { # silent echo - echo only in quiet mode
	[[ $QUIET == 1 ]] && echo -e "$1"
}

# ======================== INPUT CHECKS ========================

source_valid() {
	return $([[ -f "$PROG" ]])
}

testdata_valid() {
	return $([[ -d "$DIR" ]])
}

mac_dependencies_installed() {
	ismac && return $([[ -x "$(command -v g++-11)" ]] && [[ -x "$(command -v gtimeout)" ]])
}

timeout_valid() {
	local VALIDNUMBER='^[0-9]+([.][0-9]+)?$' # regex for number with decimal dot
	return $([[ $TIMEOUT =~ $VALIDNUMBER ]])
}

# ======================== BODY FUNCTIONS ========================

initialize_success_vars() {
	SUCCESS=0 # number of successful runs
	FAIL=0 # number of unsuccessful runs
}

test_inputs() {
	! source_valid               && error 3 "Please specify valid source file."
	! testdata_valid             && error 4 "Invalid test data directory."
	! mac_dependencies_installed && error 5 "Missing dependencies."
	! timeout_valid              && error 6 "Timeout is not a number."
}

echo_help() { # displays help screen
	echo -e "${BLUE}${BOLD}              progTester v$VERSION${NC} ${BOLD}by Prokop Hanzl${NC}
${BOLD}       usage:${NC} progtester -s <source-code> [-t <testdata-dir>] [-v|-q]
                         [-w <wrongouts-dir>] [-k <seconds>] [-o <output>]
${BOLD}requirements:${NC} test data must be in the format ${YELLOW}0000_in.txt ${GREEN}0000_out.txt${NC}
${BOLD}dependencies:${NC} GNU coreutils - on macOS: brew install coreutils
              g++ (g++-11 on macOS - brew install g++)
${BOLD}     options:${NC} ${BLUE}-h${NC} or ${BLUE}--help${NC} to show this screen
              ${BLUE}-s <source-code>${NC} or ${BLUE}--source <source-code>${NC} to specify the source
                 code file (required)
              ${BLUE}-t <testdata-dir>${NC} or ${BLUE}--testdata <testdata-dir>${NC} to specify the test
                 data directory (default: testdata/)
              ${BLUE}-v${NC} or ${BLUE}--verbose${NC} to run in verbose mode (default)
              ${BLUE}-q${NC} or ${BLUE}--quiet${NC} to run in quiet mode
              ${BLUE}-w <wrongouts-dir>${NC} or ${BLUE}--wrongouts <wrongouts-dir>${NC} to specify a
                 directory for wrong outputs
              ${BLUE}-k <seconds>${NC} or ${BLUE}--killafter <seconds>${NC} to specify a timeout
                 (in seconds) after which the program is killed. 0 for no
                 timeout (default)
              ${BLUE}-o <output>${NC} or ${BLUE}--output <output>${NC} to specify where to save the
                 output file
              ${BLUE}-u${NC} or ${BLUE}--unsorted-output${NC} to allow outputs to be in any order
              ${BLUE}-c${NC} or ${BLUE}--clock${NC} to show runtime for each input

${BOLD}Copyright (C) 2021 Prokop Hanzl${NC}
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License, version 3.

This script is made and maintained by ${BOLD}Prokop Hanzl${NC} at
${GREEN}https://github.com/ProkopHanzl/progTester${NC}. Feel free to request features and
report bugs in the repository."
	exit 0
}

cleanup() {
	rm -r /tmp/progtester
}

compile_code() { # compiles code
	vecho "${LIGHTYELLOW}Compiling...${NC}"
	ismac && COMPILER=g++-11 || COMPILER=g++
	if ! $COMPILER "$PROG" -Wall -pedantic -O2 -o "$OUTPUT"; then
		cleanup
		error 1 "Error compiling."
	fi
}

do_timeout() { # handles timeout
	local TIME1
	local TIME2
	TIME1=$(gdate +%s%3N) # nanoseconds in Unix time
	if ismac; then # if on macOS, use gtimeout
		gtimeout $TIMEOUT $OUTPUT < "$IN_FILE" > /tmp/progtester/myout
	else
		timeout $TIMEOUT $OUTPUT < "$IN_FILE" > /tmp/progtester/myout
	fi
	local TIMEOUTRET=$? # return value of timeout, 124 means timed out
	TIME2=$(gdate +%s%3N)
	TIMEDIFF=$((TIME2-TIME1))
	return $([[ $TIMEOUTRET == 124 ]])
}

compare_outs() { # compares actual output with the reference
	if [[ $SORTOUTPUT == 1 ]]; then # if --unsorted-output, sort both the reference and actual output before comparing them
		sort "$REF_FILE" > /tmp/progtester/sortedRef
		sort /tmp/progtester/myout > /tmp/progtester/sortedMyOut
		diff /tmp/progtester/sortedRef /tmp/progtester/sortedMyOut > /dev/null
	else
		diff "$REF_FILE" /tmp/progtester/myout > /dev/null
	fi
}

print_time() { # helper for --clock
	local MS="000$1"
	>&2 vecho "    ${GRAY}> time elapsed: ${PURPLE}$(($1 / 1000)).${MS: -3}s${NC}"
}

test_code() { # runs the tests
	initialize_success_vars
	vecho "${LIGHTYELLOW}Testing...${NC}"
	for IN_FILE in "$DIR"/*_in.txt; do # for each input file in test data directory
		REF_FILE=$(echo -n "$IN_FILE" | sed -e 's/_in\(.*\)$/_out\1/') # find the reference output counterpart
		if do_timeout; then # if timed out 
			>&2 vecho "${RED}FAIL: ${NC}$IN_FILE"
			>&2 vecho "    ${GRAY}> ${YELLOW}killed after ${PURPLE}${TIMEOUT}s${NC}"
			((FAIL++))
		else
			if ! compare_outs; then
				>&2 vecho "${RED}${BOLD}FAIL: ${NC}${BOLD}$IN_FILE${NC}"
				((FAIL++))
				if [[ "$WRONGOUTDIR" != 0 ]]; then 
					mkdir -p "$WRONGOUTDIR"
					SHORTREF="${REF_FILE//$DIR/}" # just the file name without the directory
					{
						echo "Input:"
						cat "$IN_FILE"
						echo
						echo "Expected output:"
						cat "$REF_FILE"
						echo
						echo "Your output:"
						cat /tmp/progtester/myout
					} > "$WRONGOUTDIR$SHORTREF"
					>&2 vecho "    ${GRAY}> see ${PURPLE}$WRONGOUTDIR$SHORTREF${NC}"
				fi
			else
				vecho "${GREEN}${BOLD}OK: ${NC}${BOLD}$IN_FILE${NC}"
				((SUCCESS++))
			fi
			[[ $CLOCK == 1 ]] && print_time $TIMEDIFF
		fi
	done
}

print_stats() { # prints stats about successful/unsuccessful runs
	TOTAL=$((FAIL+SUCCESS))
	echo -e "${BLUE}$SUCCESS/$TOTAL${NC} ($SUCCESS successes and $FAIL failures)"
	[[ $WRONGOUTDIR != 0 ]] && qecho "See ${PURPLE}$WRONGOUTDIR${NC} for wrong output data"
}

# ======================== BODY ========================

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
		*)	error 7 "Unkown option used."
			;;
	esac
done

test_inputs
mkdir -p /tmp/progtester
compile_code
test_code
print_stats
cleanup

[[ $TOTAL == "$SUCCESS" ]] && exit 0 || exit 2 # exit code 0 if all runs successful, 2 if not
