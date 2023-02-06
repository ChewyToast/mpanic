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


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE & COMPILATION

	mkdir .errors &> /dev/null
	mkdir .tmp &> /dev/null
	MKFF=$(make -C ../ &> .errors/error.txt)
	MK_1=$?
	MKFF=$(cat .errors/error.txt | cut -c 1-46)
	if [ "$MK_1" != "0" ]; then
		if [ "$MKFF" == "make: *** No targets specified and no makefile" ]; then
			printf ${RED}
			echo "Makefile not found!"
			printf ${DEF_COLOR}"\n"
			echo "Remember to clone it and run as follows:"
			echo "  1. cd minishell_project_folder"
			echo "  2. git clone git@github.com:ChewyToast/minishell_panic.git"
			echo "  3. cd minishell_panic"
			echo "  4. bash mpanic.sh"
			echo ""
			printf ${DEF_COLOR}
			rm -rf .errors
			rm -rf .tmp
			exit
		else
			printf ${RED}
			echo "Compilation error"
			printf ${DEF_COLOR}
			echo "-------------"
			echo "$MKFF"
			echo "-------------"
			rm -rf .errors
			rm -rf .tmp
			exit
		fi
	else
		mkdir traces &> /dev/null
		cp ../minishell .
		chmod 777 minishell &> /dev/null
	fi
	echo "exit" > .tmp/exec_read.txt
	< .tmp/exec_read.txt ./minishell &> .tmp/start.txt

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# var
	EOK="OK"
	prmp=$(cat -e .tmp/start.txt | sed -e "2d")
	size_prom_cat_exit=${#prmp}
	size_prom=$(($size_prom_cat_exit - 5))
	PRMP=$(echo "$prmp" | cut -c 1-$size_prom)
#


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

# >>>> TESTS ECHO


	function tracse_printer()
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
		printf "❌";
		EOK="KO"
	}

	function echo_simple_test()
	{
		# Declaramos variables para funcion
		ARGV=$(echo "$@")
		FTEST=$(echo "$ARGV" | cut -c 6-100)
		PRINT=$(echo "$ARGV" | cut -c 1-5)

		# Preparamos archivo que va a ser el input con los argumentos
		# Print para completar visualizer
		printf "$BLUE  $PRINT$DEF_COLOR"
		echo "$FTEST" > .tmp/exec_read.txt
		echo "exit" >> .tmp/exec_read.txt

		# Ejecutamos minishell y bash con mismos comandos y recojemos ES
		< .tmp/exec_read.txt ./minishell &> .tmp/exec_outp.txt
		ES1=$?
		< .tmp/exec_read.txt bash &> .tmp/bash_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		# TEST1=$(cat -e .tmp/exec_outp.txt)
		TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" | sed -e "1d" | sed -e "$ d")
		TEST2=$(cat -e .tmp/bash_outp.txt)

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [[ "$ES2" == "127" && "$ES1" == "127" && $TEST1 == *"command not found"* ]]; then
			printf "✅";
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				printf "✅";
			else
				TMP=$(echo "$PRINT" | cut -c 1-3)
				tracse_printer "$PRINT" "$TMP" "$FTEST" "$ES2" "$TEST2" "$ES1" "$TEST1";
				EOK="KO"
			fi
		fi
		printf ${BLUE};
		echo -n "]"
		printf ${DEF_COLOR};
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/bash_outp.txt
		sleep 0.05
	}

	function echo_flag_test()
	{
		# Declaramos variables para funcion
		ARGV=$(echo "$1")
		FTEST=$(echo "$ARGV" | cut -c 6-100)
		PRINT=$(echo "$ARGV" | cut -c 1-5)

		# Preparamos archivo que va a ser el input con los argumentos
		# Print para completar visualizer
		printf "$BLUE  $PRINT$DEF_COLOR"
		echo "$FTEST" > .tmp/exec_read.txt
		echo "exit" >> .tmp/exec_read.txt

		# Ejecutamos minishell y bash con mismos comandos y recojemos ES
		< .tmp/exec_read.txt ./minishell &> .tmp/exec_outp.txt
		ES1=$?
		< .tmp/exec_read.txt bash &> .tmp/bash_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		WCTEST1=$(cat -e .tmp/exec_outp.txt | wc -l)
		TEST2=$(cat -e .tmp/bash_outp.txt)

		if [ "$WCTEST1" == "4" ]; then
			TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" -e "1d" | sed -e "$ d" | sed -e "$ d")
		else
			if [ "$size_prom" != "0" ]; then
				TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "1d" | rev)
				TEST1=${TEST1:$size_prom_cat_exit:${#TEST1}}
				TEST1=$(echo -n "$TEST1" | rev)
			else
				TEST1=$(cat -e .tmp/exec_outp.txt)
				# TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "$ d" -e "1d")
				# TEST1=${TEST1:0:-7}
			fi
		fi

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [[ "$ES2" == "127" && "$ES" == "127" ]] && [ "$TEST1" == *"command not found"* ]; then
			printf "✅";
		else
			if [ "$TEST1" == "$TEST2" ] && [ "$ES1" == "$ES2" ]; then
				printf "✅";
			else
				TMP=$(echo "$PRINT" | cut -c 1-3)
				tracse_printer "$PRINT" "$TMP" "$FTEST" "$ES2" "$TEST2" "$ES1" "$TEST1";
				EOK="KO"
			fi
		fi
		printf ${BLUE};
		echo -n "]"
		printf ${DEF_COLOR};
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/bash_outp.txt
		sleep 0.05
	}

	function echo_mix_test()
	{
		# Preparamos archivo que va a ser el input con los argumentos
		FTEST=$(< .tmp/exec_read.txt cat | sed -e "$ d")
		echo "exit" >> .tmp/exec_read.txt
	
		# Ejecutamos minishell y bash con mismos comandos y recojemos ES
		< .tmp/exec_read.txt ./minishell &> .tmp/exec_outp.txt
		# ES1=$?
		ES1="not checked"
		< .tmp/exec_read.txt bash &> .tmp/bash_outp.txt
		ES2=$?

		# Damos valor a variables para comparar, leemos de los archivos de salida
		TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "1d" -e "$ d" | sed -e "1d" | sed -e "$ d")
		TEST2=$(cat -e .tmp/bash_outp.txt)
		# TEST1=$(cat -e .tmp/exec_outp.txt | sed -e "1d" -e "2d" -e "$ d" | sed -e "$ d")

		# Realizamos comparativas y imprimimos resultado y/o resultado en archivo
		if [ "$TEST2" == *"command not found"* ] && [ "$TEST1" == *"command not found"* ]; then
			printf "✅";
		else
			if [ "$TEST1" == "$TEST2" ]; then
				printf "✅";
			else
				tracse_printer "$PRINT" "$1" "$FTEST" "$ES1" "$TEST2" "$ES1" "$TEST1";
				EOK="KO"
			fi
		fi
		printf ${BLUE};
		echo -n "]"
		printf ${DEF_COLOR};
		echo "" > .tmp/exec_outp.txt
		echo "" > .tmp/bash_outp.txt
		sleep 0.05
	}

