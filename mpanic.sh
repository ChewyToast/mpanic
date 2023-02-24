#!/bin/bash

# colors
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
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  UTILS

function	clean_exit()
{
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell
	exit
}

function	echo_color()
{
	printf $1
	if [ "$3" == "-n" ]; then
		echo -n $2
	else
		echo $2
	fi
	printf ${DEF_COLOR}	
}

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE & COMPILATION

	mkdir .errors &> /dev/null
	mkdir .tmp &> /dev/null
	echo_color ${GRAY} "Compiling Makefile ... Please wait!"
	MKFF=$(make -C ../ &> .errors/error.txt)
	echo_color ${GRAY} "Thanks for waiting"
	MK_1=$?
	MKFF=$(cat .errors/error.txt | cut -c 1-46)

	if [ "$MK_1" != "0" ]; then
		if [ "$MKFF" == "make: *** No targets specified and no makefile" ]; then
			echo_color ${RED} "Makefile not found!"
			echo "Remember to clone it and run as follows:"
			echo "  1. cd minishell_project_folder"
			echo "  2. git clone git@github.com:ChewyToast/minishell_panic.git"
			echo "  3. cd minishell_panic"
			echo "  4. bash mpanic.sh"
			echo ""
			clean_exit
		else
			echo_color ${RED} "Compilation error"
			echo "-------------"
			echo "$MKFF"
			echo "-------------"
			clean_exit
		fi
	else
		mkdir traces &> /dev/null
		cp ../minishell .
		chmod 777 minishell &> /dev/null
	fi
	echo "exit" > .tmp/exec_read.txt
	< .tmp/exec_read.txt ./minishell &> .tmp/start.txt

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE VARIABLES
# PROMPT
	prmp=$(cat -e .tmp/start.txt | sed -e "2d")
	size_prom_cat_exit=${#prmp}
	size_prom=$(($size_prom_cat_exit - 5))
	PRMP=$(echo "$prmp" | cut -c 1-$size_prom)
# TEST COUNTER
	i=0
# TEST RESULT
	ret=0
# TEST STATUS
	EOK="OK"


# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

# # >>>> TESTS ECHO


	function trace_printer()
	{
		TMP=$(echo "$1" | cut -c 1-2)
		echo "--------------------> test [$2]" >> traces/echo_trace.txt
		echo "cmd: \"$3\"" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "expected: (exit code: $4)" >> traces/echo_trace.txt
		echo "->$5<-" >> traces/echo_trace.txt
		echo "" >> traces/echo_trace.txt
		echo "found: (exit code: $6)" >> traces/echo_trace.txt
		echo "->$7<-" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "--------------------<">> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
	}


	function print_test_result()
	{
		echo_color ${BLUE} "  ${i}.  [" -n
		if [ "$ret" == 1 ]; then
			printf "✅"
		else
			printf "❌"
		fi
		echo_color ${BLUE} " ] ->" -n
		printf ${MAGENTA};
		if [ "$2" ]; then
			echo -n "$2";
		else
			echo -n "$1";
		fi
		printf "${BLUE}<-${DEF_COLOR}\n\n";

	}
	
	function echo_simple_test()
	{
		# Declaramos variables para funcion
		let "i=i+1"
		FTEST=$(echo "$1")

		# Preparamos archivo que va a ser el input con los argumentos
		# Print para completar visualizer
 		echo "$FTEST" > .tmp/exec_read.txt
 		echo "exit" >> .tmp/exec_read.txt

		# Ejecutamos minishell y bash con mismos comandos y recojemos ES
		< .tmp/exec_read.txt ./minishell &> .tmp/exec_outp.txt
		ES1=$?
		< .tmp/exec_read.txt bash &> .tmp/bash_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		WCTEST1=$(cat -e .tmp/exec_outp.txt | wc -l)
		WCTEST2=$(cat -e .tmp/bash_outp.txt | wc -l)
	
		if [ "$WCTEST1" == "       4" ]; then
			TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "$ d" | sed -e "1d")
			TEST2=$(cat -e .tmp/bash_outp.txt)
		else
			if [ "$WCTEST1" == "       3" ]; then
				# TEST1=$(cat -e .tmp/exec_outp.txt)
				TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d" | rev )
				TEST1=${TEST1:$size_prom_cat_exit:${#TEST1}}
				TEST1=$(echo "$TEST1" | rev )
				# TEST1=${TEST1:0:7}
				TEST2=$(cat -e .tmp/bash_outp.txt)
			else
				TEST1=$(cat -e .tmp/exec_outp.txt)
				TEST2=$(cat -e .tmp/bash_outp.txt)
			fi
		fi

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [[ "$ES2" == "127" && "$ES1" == "127" && $TEST1 == *"command not found"* ]]; then
			ret=1;
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				ret=1
			else
				ret=0
				trace_printer "$1" "$i" "$FTEST" "$ES2" "$TEST2" "$ES1" "$TEST1";
			fi
		fi
		PRINT=$(print_test_result "${FTEST}")
		echo $PRINT
 		echo "" > .tmp/exec_outp.txt
 		echo "" > .tmp/bash_outp.txt
 	}

	function echo_mix_test()
	{
		FTEST=$(< .tmp/exec_read.txt cat | sed -e "$ d")
		echo "exit" >> .tmp/exec_read.txt
		< .tmp/exec_read.txt ./minishell &> .tmp/exec_outp.txt
		ES1=$?
		< .tmp/exec_read.txt bash &> .tmp/bash_outp.txt
		ES2=$?
		TEST2=$(cat -e .tmp/bash_outp.txt)
		TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "1d" -e "2d" -e "$ d" | sed -e "$ d")
		if [[ "$ES2" == "127" && "$ES1" == "127" && "$TEST1" == *"command not found"* ]]; then
			printf "✅";
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				printf "✅";
			else
				tracse_printer "$PRINT" "$1" "$FTEST" "$ES2" "$TEST2" "$ES1" "$TEST1";
				EOK="KO"
			fi
		fi
		printf ${BLUE};
		echo -n "]";
		printf " ->";
		printf ${MAGENTA};
		if [ "$3" ]; then
			echo -n "$3";
		else
			echo -n "$2";
		fi
		printf "${BLUE}<-${DEF_COLOR}\n\n";
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/bash_outp.txt
	}

# >>>>

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  BANNER


	printf ${MAIN_COLOR}"\t\t -----------------------"${DEF_COLOR};
	printf ${MAIN_COLOR}"\n\t\t| 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
	printf ${MAIN_COLOR}"\t\t -----------------------\n\n"${DEF_COLOR};


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TEST CALLS

#ECHO
	printf ${BLUE}"\n|=======================[ ECHO ]=======================|"${DEF_COLOR}
	rm -rf traces/echo_trace.txt &> /dev/null
	echo "" > traces/echo_trace.txt
	echo "**************************************************************" >> traces/echo_trace.txt
	echo "*                          CARE!                             *" >> traces/echo_trace.txt
	echo "*                                                            * " >> traces/echo_trace.txt
	echo "* This test doesnt work if ur readline prompt have newlines  *" >> traces/echo_trace.txt
	echo "*                                                            *" >> traces/echo_trace.txt
	echo "**************************************************************" >> traces/echo_trace.txt
	echo "" >> traces/echo_trace.txt
	printf ${BLUE}"\n\n\n"${DEF_COLOR}
	printf "${BLUE} parsing\n ------------------------------------\n\n${DEF_COLOR}"
	echo_simple_test 'echo ""     '
 	echo_simple_test 'echo'
	echo_simple_test 'echO ""    '
	echo_simple_test '    echo'
	echo_simple_test '    echo       " hi"'
	echo_simple_test '"echo" ""   '
	echo_simple_test 'echo hi   '
	echo_simple_test 'EcHo hi   '
	echo_simple_test 'echo """ ""hi" " """'
	echo_simple_test "\"echo\" ''"
	echo_simple_test 'echo \"hi\"'
	echo_simple_test 'echo $HOME'
	echo_simple_test '  13. [' 'echo $PATH'
	echo_simple_test '  14. [' 'echo $NONEXIST'
	echo_simple_test '  15. [' '" echo"'
	echo_simple_test '  16. [' '\ echo "   " $'
	echo_simple_test '  17. [' 'echo hi~'
	echo_simple_test '  18. [' 'echo ~'
	echo_simple_test '  19. [' 'echo ~false'
	echo_simple_test '  20. [' 'echo \~'
	echo_simple_test '  21. [' 'echo "~"ups'
	printf "${BLUE}\n flags\n ------------------------------------\n\n${DEF_COLOR}"
	echo_simple_test '  22. [' 'echo -n'
	echo_simple_test '  23. [' 'echo -n hi'
	echo_simple_test '  24. [' ' echo -nn'
	echo_simple_test '  25. [' 'echo -nn hi'
	echo_simple_test '  26. [' ' echo --n'
	echo_simple_test '  27. [' ''"'"'echo'"'"' --n hi'
	echo_simple_test '  28. [' 'echo -n -n'
	echo_simple_test '  29. [' 'echo -n -n hi'
	echo_simple_test '  30. [' 'echo -nn -nn'
	echo_simple_test '  31. [' 'echo -nn -nn hi'
	echo_simple_test '  32. [' 'echo -n -n -n -n'
	echo_simple_test '  33. [' 'echo -n -n -n -n hi'
	echo_simple_test '  34. [' 'echo -n -n -n \-n hi'
	echo_simple_test '  35. [' 'echo -nn hi --n'
	echo_simple_test '  36. [' 'echo \-nn hi --n'
	echo_simple_test '  37. [' 'echo -nn hi --n'
	echo_simple_test '  38. [' 'echo "-nn" hi -n'
	echo_simple_test '  39. [' 'echo -------------nnnnnnnnnn hi'
	echo_simple_test '  40. [' 'echo "-------------nnnnnnnnnn" hi'
# 	printf "${BLUE}\n combo\n ------------------------------------\n\n${DEF_COLOR}"
# 	# printf ${BLUE}"\n\n\n              ---------------         [ echo plus ]         ---------------            \n\n  "${DEF_COLOR}
# 	export ECMD="echo" &> /dev/null
# 	echo_simple_test '  41. [' '$ECMD' ''
# 	echo_simple_test '  42. [' '$ECMD "hi"'
# 	export ECMD="EchO" &> /dev/null
# 	echo_simple_test '  43. [' '$ECMD'
# 	export ECMD="EChO" &> /dev/null
# 	echo_simple_test '  44. [' '$ECMD "hi"'
# 	export ECMD="         echo" &> /dev/null
# 	echo_simple_test '  45. [' '$ECMD "hi"'
# 	export ECMD="         EcHO       " &> /dev/null
# 	echo_simple_test '  46. [' '$ECMD " hi"'
# 	printf "${RED}\tmore test comming soon...👹${DEF_COLOR}\n"
# 	# unset ECMD
# 	# printf ${BLUE};
# 	# echo -n "  47. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="echo"
# 	# $ECMD "hi"' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "47";
# 	# printf ${BLUE};
# 	# echo -n "  48. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="EchO"
# 	# $ECMD " hi"' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "48";
# 	# printf ${BLUE};
# 	# echo -n "  49. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="         EcHO       "
# 	# $ECMD "hi"' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "49";
# 	# printf ${BLUE};
# 	# echo -n "  50. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="         EcHO      hi "
# 	# $ECMD' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "50";
# 	# printf ${BLUE};
# 	# echo -n "  51. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="         '"'"'echo'"'"'      hi "
# 	# $ECMD' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "51";
# 	# printf ${BLUE};
# 	# echo -n "  52. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export ECMD="         "echo"      hi "
# 	# $ECMD' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "52";
# 	# printf ${BLUE};
# 	# echo -n "  53. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export PATH="."
# 	# echo hola' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "53";
# 	# printf ${BLUE};
# 	# echo -n "  54. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'export PATH="."
# 	# echo hola' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "53";
# 	# printf ${BLUE};
# 	# echo -n "  55. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'unset PATH
# 	# echo $USER*1' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "54";
# 	# printf ${BLUE};
# 	# echo -n "  56. ["
# 	# printf ${DEF_COLOR};
# 	# echo 'unset HOME
# 	# echo "~"$USER' > .tmp/exec_read.txt
# 	# echo "exit" >> .tmp/exec_read.txt
# 	# echo_mix_test "55";
	if [ "$EOK" == "KO" ];
	then
		printf "${CYAN}\n\n  It seems that there are some tests\n"
		printf "  that have not passed...\n\n"
		printf "  Failure traces -> traces/echo_traces.txt\n"
	fi
	printf "${BLUE}\n|======================================================|\n\n\n${DEF_COLOR}"
# #

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "${BLUE}  Any issue send via slack bmoll-pe or ailopez-o\n\n${DEF_COLOR}"
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
