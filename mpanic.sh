#!/bin/bash

# colors
	DEF_COLOR='\033[0;39m'
	GRAY='\033[0;90m'
	RED='\033[0;91m'
	HARD_RED='\033[1;91m'
	GREEN='\033[0;92m'
	YELLOW='\033[0;93m'
	BLUE='\033[0;94m'
	MAGENTA='\033[0;95m'
	CYAN='\033[0;96m'
	WHITE='\033[0;97m'
	MAIN_COLOR='\033[0;96m'
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  BANNER


	printf ${MAIN_COLOR}"\n\t\t -----------------------"${DEF_COLOR};
	printf ${MAIN_COLOR}"\n\t\t| 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
	printf ${MAIN_COLOR}"\t\t -----------------------\n\n"${DEF_COLOR};


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
	print_color ${GRAY} "Compiling Makefile ... Please wait!${DEF_COLOR}"
	MKFF=$(make -C ../ &> .errors/error.txt)
	MK_1=$?
	MKFF=$(cat .errors/error.txt | cut -c 1-46)

	if [ "$MK_1" != "0" ]; then
		if [ "$MKFF" == "make: *** No targets specified and no makefile" ]; then
			print_color ${RED} "\033[2K\rMakefile not found!\n${DEF_COLOR}"
			echo "Remember to clone it and run as follows:"
			echo "  1. cd minishell_project_folder"
			echo "  2. git clone git@github.com:ChewyToast/minishell_panic.git"
			echo "  3. cd minishell_panic"
			echo "  4. bash mpanic.sh"
			echo ""
			clean_exit
		else
			print_color ${RED} "\033[2K\rCompilation error\n${DEF_COLOR}"
			echo "-------------"
			echo "${DEF_COLOR}$MKFF${DEF_COLOR}"
			echo "-------------"
			clean_exit
		fi
	else
		mkdir traces &> /dev/null
		cp ../minishell .
		chmod 777 minishell &> /dev/null
	fi
	print_color ${GRAY} "\033[2K\r\n Compilation done\n"
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
		ESF=""
	# TEST STATUS
		EOK="OK"