# >>>>

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  BANNER


	printf ${MAIN_COLOR}"\t\t\t\t    -----------------------"${DEF_COLOR};
	printf ${MAIN_COLOR}"\n\t\t\t\t   | 👹 MINISHELL PANIC 👹 |\n"${DEF_COLOR};
	printf ${MAIN_COLOR}"\t\t\t\t    -----------------------\n\n"${DEF_COLOR};


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TEST CALLS

#ECHO
	printf ${BLUE}"\n|=========================================[ TESTING ]========================================|\n\n\n  "${DEF_COLOR}
	rm -rf traces/echo_trace.txt &> /dev/null
	echo "" > traces/echo_trace.txt
	echo "**************************************************************" >> traces/echo_trace.txt
	echo "*                          CARE!                             *" >> traces/echo_trace.txt
	echo "*                                                            * " >> traces/echo_trace.txt
	echo "* This test doesnt work if ur readline prompt have newlines  *" >> traces/echo_trace.txt
	echo "*                                                            *" >> traces/echo_trace.txt
	echo "**************************************************************" >> traces/echo_trace.txt
	echo "" >> traces/echo_trace.txt
	printf ${BLUE}"\n              ---------------         [ parsing & echo ]         ---------------            \n\n\n     "${DEF_COLOR}
	echo_simple_test '  1.[echo ""     '
	echo_simple_test '  2.[echo'
	echo_simple_test '  3.[echO ""    '
	echo_simple_test '  4.[    echo'
	echo_simple_test '  5.[    echo       " hi"'
	echo_simple_test '  6.["echo" ""   '
	echo_simple_test '  7.[echo hi   '
	echo_simple_test '  8.[EcHo hi   '
	printf "\n\n\n     "
	echo_simple_test '  9.[echo """ ""hi" " """'
	echo_simple_test ' 10.["echo" "'""'"'
	echo_simple_test ' 11.[echo \"hi\"'
	echo_simple_test ' 12.[echo $HOME'
	echo_simple_test ' 13.[echo $USER "" $USER '"'"'$USER'"'"'$ "$USER" "'"'"'$USER'"'"'$ $USER"'"'"'$USER'"'"'"$USER"$'"'"'"$USER"'"'"' "$USER"$nothing$$'
	echo_simple_test ' 14.[echo $NONEXIST'
	echo_simple_test ' 15.["      echo"'
	echo_simple_test ' 16.[\ echo "   " $'
	printf "\n\n\n     "
	echo_simple_test ' 17.[echo hi~'
	echo_simple_test ' 18.[echo ~'
	echo_simple_test ' 19.[echo ~false'
	echo_simple_test ' 20.[echo \~'
	echo_simple_test ' 21.[echo "~"ups'
	echo_flag_test ' 22.[echo -n' '3'
	echo_flag_test ' 23.[echo -n hi' '3'
	echo_flag_test ' 24.[echo -nn' '3'
	printf "\n\n\n     "
	echo_flag_test ' 25.[echo -nn hi' '3'
	echo_simple_test ' 26.[echo --n' '4'
	echo_simple_test ' 27.['"'"'echo'"'"' --n hi' '4'
	echo_flag_test ' 28.[echo -n -n' '3'
	echo_flag_test ' 29.[echo -n -n hi' '3'
	echo_flag_test ' 30.[echo -nn -nn' '3'
	echo_flag_test ' 31.[echo -nn -nn hi' '3'
	echo_flag_test ' 32.[echo -n -n -n -n' '3'
	printf "\n\n\n     "
	echo_flag_test ' 33.[echo -n -n -n -n hi' '3'
	echo_flag_test ' 34.[echo -n -n -n \-n hi' '3'
	echo_flag_test ' 35.[echo -nn hi --n' '3'
	echo_flag_test ' 36.[echo \-nn hi --n' '4'
	echo_flag_test ' 37.[echo -nn hi --n' '3'
	echo_flag_test ' 38.[echo "-nn" hi -n' '3'
	echo_simple_test ' 39.[echo -------------nnnnnnnnnn hi' '4'
	echo_simple_test ' 40.[echo "-------------nnnnnnnnnn" hi' '4'
	printf "\n\n\n     "
	# printf ${BLUE}"\n\n\n              ---------------         [ echo plus ]         ---------------            \n\n  "${DEF_COLOR}
	export ECMD="echo" &> /dev/null
	echo_simple_test ' 41.[$ECMD'
	echo_simple_test ' 42.[$ECMD "hi"'
	export ECMD="EchO" &> /dev/null
	echo_simple_test ' 43.[$ECMD'
	export ECMD="EChO" &> /dev/null
	echo_simple_test ' 44.[$ECMD "hi"'
	export ECMD="         echo" &> /dev/null
	echo_simple_test ' 45.[$ECMD "hi"'
	export ECMD="         EcHO       " &> /dev/null
	echo_simple_test ' 46.[$ECMD " hi"'
	unset ECMD
	printf ${BLUE};
	echo -n "   47.["
	printf ${DEF_COLOR};
	echo 'export ECMD="echo"
	$ECMD "hi"' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "47";
	printf ${BLUE};
	echo -n "   48.["
	printf ${DEF_COLOR};
	echo 'export ECMD="EchO"
	$ECMD " hi"' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "48";
	printf "\n\n\n     "
	printf ${BLUE};
	echo -n "   49.["
	printf ${DEF_COLOR};
	echo 'export ECMD="         EcHO       "
	$ECMD "hi"' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "49";
	printf ${BLUE};
	echo -n "   50.["
	printf ${DEF_COLOR};
	echo 'export ECMD="         EcHO      hi "
	$ECMD' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "50";
	printf ${BLUE};
	echo -n "   51.["
	printf ${DEF_COLOR};
	echo 'export ECMD="         '"'"'echo'"'"'      hi "
	$ECMD' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "51";
	printf ${BLUE};
	echo -n "   52.["
	printf ${DEF_COLOR};
	echo 'export ECMD="         "echo"      hi "
	$ECMD' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "52";
	printf ${BLUE};
	echo -n "   53.["
	printf ${DEF_COLOR};
	echo 'export PATH="."
	echo hola' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "53";
	printf ${BLUE};
	echo -n "   53.["
	printf ${DEF_COLOR};
	echo 'export PATH="."
	echo hola' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "53";
	printf ${BLUE};
	echo -n "   54.["
	printf ${DEF_COLOR};
	echo 'unset PATH
	echo $USER*1' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "54";
	printf ${BLUE};
	echo -n "   55.["
	printf ${DEF_COLOR};
	echo 'unset HOME
	echo "~"$USER' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "55";
	printf "\n\n\n     "
	printf ${BLUE};
	echo -n "   56.["
	printf ${DEF_COLOR};
	echo 'unset HOME
	echo "~"$USER' > .tmp/exec_read.txt
	echo "exit" >> .tmp/exec_read.txt
	echo_mix_test "56";
	if [ "$EOK" == "KO" ];
	then
		printf "\n\n\n\n\n"
		printf ${BLUE}"     It seems that there are some tests that have not passed...\n"
		printf ${BLUE}"     To see the failure traces, check in traces/echo_traces.txt\n"
	fi
	printf ${BLUE}"\n\n|===========================================================================================|\n\n"
# #

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

# # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "     Any issue send via slack bmoll-pe or ailopez-o\n\n"${DEF_COLOR}
	rm -rf .errors
	rm -rf .tmp
	rm -rf minishell

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
