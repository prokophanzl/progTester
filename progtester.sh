#!/bin/bash

PROG=$1
# DIR=$2
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
	# echo
	if ! diff $REF_FILE /tmp/progtester/myout > /dev/null; then
		# echo
		# echo -e "${YELLOW}input:${NC}"
		# cat $IN_FILE
		# echo
		# echo -e "${YELLOW}expected output:${NC}"
		# cat $REF_FILE
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
