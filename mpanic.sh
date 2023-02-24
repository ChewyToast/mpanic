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

	function	print_color()
	{
		printf "$1"
		printf "$2"
		printf ${DEF_COLOR}	
	}
#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE & COMPILATION

	mkdir .errors &> /dev/null
	mkdir .tmp &> /dev/null
	print_color ${GRAY} "Compiling Makefile ... Please wait!\n"
	MKFF=$(make -C ../ &> .errors/error.txt)
	print_color ${GRAY} "Thanks for waiting\n"
	MK_1=$?
	MKFF=$(cat .errors/error.txt | cut -c 1-46)

	if [ "$MK_1" != "0" ]; then
		if [ "$MKFF" == "make: *** No targets specified and no makefile" ]; then
			print_color ${RED} "Makefile not found!\n"
			echo "Remember to clone it and run as follows:"
			echo "  1. cd minishell_project_folder"
			echo "  2. git clone git@github.com:ChewyToast/minishell_panic.git"
			echo "  3. cd minishell_panic"
			echo "  4. bash mpanic.sh"
			echo ""
			clean_exit
		else
			print_color ${RED} "Compilation error\n"
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

#


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
#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

	function trace_printer()
	{
		TMP=$(echo "$1" | cut -c 1-2)
		echo "--------------------> test [$2]" >> traces/echo_trace.txt
		echo "cmd: \"$3\"" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "EXPECTED:" >> traces/echo_trace.txt
		echo "exit status: $4" >> traces/echo_trace.txt
		echo "->$5<-" >> traces/echo_trace.txt
		echo "" >> traces/echo_trace.txt
		echo "FOUND:" >> traces/echo_trace.txt
		echo "exit status: $6" >> traces/echo_trace.txt
		echo "->$7<-" >> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
		echo "--------------------<">> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
	}

	function print_test_result()
	{
		if [ "${#i}" == "1" ]; then
			print_color ${BLUE} "  ${i}.  |"
		else
			if [ "${#i}" == "2" ]; then
				print_color ${BLUE} "  ${i}. |"
			else
				if [ "${#i}" == "3" ]; then
					print_color ${BLUE} "  ${i}.|"
				fi
			fi
		fi
		if [ "$ret" == 1 ]; then
			printf "✅"
		else
			printf "❌"
		fi
		print_color ${BLUE} "| - |"
		printf ${MAGENTA};
		if [ "$2" ]; then
			printf "$2";
		else
			printf "$1";
		fi
		printf "${BLUE}|${DEF_COLOR}\n";

	}
	
	function one_line_test()
	{
		# Declaramos variables para funcion
		let "i=i+1"
		FTEST=$(echo "$1")

		# Preparamos archivo que va a ser el input con los argumentos
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
				TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d" | rev )
				TEST1=${TEST1:$size_prom_cat_exit:${#TEST1}}
				TEST1=$(echo "$TEST1" | rev )
				TEST2=$(cat -e .tmp/bash_outp.txt)
			else
				TEST1=$(cat -e .tmp/exec_outp.txt)
				TEST2=$(cat -e .tmp/bash_outp.txt)
			fi
		fi

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [[ "$ES2" != "0" && "$ES1" != "0" ]]; then
			TEST2=${TEST2:18:${#TEST2}}
			if [[ $TEST1 == *"$TEST2"*  ]]; then
				ret=1;
			else
				ret=0
				trace_printer "$1" "$i" "$FTEST" "$ES2" "$(cat -e .tmp/bash_outp.txt)" "$ES1" "$TEST1";
			fi
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				ret=1
			else
				ret=0
				trace_printer "$1" "$i" "$FTEST" "$ES2" "$TEST2" "$ES1" "$TEST1";
			fi
		fi
		print_test_result "${FTEST}";
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/bash_outp.txt
	}

#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  BANNER


	printf ${MAIN_COLOR}"\t\t -----------------------"${DEF_COLOR};
	printf ${MAIN_COLOR}"\n\t\t| 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
	printf ${MAIN_COLOR}"\t\t -----------------------\n\n"${DEF_COLOR};


#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TEST CALLS

	#ECHO
		printf ${BLUE}"\n|=======================[ ECHO ]=======================|"${DEF_COLOR}
		rm -rf traces/echo_trace.txt &> /dev/null

		# PRINT IN TRACES
			echo "" > traces/echo_trace.txt
			echo "**************************************************************" >> traces/echo_trace.txt
			echo "*                          CARE!                             *" >> traces/echo_trace.txt
			echo "*                                                            * " >> traces/echo_trace.txt
			echo "* This test doesnt work if ur readline prompt have newlines  *" >> traces/echo_trace.txt
			echo "*                                                            *" >> traces/echo_trace.txt
			echo "**************************************************************" >> traces/echo_trace.txt
			echo "" >> traces/echo_trace.txt
			printf ${BLUE}"\n\n\n"${DEF_COLOR}
		#

		# SIMPLE TEST ECHO WHILE
			printf "${BLUE} simple\n ------------------------------------\n\n${DEF_COLOR}"
			test_file="./test/echo/echo_tests.txt"
			while IFS= read -r linea
			do
				one_line_test "$linea"
			done < "$test_file"
		#

		# FLAGS TEST ECHO WHILE
			printf "${BLUE}\n flags\n ------------------------------------\n\n${DEF_COLOR}"
			test_file="./test/echo/echo_flag_tests.txt"
			while IFS= read -r linea
			do
				one_line_test "$linea"
			done < "$test_file"
		#

		# # MIXED TEST ECHO WHILE
		# 	printf "${BLUE} mixed\n ------------------------------------\n\n${DEF_COLOR}"
		# 	test_file="./test/echo/echo_mix_tests.txt"
		# 	while IFS= read -r linea
		# 	do
		# 		one_line_test "$linea"
		# 	done < "$test_file"
		# #


		printf "${BLUE}\n combo\n ------------------------------------\n\n${DEF_COLOR}"
		# printf ${BLUE}"\n\n\n              ---------------         [ echo plus ]         ---------------            \n\n  "${DEF_COLOR}
		export ECMD="echo" &> /dev/null
		one_line_test '$ECMD' ''
		one_line_test '$ECMD "hi"'
		export ECMD="EchO" &> /dev/null
		one_line_test '$ECMD'
		export ECMD="EChO" &> /dev/null
		one_line_test '$ECMD "hi"'
		export ECMD="         echo" &> /dev/null
		one_line_test '$ECMD "hi"'
		export ECMD="         EcHO       " &> /dev/null
		one_line_test '$ECMD " hi"'
		printf "${RED}\n\n\tmore test comming soon...👹${DEF_COLOR}\n"
		# printf ${BLUE};
		# echo -n "  47. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="echo"
		# $ECMD "hi"' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "47";
		# printf ${BLUE};
		# echo -n "  48. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="EchO"
		# $ECMD " hi"' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "48";
		# printf ${BLUE};
		# echo -n "  49. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="         EcHO       "
		# $ECMD "hi"' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "49";
		# printf ${BLUE};
		# echo -n "  50. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="         EcHO      hi "
		# $ECMD' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "50";
		# printf ${BLUE};
		# echo -n "  51. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="         '"'"'echo'"'"'      hi "
		# $ECMD' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "51";
		# printf ${BLUE};
		# echo -n "  52. ["
		# printf ${DEF_COLOR};
		# echo 'export ECMD="         "echo"      hi "
		# $ECMD' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "52";
		# printf ${BLUE};
		# echo -n "  53. ["
		# printf ${DEF_COLOR};
		# echo 'export PATH="."
		# echo hola' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "53";
		# printf ${BLUE};
		# echo -n "  54. ["
		# printf ${DEF_COLOR};
		# echo 'export PATH="."
		# echo hola' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "53";
		# printf ${BLUE};
		# echo -n "  55. ["
		# printf ${DEF_COLOR};
		# echo 'unset PATH
		# echo $USER*1' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "54";
		# printf ${BLUE};
		# echo -n "  56. ["
		# printf ${DEF_COLOR};
		# echo 'unset HOME
		# echo "~"$USER' > .tmp/exec_read.txt
		# echo "exit" >> .tmp/exec_read.txt
		# echo_mix_test "55";
		# unset ECMD
		if [ "$EOK" == "KO" ];
		then
			printf "${CYAN}\n\n  It seems that there are some tests\n"
			printf "  that have not passed...\n\n"
			printf "  Failure traces -> traces/echo_traces.txt\n"
		fi
		printf "${BLUE}\n|======================================================|\n\n\n${DEF_COLOR}"
	#
#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "${BLUE}  Any issue send via slack bmoll-pe, arebelo or ailopez-o\n\n${DEF_COLOR}"
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell

#