#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

	function trace_printer()
	{
		echo "---------------------------------------------> test [$1]" >> traces/echo_trace.txt
		echo "| CMD: ->$2<-" >> traces/echo_trace.txt
		echo "|--------------------------------" >> traces/echo_trace.txt
		# echo "|" >> traces/echo_trace.txt
		echo "|  EXPECTED (BASH OUTP)  |  exit status: ($3)"$'\n'\| >> traces/echo_trace.txt
		# echo "|       exit status: $4" >> traces/echo_trace.txt
		echo "|--- STDOUT:" >> traces/echo_trace.txt
		echo "|->$4<-" >> traces/echo_trace.txt
		echo "|" >> traces/echo_trace.txt
		echo "|--- STDERR:" >> traces/echo_trace.txt
		echo "|->$5<-" >> traces/echo_trace.txt
		echo "|--------------------------------" >> traces/echo_trace.txt
		echo "|--->FOUND (MINISHELL OUTP)  |  exit status: ($6)"$'\n'\| >> traces/echo_trace.txt
		if [ "$9" == "" ]; then
			echo "|--- STDOUT:" >> traces/echo_trace.txt
			echo "|->$7<-" >> traces/echo_trace.txt
			echo "|" >> traces/echo_trace.txt
			echo "|--- STDERR:" >> traces/echo_trace.txt
			echo "|->$8<-" >> traces/echo_trace.txt
		else
			echo "| SEG FAULT!!" >> traces/echo_trace.txt
			echo "| $9" >> traces/echo_trace.txt
			# echo "| SEG FAULT!!" >> traces/echo_trace.txt
		fi
		echo "|">> traces/echo_trace.txt
		echo "---------------------------------------------<">> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
	}

	function print_test_result()
	{
		if [ "${#i}" == "1" ]; then
			print_color ${BLUE} "  ${i}.  [${DEF_COLOR}"
		else
			if [ "${#i}" == "2" ]; then
				print_color ${BLUE} "  ${i}. [${DEF_COLOR}"
			else
				if [ "${#i}" == "3" ]; then
					print_color ${BLUE} "  ${i}.[${DEF_COLOR}"
				fi
			fi
		fi
		if [ "$ret" == "1" ]; then
			printf "${GREEN}OK${DEF_COLOR}"
		else
			if [ "$ret" == "0" ]; then
				printf "${RED}KO${DEF_COLOR}"
			else
				if [ "$ESF" == "" ]; then
					ESF="$i"
				else
					ESF="$ESF, $i"
				fi
			printf "${HARD_RED}SF${DEF_COLOR}"
			fi
		fi
		print_color ${BLUE} "] - |"
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
		{ ./minishell; } < .tmp/exec_read.txt &> .tmp/exec_other_outp.txt
		{ ./minishell; } < .tmp/exec_read.txt 1> .tmp/exec_outp.txt 2> .tmp/exec_error_outp.txt
		ES1=$?
		< .tmp/exec_read.txt bash 1> .tmp/bash_outp.txt 2> .tmp/bash_error_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		WCTEST1=$(cat -e .tmp/exec_outp.txt | wc -l)
		WCTEST2=$(cat -e .tmp/bash_outp.txt | wc -l)
		if [ $ES1 == "139" ]; then 
			{ ./minishell; } < .tmp/exec_read.txt &> .tmp/exec_other_outp.txt
			SF_TMP=$(cat .tmp/exec_other_outp.txt | sed -e "1d")
		fi
	
		if [ "$WCTEST1" == "       3" ]; then
			TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d")
			# TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "$ d" | sed -e "1d")
			TEST2=$(cat -e .tmp/bash_outp.txt)
		else
			if [[ "$WCTEST1" == "       2" && "$ES1" == "0" ]]; then
				TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "1d" | rev)
				# TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d" | rev )
				TEST1=${TEST1:$size_prom_cat_exit:${#TEST1}}
				TEST1=$(echo "$TEST1" | rev )
				TEST2=$(cat -e .tmp/bash_outp.txt)
			else
				if [[ "$WCTEST1" == "       2" && "$ES1" != "0" ]]; then
					TEST1=$(cat -e .tmp/exec_error_outp.txt)
					TEST2=$(cat -e .tmp/bash_outp.txt)
				else
					TEST1=$(cat -e .tmp/exec_outp.txt)
					TEST2=$(cat -e .tmp/bash_outp.txt)
				fi
			fi
		fi

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [[ "$ES1" != "0" ]]; then
			TEST2=${TEST2:18:${#TEST2}}
			if [[ "$TEST1" == *"$TEST2"* && "$ES2" == "$ES1" ]]; then
				ret=1;
			else
				if [[ "$SF_TMP" == *"Segmentation fault"* ]]; then
					ret=2
				else
					ret=0
				fi
				EOK="KO"
				trace_printer "$i" "$FTEST" "$ES2" "$(cat -e .tmp/bash_outp.txt)" "$(cat -e .tmp/bash_error_outp.txt)" "$ES1" "$TEST1" "$TESTERR" "$SF_TMP";
			fi
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				ret=1
			else
				ret=0
				EOK="KO"
				trace_printer "$i" "$FTEST" "$ES2" "$(cat -e .tmp/bash_outp.txt)" "$(cat -e .tmp/bash_error_outp.txt)" "$ES1" "$TEST1" "$TESTERR" "$SF_TMP";
			fi
		fi
		print_test_result "${FTEST}";
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/exec_error_outp.txt
		echo "" > .tmp/bash_outp.txt
		echo "" > .tmp/bash_weeoe_outp.txt
	}

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
			echo "* This tester doesnt work if ur readline prompt have '\n'    *" >> traces/echo_trace.txt
			echo "*                                                            *" >> traces/echo_trace.txt
			echo "**************************************************************" >> traces/echo_trace.txt
			echo "" >> traces/echo_trace.txt
			printf ${BLUE}"\n\n\n"${DEF_COLOR}
		#

		# SIMPLE TEST ECHO WHILE
			printf "${BLUE} simple\n ------------------------------------\n\n${DEF_COLOR}"
			test_file="./test/echo/echo_tests.txt"
			if [ ! -f "$test_file" ]; then
				printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
			else
				while read -r test_cmd; do
				one_line_test "$test_cmd"
				done < "$test_file"
			fi
		#

		# FLAGS TEST ECHO WHILE
			printf "${BLUE}\n flags\n ------------------------------------\n\n${DEF_COLOR}"
			test_file="./test/echo/echo_flag_tests.txt"
			if [ ! -f "$test_file" ]; then
				printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
			else
				while read -r test_cmd; do
				one_line_test "$test_cmd"
				done < "$test_file"
			fi
		#

		# MIXED TEST ECHO WHILE
			printf "${BLUE}\n export\n ------------------------------------\n\n${DEF_COLOR}"
			test_file="./test/echo/echo_mix_tests.txt"
			if [ ! -f "$test_file" ]; then
				printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
			else
				while read -r test_cmd; do
				export TMPENVVAR="$test_cmd"
				IFS= read -r test_cmd
				one_line_test "$test_cmd"
				done < "$test_file"
				unset TMPENVVAR
			fi
		#

		printf "${RED}\n\n\tmore test comming soon...👹${DEF_COLOR}\n"
		# ECHO RESUME
			if [ "$EOK" == "KO" ]; then
				printf "${BLUE}\n\n  It seems that there are some tests that have not passed...\n\n"
				if [ "$ESF" != "" ]; then
					printf "  and your minishell gives ${RED}segmentation fault!${BLUE} ($ESF)\n\n"
				fi
				printf "  To see full failure traces -> traces/echo_traces.txt\n"
			fi
		#
		printf "${BLUE}\n|======================================================|\n\n\n${DEF_COLOR}"
	#
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "${BLUE}  Any issue send via slack bmoll-pe, arebelo or ailopez-o\n\n${DEF_COLOR}"
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell

#
