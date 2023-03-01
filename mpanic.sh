#!/bin/bash

# Colors
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

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  UTILS

	function	print_helper()
	{
		echo -e "\n${BLUE} Usage:${DEF_COLOR} bash mpanic.sh [options] [arguments]\n"
		echo -e "${BLUE} Options:${DEF_COLOR}"
		echo -e "\t-h --help\tShow this help message"
		echo -e "\n${BLUE} Arguments:${DEF_COLOR}"
		echo -e "\techo\t\tExecute the echo test"
		echo -e "\texport\t\tExecute the export test"
		echo -e "\n${YELLOW} Examples:${DEF_COLOR}"
		echo -e "\t bash mpanic.sh --help"
		echo -e "\t bash mpanic.sh echo"
		echo -e "\n If no arguments are provided, all tests will be executed.\n"
		exit 0
	}

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

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

	function trace_printer()
	{
		echo "---------------------------------------------> test [$1]" >> traces/echo_trace.txt
		echo "| CMD: ->$2<-" >> traces/echo_trace.txt
		echo "|--------------------------------" >> traces/echo_trace.txt
		echo "|  EXPECTED (BASH OUTP)  |  exit status: ($3)"$'\n'\| >> traces/echo_trace.txt
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
		fi
		echo "|">> traces/echo_trace.txt
		echo "---------------------------------------------<">> traces/echo_trace.txt
		echo >> traces/echo_trace.txt
	}

	function print_test_result()
	{
		if [ "${#i}" == "1" ]; then
			print_color ${BLUE} "  ${i}.   [${DEF_COLOR}"
		else
			if [ "${#i}" == "2" ]; then
				print_color ${BLUE} "  ${i}.  [${DEF_COLOR}"
			else
				if [ "${#i}" == "3" ]; then
					print_color ${BLUE} "  ${i}. [${DEF_COLOR}"
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
	
	function first_tester_function()
	{
		# Declaramos variables para funcion
		SF_TMP=""
		let "i=i+1"
		FTEST=$(echo "$1")

		# Preparamos archivo que va a ser el input con los argumentos
		echo "$FTEST" > .tmp/exec_read.txt
		echo "exit" >> .tmp/exec_read.txt

		# Ejecutamos minishell y bash con mismos comandos y recojemos ES
		{ ./minishell; } < .tmp/exec_read.txt 1> .tmp/exec_outp.txt 2> .tmp/exec_error_outp.txt
		ES1=-$?
		< .tmp/exec_read.txt bash 1> .tmp/bash_outp.txt 2> .tmp/bash_error_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		WCTEST1=$(cat -e .tmp/exec_outp.txt | wc -l)
		WCTEST2=$(cat -e .tmp/bash_outp.txt | wc -l)
		if [ $ES1 == "139" ]; then 
			{ ./minishell; } < .tmp/exec_read.txt &> .tmp/exec_other_outp.txt
			SF_TMP=$(cat .tmp/exec_other_outp.txt | sed -e "1d")
		fi
	
		
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
				TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d")
				TEST2=$(cat -e .tmp/bash_outp.txt)
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
		print_test_result "${FTEST}" "$2";
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/exec_error_outp.txt
		echo "" > .tmp/bash_outp.txt
		echo "" > .tmp/bash_weeoe_outp.txt
	}

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TEST CALLS

	#ECHO
		function echo_test_call()
		{
			if [ "$TTECHO" != "" ]; then
				return ;
			fi
			printf ${BLUE}"\n|==========================[ ECHO ]==========================|"${DEF_COLOR}
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
					first_tester_function "$(echo "$test_cmd" | cut -d'@' -f1)" "$(echo "$test_cmd" | cut -d'@' -f2-)"
					# first_tester_function "$test_cmd"
					done < "$test_file"
				fi
			#

			# FLAGS TEST ECHO WHILE
				printf "${BLUE}\n with flag\n ------------------------------------\n\n${DEF_COLOR}"
				test_file="./test/echo/echo_flag_tests.txt"
				if [ ! -f "$test_file" ]; then
					printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
				else
					while read -r test_cmd; do
					first_tester_function "$(echo "$test_cmd" | cut -d'@' -f1)" "$(echo "$test_cmd" | cut -d'@' -f2-)"
					done < "$test_file"
				fi
			#

			# MIXED TEST ECHO WHILE
				printf "${BLUE}\n with env variables\n ------------------------------------\n\n${DEF_COLOR}"
				test_file="./test/echo/echo_mix_tests.txt"
				if [ ! -f "$test_file" ]; then
					printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
				else
					while read -r test_cmd; do
					export TMPENVVAR="$test_cmd"
					IFS= read -r test_cmd
					first_tester_function "$(echo "$test_cmd" | cut -d'@' -f1)" "$(echo "$test_cmd" | cut -d'@' -f2-)"
					done < "$test_file"
					unset TMPENVVAR
				fi
			#

			# ECHO RESUME
				if [ "$EOK" == "KO" ]; then
					printf "${BLUE}\n\n  It seems that there are some tests that have not passed...\n\n"
					if [ "$ESF" != "" ]; then
						printf "  and your minishell gives ${RED}segmentation fault!${BLUE} ($ESF)\n\n"
					fi
					printf "  To see full failure traces -> traces/echo_traces.txt\n"
				fi
			#
			TTECHO="1";
			printf "${BLUE}\n|============================================================|\n\n\n${DEF_COLOR}"
		}
	#

	#EXPORT
		function export_test_call()
		{
			if [ "$TTEXPORT" != "" ]; then
				return ;
			fi
			EOK="OK"
			ESF=""
			printf ${BLUE}"\n|=========================[ EXPORT ]=========================|\n\n"${DEF_COLOR}
			rm -rf traces/export_trace.txt &> /dev/null

			# PRINT IN TRACES
				echo "" > traces/export_trace.txt
				echo "**************************************************************" >> traces/echo_trace.txt
				echo "*                          CARE!                             *" >> traces/echo_trace.txt
				echo "*                                                            * " >> traces/echo_trace.txt
				echo "* This tester doesnt work if ur readline prompt have '\n'    *" >> traces/echo_trace.txt
				echo "*                                                            *" >> traces/echo_trace.txt
				echo "**************************************************************" >> traces/echo_trace.txt
				echo "" > traces/export_trace.txt
			#
			# SIMPLE TEST ECHO WHILE
				test_file="./test/export/export_tests.txt"
				if [ ! -f "$test_file" ]; then
					printf "${RED} File needed to test $test_file not found\n\n${DEF_COLOR}"
				else
					while read -r test_cmd; do
					first_tester_function "$(echo "$test_cmd" | cut -d'@' -f1)" "$(echo "$test_cmd" | cut -d'@' -f2-)"
					# first_tester_function "$test_cmd"
					done < "$test_file"
				fi
			#

			# EXPORT RESUME
				if [ "$EOK" == "KO" ]; then
					printf "${BLUE}\n\n  It seems that there are some tests that have not passed...\n\n"
					if [ "$ESF" != "" ]; then
						printf "  and your minishell gives ${RED}segmentation fault!${BLUE} ($ESF)\n\n"
					fi
					printf "  To see full failure traces -> traces/export_traces.txt\n"
				fi
			#

			TTEXPORT="1";
			printf "${BLUE}\n|===============================================================|\n\n${DEF_COLOR}"
		}
	#

#

#############################################################################

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  BANNER

	if [[ "$(ls -la)" != *".timmer"* ]]; then
		touch .timmer
		printf ${MAIN_COLOR}"\n\tWellocme to minishell panic 👹 !\n\n"${DEF_COLOR};
		printf ${BLUE}" It looks like its ur first time using this tester,\n";
		printf ${BLUE}" so let me explain u how it works:\n${DEF_COLOR}";
		print_helper;
		exit;
	fi

	if [ "$#" == "1" ] && [[ "$1" == "-h" || "$1" == "--help" ]]; then
		print_helper;
	fi

	printf ${MAIN_COLOR}"\n\t\t    -----------------------"${DEF_COLOR};
	printf ${MAIN_COLOR}"\n\t\t   | 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
	printf ${MAIN_COLOR}"\t\t    -----------------------\n\n"${DEF_COLOR};

	for arg in "$@"
	do
		case "$arg" in
			"echo"|"export"|"-h") ;;
			*) printf "\n Invalid argument:"${DEF_COLOR}" $arg\n Type "${BLUE}"--help"${DEF_COLOR}" to see the valid options\n\n"${DEF_COLOR} && exit 1 ;;
		esac
	done
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
	printf ${BLUE}"\n CARE!\n This tester doesnt work if ur readline prompt have newline\n"${DEF_COLOR}

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
	# Echo done
		TTECHO=""
	# Export done
		TTEXPORT=""
	
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  EXECUTOR

	if [[ "$#" != "0" ]]; then
		for arg in "$@"
		do
			case "$arg" in
				"echo") echo_test_call ;;
				"export") export_test_call ;;
			esac
		done
	else
		echo_test_call;
		export_test_call;
	fi

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "${RED}\n\tmore test comming soon...👹${DEF_COLOR}\n\n"
	printf "${BLUE}  Any issue send via slack bmoll-pe, arebelo or ailopez-o\n\n${DEF_COLOR}"
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell
	printf ${DEF_COLOR};

#
