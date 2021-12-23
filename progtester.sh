#!/bin/bash

# progTester: a test script for ProgTest
# Copyright (C) 2021 Prokop Hanzl

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

PROG=$1
DIR=${2%/}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

SUCCESS=0
FAIL=0

mkdir -p /tmp/progtester

echo -e "${YELLOW}Compiling...${NC}"
if ! g++ $PROG -Wall -pedantic -O2 -fsanitize=address -Wextra -Wno-deprecated -o /tmp/progtester/tester; then
	echo -e "${RED}Error compiling.${NC}"
	rm -r progtester
	exit 1
fi
echo

echo -e "${YELLOW}Testing...${NC}"
for IN_FILE in "$DIR"/*_in.txt; do
	REF_FILE=`echo -n $IN_FILE | sed -e 's/_in\(.*\)$/_out\1/'`
	/tmp/progtester/tester < $IN_FILE > /tmp/progtester/myout
	if ! diff $REF_FILE /tmp/progtester/myout > /dev/null; then
		echo -e "${RED}FAIL: ${NC}$IN_FILE"
		FAIL=$((FAIL+1))

		mkdir -p wrong_testdata

		echo "Input:" >> wrong_$REF_FILE
		cat $IN_FILE >> wrong_$REF_FILE
		echo >> wrong_$REF_FILE
		
		echo "Expected output:" >> wrong_$REF_FILE
		cat $REF_FILE >> wrong_$REF_FILE
		echo >> wrong_$REF_FILE

		echo "Your output:" >> wrong_$REF_FILE
		cat /tmp/progtester/myout >> wrong_$REF_FILE

		echo -e "    ${YELLOW}> see wrong_$REF_FILE${NC}"
	else
		echo -e "${GREEN}OK: ${NC}$IN_FILE"
		SUCCESS=$((SUCCESS+1))
	fi
done

TOTAL=$(($FAIL+$SUCCESS))
echo
echo -e "${BLUE}$SUCCESS/$TOTAL${NC} ($SUCCESS successes and $FAIL failures)"

rm -r /tmp/progtester
