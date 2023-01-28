#!/bin/bash

DEF_COLOR='\033[0;39m'
GRAY='\033[0;90m'
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
MAIN_COLOR='\033[0;96m'

function echo_test()
{
	ARGV=$(echo "$@")
	# echo -n $ARGV
	FTEST=$(echo "$ARGV" | cut -c 5-20)
	PRINT=$(echo "$ARGV" | cut -c 1-4)
	# echo -n "$FTEST"
	echo -n " "
	printf ${BLUE};
	echo -n " "$PRINT
	printf ${DEF_COLOR};
	TEST1=$(echo $FTEST | ./minishell 2>&-)
	ES_1=$?
	TEST1=$(echo "$TEST1" | cat -e)
	TEST2=$(echo $FTEST | bash 2>&-)
	ES_2=$?
	TEST2=$(echo "$TEST2" | cat -e)
	if [ "$TEST1" == "$TEST2" ] && [ "$ES_1" == "$ES_2" ]; then
		printf ${GREEN}"OK";
	else
		TMP=$(echo "$PRINT" | cut -c 1-2)
		echo "------------------------- test [$TMP]" >> traces/echo_trace.txt
		echo "expected: (exit code: $ES_2)" >> traces/echo_trace.txt
		echo "->$TEST2<-" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "found: (exit code: $ES_1)" >> traces/echo_trace.txt
		echo "->$TES1<-" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "-------------------------" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		printf ${RED}"KO";
	fi
	printf ${BLUE};
	echo -n "]"
	printf ${DEF_COLOR};
	sleep 0.05
}

printf ${MAIN_COLOR}"\t\t\t    -----------------------"${DEF_COLOR};
printf ${MAIN_COLOR}"\n\t\t\t   | 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
printf ${MAIN_COLOR}"\t\t\t    -----------------------\n\n"${DEF_COLOR};

make -C ../
cp ../minishell .
chmod 755 minishell

# ECHO TESTS
printf ${BLUE}"\n|===============================[ ECHO TESTS ]================================|\n\n"${DEF_COLOR}
mkdir traces
touch traces/echo_trace.txt
echo > traces/echo_trace.txt
echo_test ' 1.[echo ""     '
echo_test ' 2.[echo'
echo_test ' 3.[echO ""    '
echo_test ' 4.[    echo'
echo_test ' 5.[    echo       " hi"'
echo_test ' 6.["echo" ""   '
echo_test ' 7.[echo hi   '
echo_test ' 8.[EcHo hi   '
printf "\n\n"
echo_test ' 9.[echo """ ""hi" " """'
echo_test '10.[echo "'""'"'
echo_test '11.[echo \"hi\"'
echo_test '12.[echo $HOME'
echo_test '13.[echo $PATH'
echo_test '14.[echo $NONEXIST'
echo_test '15.["      echo"'
echo_test '16.[\ echo "   " $'
printf ${BLUE}"\n\n|===============================================================================|\n"${DEF_COLOR}

# PID=$(ps | grep minishell | grep -v "minishell_panic" | awk '{print $1}')
