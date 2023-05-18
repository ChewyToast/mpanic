#!/bin/bash

# Colors
	MAIN_COLOR='\033[38;5;247m'
	DEF_COLOR='\033[0;39m'
	RED='\033[0;91m'
	GREEN='\033[0;92m'
	YELLOW='\033[0;93m'
	CYAN='\033[0;96m'
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  UTILS

	function	print_helper()
	{
		echo -e "\n${YELLOW} Usage:${MAIN_COLOR} bash mpanic.sh [options] [arguments]\n"
		echo -e "${YELLOW} Options:${MAIN_COLOR}"
		echo -e "\t-h --help\tShow this help message"
		echo -e "\t-b --bonus\tWill execute the tester with bonus tests"
		echo -e "\t-i --ignore\tWill run all tests except those specified by argument\n\t\t\t(compatible with bonus option)"
		echo -e "\n${YELLOW} Arguments:${MAIN_COLOR}"
		echo -e "\techo\t\tExecute the echo tests"
		echo -e "\texport\t\tExecute the export tests"
		echo -e "\tenv\t\tExecute the env tests"
		echo -e "\texit\t\tExecute the exit tests"
		echo -e "\tdirectory\tExecute the directory tests"
		echo -e "\tparser\t\tExecute the parser tests"
		echo -e "\tpipe\t\tExecute the pipe tests"
		echo -e "\tredirection\tExecute the redirection tests"
		echo -e "\tstatus\t\tExecute the exit status tests"
		echo -e "\tshlvl\t\tExecute the shlvl tests"
		echo -e "\tpanicm\t\tExecute the panic mandatory tests"
		echo -e "\tpanics\t\tExecute the panic scapes tests"
		echo -e "\tyour\t\tExecute the exit status tests"
		echo -e "\n${YELLOW} Examples:${MAIN_COLOR}"
		echo -e "\tmpanic.sh --help\tShow this help message"
		echo -e "\tmpanic.sh -b echo\tExecute only the echo tests with bonus"
		echo -e "\tmpanic.sh -b -i echo\tExecute all the tests with bonus except the echo one"
		echo -e "\tmpanic.sh parser pipe\tExecute the parser and pipe status tests"
		echo -e "\n If no arguments are provided, all tests will be executed.\n"
		exit 0
	}

	function	print_in_traces()
	{
		echo "" > ${1}
		echo "**************************************************************" >> ${1}
		echo "*                          CARE!                             *" >> ${1}
		echo "*                                                            * " >> ${1}
		echo "* This tester doesnt work if ur readline prompt have '\n'    *" >> ${1}
		echo "*                                                            *" >> ${1}
		echo "**************************************************************" >> ${1}
		echo "" >> ${1}
		printf ${MAIN_COLOR}"\n\n\n"${MAIN_COLOR}
	}

	function	print_end_tests()
	{
		if [ "${1}" == "KO" ]; then
			printf "${MAIN_COLOR}\n\n  It seems that there are some tests that have not passed..."
			if [ "$ESF" != "" ]; then
				printf "\n  and your minishell gives ${RED}segmentation fault${MAIN_COLOR} at tests:\n  [${2} ]"
			fi
			printf "\n\n  To see full failure traces -> ${3}\n"
		else
			rm -rf ${3} &> /dev/null
			printf "${MAIN_COLOR}\n\n  All ${4} test passed successfully!!"
		fi
		printf "\n"
	}

	function	clean_exit()
	{
		rm -rf .errors
		rm -rf cleaner
		rm -rf .tmp
		rm -rf minishell
		printf ${DEF_COLOR};
		exit
	}

	function	print_color()
	{
		printf "$1"
		printf "$2"
		printf ${MAIN_COLOR}	
	}

	function	trace_printer()
	{
		echo "---------------------------------------------> test [${2}]" >> ${1}
		echo " CMD: ->${3}<-" | sed 's/^/| /' >> ${1}
		echo "|--------------------------------" >> ${1}
		echo "|  EXPECTED (BASH OUTP)  |  exit status: (${4})"$'\n'\| >> ${1}
		echo "|--- STDOUT:" >> ${1}
		echo "->${5}<-" | sed 's/^/| /' >> ${1}
		echo "|" >> ${1}
		echo "|--- STDERR:" >> ${1}
		echo "->${11}<-" | sed 's/^/| /' >> ${1}
		echo "|">> ${1}
		echo "|--- COMPARED STR:" >> ${1}
		echo "->${6}<-" | sed 's/^/| /' >> ${1}
		echo "|--------------------------------" >> ${1}
		echo "|--->FOUND (MINISHELL OUTP)  |  exit status: (${7})"$'\n'\| >> ${1}
		if [ "${10}" == "" ]; then
			echo "|--- STDOUT:" >> ${1}
			echo "->${8}<-" | sed 's/^/| /' >> ${1}
			echo "|" >> ${1}
			echo "|--- STDERR:" >> ${1}
			echo "->${9}<-" | sed 's/^/| /' >> ${1}
		else
			echo "${10}" | sed 's/^/| /' >> ${1}
		fi
		echo "|">> ${1}
		echo "---------------------------------------------<">> ${1}
		echo >> ${1}
	}

	function	print_test_result()
	{
		if [ "$2" ]; then msg=$2
		else msg=$1
		fi

		case ${#i} in
			1) printf "${MAIN_COLOR}  ${i}.   |${MAIN_COLOR}" ;;
			2) printf "${MAIN_COLOR}  ${i}.  |${MAIN_COLOR}" ;;
			3) printf "${MAIN_COLOR}  ${i}. |${MAIN_COLOR}" ;;
		esac

		if [ ${#msg} -gt 47 ]; then
			msg=${msg:0:40}"..."
		fi

		case $ret in
			0) printf "${RED}%s${MAIN_COLOR}|" "$msg" ;;
			1) printf "${GREEN}%s${MAIN_COLOR}|" "$msg" ;;
			*) printf "${RED}%s${MAIN_COLOR}|" "$msg" ;;
		esac

		local padding=$(( 47 - ${#msg} ))

		if [ $padding -gt 0 ]; then
			printf "%0.s " $(seq 1 $padding 2> /dev/null)
		fi

		case $ret in
			0) printf "[${RED}K0${MAIN_COLOR}]\n" ;;
			1) printf "[${GREEN}OK${MAIN_COLOR}]\n" ;;
			*) printf "[${YELLOW}SF${MAIN_COLOR}]\n" ;;
		esac
	}

	function	add_summary()
	{
		printf -v SUMARY "%s\n  %-30s  ${GREEN}%3d${MAIN_COLOR}    ${RED}%3d${MAIN_COLOR}    ${RED}%3d${MAIN_COLOR}    %3d" "${SUMARY}" "[${1}]" ${2} ${3} ${4} $((${2}+${3}+${4}))
	}

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TESTS FUNCTIONS

	function exec_function()
	{
		SF_TMP=""
		let "i=i+1"
		echo $'\n' >> ${2}


		{ ./minishell; } < ${2} 1> .tmp/exec_outp.txt 2> .tmp/exec_error_outp.txt
		ES1=$?
		./cleaner ".tmp/exec_outp.txt"
		MINI_STDOUTP=$(cat -e .tmp/exec_outp_clean.txt 2> /dev/null)
		MINI_ERROUTP_ALL=$(cat -e .tmp/exec_error_outp.txt 2> /dev/null)
		MINI_ERROUTP=$(cat -e .tmp/exec_error_outp.txt 2> /dev/null)
	
		{ bash; } < ${2} 1> .tmp/bash_outp.txt 2> .tmp/bash_error_outp.txt
		ES2=$?
		BASH_STDOUTP=$(cat -e .tmp/bash_outp.txt 2> /dev/null)
		BASH_ERROUTP=$(cat -e .tmp/bash_error_outp.txt 2> /dev/null)
		BASH_ERROUTP_CUT=$(head -n 1 .tmp/bash_error_outp.txt 2> /dev/null)
		if [ -n "$BASH_ERROUTP_CUT" ]; then
			BASH_ERROUTP_CUT="${BASH_ERROUTP_CUT:14}"
			if [ ${#BASH_ERROUTP_CUT} -ge 9 ] && [[ "$BASH_ERROUTP_CUT" == *"syntax error"* ]]; then
				BASH_ERROUTP_CUT="${BASH_ERROUTP_CUT%?????????}"
			fi
		fi


		std_condition=$( [[ "${MINI_STDOUTP}" == "${BASH_STDOUTP}" ]] && echo "true" || echo "false" )
		err_condition=$( [[ "${BASH_ERROUTP_CUT}" == "" && "${MINI_ERROUTP}" == "${BASH_ERROUTP_CUT}" ]] || [[ "${BASH_ERROUTP_CUT}" != "" && "${MINI_ERROUTP}" == *"${BASH_ERROUTP_CUT}"* ]] && echo "true" || echo "false" )
		es_condition=$( [[ "${ES1}" == "${ES2}" ]] && echo "true" || echo "false" )


		if [ "${ES1}" == "139" ] || [ "${ES1}" == "134" ] || [ "${ES1}" == "136" ] || [ "${ES1}" == "137" ] || [ "${ES1}" == "138" ]; then
			{ ./minishell; } < ${2} &> .tmp/exec_other_outp.txt
			TOTAL_SF_COUNT=$((TOTAL_SF_COUNT+1))
			SF_COUNT=$((SF_COUNT+1))
			ret=3
			EOK="KO"
			ESF="${ESF} ${i}"
			SF_TMP=$(cat .tmp/exec_other_outp.txt | sed -e "1d" 2> /dev/null)
			trace_printer "${1}" "${i}" "$(cat ${2})" "${ES2}" "${BASH_STDOUTP}" "${BASH_ERROUTP_CUT}" "${ES1}" "${MINI_STDOUTP}" "${MINI_ERROUTP}" "${SF_TMP}" "${BASH_ERROUTP}";
		else
			if [[ "${std_condition}" == "true" && "${es_condition}" == "true" && "${err_condition}" == "true" ]]; then
				trace_printer "traces/correct_log.txt" "${i}" "$(cat ${2} 2> /dev/null)" "${ES2}" "${BASH_STDOUTP}" "${BASH_ERROUTP_CUT}" "${ES1}" "${MINI_STDOUTP}" "${MINI_ERROUTP}" "${SF_TMP}" "${BASH_ERROUTP}";
				TOTAL_OK_COUNT=$((TOTAL_OK_COUNT+1))
				OK_COUNT=$((OK_COUNT+1))
				ret=1
			else
				TOTAL_KO_COUNT=$((TOTAL_KO_COUNT+1))
				KO_COUNT=$((KO_COUNT+1))
				ret=0
				EOK="KO"
				trace_printer "${1}" "${i}" "$(cat ${2} 2> /dev/null)" "${ES2}" "${BASH_STDOUTP}" "${BASH_ERROUTP_CUT}" "${ES1}" "${MINI_STDOUTP}" "${MINI_ERROUTP}" "${SF_TMP}" "${BASH_ERROUTP}";
			fi
		fi

		print_test_result "${4}" "${3}";
		echo -n "" > .tmp/exec_read.txt
		echo -n "" > .tmp/exec_outp_clean.txt
		echo -n "" > .tmp/exec_outp.txt
		echo -n "" > .tmp/exec_error_outp.txt
		echo -n "" > .tmp/bash_outp.txt
	}

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  TEST CALLS

	function main_test_call()
	{
		# Nombre del archivo a leer
		test_file="./test/${1}"
		if [ ! -f "${test_file}" ]; then
			printf "\n${RED} File needed to test ${test_file} not found\n\n${MAIN_COLOR}"
		else
			while read test_cmd; do
				if [ "${#test_cmd}" != "0" ]; then
					if [[ "$(echo "${test_cmd}" | cut -c1)" != "#" ]]; then
						echo -n "" > .tmp/exec_read.txt
						IFS=';' read -ra fragments <<< "${test_cmd}"
						rest_of_line=""
						for fragment in "${fragments[@]}"; do
							if [[ "$fragment" == *"@"* ]]; then
								rest_of_line=$(echo "$fragment" | cut -d'@' -f2-)
								echo $(echo "$fragment" | cut -d'@' -f1) >> .tmp/exec_read.txt
								break
							else
								rest_of_line=$fragment
								echo $(echo "$fragment" | cut -d'@' -f1) >> .tmp/exec_read.txt
							fi
						done
						exec_function "${3}" ".tmp/exec_read.txt" "${rest_of_line}" "${rest_of_line}"
					else
						eval ${test_cmd:1} 2> /dev/null
					fi
				fi
			done < "$test_file"
		fi
	}

	function echo_test_call()
	{
		if [ "$TTECHO" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		printf ${MAIN_COLOR}"\n|==========================[ ECHO ]==========================|"${MAIN_COLOR}
		print_in_traces "traces/echo_trace.txt"
		main_test_call "mandatory/echo/echo.txt" "exec_function" "traces/echo_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/echo/echo.txt" "exec_function" "traces/echo_trace.txt"
		fi
		add_summary "echo" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/echo_trace.txt" "echo"
		TTECHO="1";
	}

	function export_test_call()
	{
		if [ "$TTEXPORT" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=========================[ EXPORT ]=========================|"${MAIN_COLOR}
		print_in_traces "traces/export_trace.txt"
		main_test_call "mandatory/export/export.txt" "exec_function" "traces/export_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/export/export.txt" "exec_function" "traces/export_trace.txt"
		fi
		add_summary "export" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/export_trace.txt" "export"
		TTEXPORT="1";
	}

	function env_test_call()
	{
		if [ "$TTENV" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|===========================[ ENV ]==========================|"${MAIN_COLOR}
		print_in_traces "traces/env_trace.txt"
		main_test_call "mandatory/env/env.txt" "exec_function" "traces/env_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/env/env.txt" "exec_function" "traces/env_trace.txt"
		fi
		add_summary "env" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/env_trace.txt" "env"
		TTENV="1";
	}

	function exit_test_call()
	{
		if [ "$TTEXIT" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|==========================[ EXIT ]==========================|"${MAIN_COLOR}
		print_in_traces "traces/exit_trace.txt"
		main_test_call "mandatory/exit/exit.txt" "exec_function" "traces/exit_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/exit/exit.txt" "exec_function" "traces/exit_trace.txt"
		fi
		add_summary "exit" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/exit_trace.txt" "exit"
		TTEXIT="1";
	}

	function directory_test_call()
	{
		if [ "$TTDIR" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|========================[ DIRECTORY ]=======================|"${MAIN_COLOR}
		print_in_traces "traces/directory_trace.txt"
		main_test_call "mandatory/dir/dir.txt" "exec_function" "traces/directory_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/dir/dir.txt" "exec_function" "traces/directory_trace.txt"
		fi
		add_summary "directory" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/directory_trace.txt" "directory"
		TTDIR="1";
	}

	function parser_test_call()
	{
		if [ "$TTPARSER" != "" ]; then
			return ;
		fi
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=========================[ PARSER ]=========================|"${MAIN_COLOR}
		mkdir traces/parse &> /dev/null
		print_in_traces "traces/parse/dollar_trace.txt" &> /dev/null
		print_in_traces "traces/parse/quotes_trace.txt" &> /dev/null
		print_in_traces "traces/parse/spaces_trace.txt" &> /dev/null
		print_in_traces "traces/parse/tilde_trace.txt" &> /dev/null
		print_in_traces "traces/parse/syntax_error_trace.txt" &> /dev/null
		printf "\n\n    ----------------------[ dollar ]---------------------\n\n"
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		main_test_call "mandatory/parser/dollar.txt" "exec_function" "traces/parse/dollar_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/parser/dollar.txt" "exec_function" "traces/parse/dollar_trace.txt"
		fi
		add_summary "dollars" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		printf "\n    ----------------------[ quotes ]---------------------\n\n"
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		main_test_call "mandatory/parser/quotes.txt" "exec_function" "traces/parse/quotes_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/parser/quotes.txt" "exec_function" "traces/parse/quotes_trace.txt"
		fi
		add_summary "quotes" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		printf "\n    ----------------------[ spaces ]---------------------\n\n"
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		main_test_call "mandatory/parser/spaces.txt" "exec_function" "traces/parse/spaces_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/parser/spaces.txt" "exec_function" "traces/parse/spaces_trace.txt"
		fi
		add_summary "spaces" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		printf "\n    -----------------------[ tilde ]---------------------\n\n"
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		main_test_call "mandatory/parser/tilde.txt" "exec_function" "traces/parse/tilde_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/parser/tilde.txt" "exec_function" "traces/parse/tilde_trace.txt"
		fi
		add_summary "tilde" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		printf "\n    -------------------[ syntax_error ]------------------\n\n"
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		main_test_call "mandatory/parser/syntax_error.txt" "exec_function" "traces/parse/syntax_error_trace.txt"
		add_summary "syntax_error" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		if [ ${TESTER_MODE} == "bonus" ]; then
			print_in_traces "traces/parse/operators_trace.txt" &> /dev/null
			main_test_call "bonus/parser/syntax_error.txt" "exec_function" "traces/parse/operators_trace.txt"
			printf "\n    ---------------------[ operators ]---------------------\n\n"
			OK_COUNT=0
			KO_COUNT=0
			SF_COUNT=0
			main_test_call "bonus/parser/operators.txt" "exec_function" "traces/parse/operators_trace.txt"
			add_summary "operators" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		fi
		print_end_tests "${EOK}" "${ESF}" "traces/parse/*.txt" "parser"
		TTPARSER="1";
	}

	function pipe_test_call()
	{
		if [ "$TTPIPE" != "" ]; then
			return ;
		fi
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=========================[ PIPES ]==========================|"${MAIN_COLOR}
		print_in_traces "traces/pipes_trace.txt"
		main_test_call "mandatory/pipe/pipe.txt" "exec_function" "traces/pipes_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/pipe/pipe.txt" "exec_function" "traces/pipes_trace.txt"
		fi
		add_summary "pipe" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/pipes_trace.txt" "pipe"
		TTPIPE="1";
	}

	function redirection_test_call()
	{
		if [ "$TTREDIRECT" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|======================[ REDIRECTIONS ]======================|"${MAIN_COLOR}
		print_in_traces "traces/redirection_trace.txt"
		main_test_call "mandatory/redirection/redirection.txt" "exec_function" "traces/redirection_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/redirection/redirection.txt" "exec_function" "traces/redirection_trace.txt"
		fi
		add_summary "redirection" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/redirection_trace.txt" "redirection"
		TTREDIRECT="1";
	}

	function status_test_call()
	{
		if [ "$TTSTATUS" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=========================[ STATUS ]=========================|"${MAIN_COLOR}
		print_in_traces "traces/status_trace.txt"
		main_test_call "mandatory/status/status.txt" "exec_function" "traces/status_trace.txt"
		if [ ${TESTER_MODE} == "bonus" ]; then
			main_test_call "bonus/status/status.txt" "exec_function" "traces/status_trace.txt"
		fi
		add_summary "status" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		print_end_tests "${EOK}" "${ESF}" "traces/status_trace.txt" "status"
		TTSTATUS="1";
	}

	function shlvl_test_call()
	{
		if [ "$TTSHL" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=======================[ SHLVL TESTS ]======================|"${MAIN_COLOR}
		print_in_traces "traces/shlvl_trace.txt"
		main_test_call "mandatory/shlvl/shlvl.txt" "exec_function" "traces/shlvl_trace.txt"
		print_end_tests "${EOK}" "${ESF}" "traces/shlvl_trace.txt" "shlvl"
		add_summary "shlvl" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		TTSHL="1";
	}

	function your_test_call()
	{
		if [ "$TTYOUR" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|=======================[ YOUR TESTS ]=======================|"${MAIN_COLOR}
		print_in_traces "traces/your_trace.txt"
		main_test_call "your_tests.txt" "exec_function" "traces/your_trace.txt"
		print_end_tests "${EOK}" "${ESF}" "traces/your_trace.txt" "your"
		add_summary "your" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		TTYOUR="1";
	}

	function panic_mandatory_test_call()
	{
		rm-rf traces/panic/panic_mandatory.txt &> /dev/null
		mkdir traces/panic &> /dev/null
		if [ "$TTPM" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|====================[ PANIC MANDATORY ]=====================|"${MAIN_COLOR}
		print_in_traces "traces/panic/panic_mandatory.txt"
		main_test_call "panic/panic_mandatory/panic_mandatory.txt" "exec_function" "traces/panic/panic_mandatory.txt"
		print_end_tests "${EOK}" "${ESF}" "traces/panic/panic_mandatory.txt" "panic mandatory"
		add_summary "panic mandatory" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		TTPM="1";
	}

	function panic_scapes_test_call()
	{
		rm-rf traces/panic/panic_scapes.txt &> /dev/null
		mkdir traces/panic &> /dev/null
		if [ "$TTPS" != "" ]; then
			return ;
		fi
		OK_COUNT=0
		KO_COUNT=0
		SF_COUNT=0
		EOK="OK"
		ESF=""
		printf ${MAIN_COLOR}"\n|======================[ PANIC SCAPES ]======================|"${MAIN_COLOR}
		print_in_traces "traces/panic/panic_scapes.txt"
		main_test_call "panic/scapes/scapes.txt" "exec_function" "traces/panic/panic_scapes.txt"
		print_end_tests "${EOK}" "${ESF}" "traces/panic/panic_scapes.txt" "panic scapes"
		add_summary "panic scapes" "${OK_COUNT}" "${KO_COUNT}" "${SF_COUNT}"
		TTPS="1";
	}

#

#############################################################################

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PARSER

	if [[ "$(ls -la)" != *".timmer"* ]]; then
		touch .timmer
		printf ${MAIN_COLOR}"\n\tWellocme to minishell panic 👹 !\n\n"${MAIN_COLOR};
		printf " It looks like its ur first time using this tester,\n";
		printf " so let me explain u how it works:\n";
		print_helper;
	fi

	# Test mode
		TESTER_MODE="mandatory"
		IGNORE="0"
	for arg in "$@"
	do
		case "$arg" in
			"-h"|"--help") print_helper ;;
			"-i"|"--ignore") IGNORE="1" ;;
			"echo"|"export"|"exit"|"parser"|"pipe"|"redirection"|"status"|"env"|"directory"|"shlvl"|"your"|"panicm"|"panics") ;;
			"-b"|"--bonus") TESTER_MODE="bonus" ;;
			*) printf "\n Invalid argument:"${MAIN_COLOR}" $arg\n" 
				print_helper
				clean_exit;;
		esac
	done

	if [ "$#" == "1" ] && [[ "$1" == "-h" || "$1" == "--help" ]]; then
		print_helper;
	fi

	printf ${RED}"\n\t\t    -----------------------"${MAIN_COLOR};
	printf ${RED}"\n\t\t   | 👹 MINISHELL PANIC 👹 |\n"${MAIN_COLOR};
	printf ${RED}"\t\t    -----------------------\n\n"${MAIN_COLOR};

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE & COMPILATION

	INPUT_FILE=cleaner.c

	if [ -r "$INPUT_FILE" ]; then
		error_message=$(gcc -Wall -Wextra -Werror -Wpedantic -Werror=pedantic -pedantic-errors -Wcast-align -Wcast-qual -Wdisabled-optimization -Wformat=2 -Wuninitialized -Winit-self -Wmissing-include-dirs -Wredundant-decls -Wshadow -Wstrict-overflow=5 -Wundef -fdiagnostics-show-option -fstack-protector-all $INPUT_FILE -o cleaner 2>&1)
		if echo "$error_message" | grep -q "error:"; then
			echo "Compilation error in file: cleaner.c:"$'\n'"$error_message"$'\n'
			exit 1
		fi
	else
		echo "Error: File $INPUT_FILE does not exist or does not have read permissions"
		exit 1
	fi

	mkdir .errors &> /dev/null
	mkdir .tmp &> /dev/null
	print_color ${GRAY} "Compiling Makefile ... Please wait!${MAIN_COLOR}"
	MKFF=$(make -C ../ &> .errors/error.txt)
	MK_1=$?
	MKFF=$(cat .errors/error.txt | cut -c 1-46)

	if [ "$MK_1" != "0" ]; then
		if [ "$MKFF" == "make: *** No targets specified and no makefile" ]; then
			print_color ${RED} "\033[2K\rMakefile not found!\n${MAIN_COLOR}"
			echo "Remember to clone it and run as follows:"
			echo "  1. cd minishell_project_folder"
			echo "  2. git clone git@github.com:ChewyToast/minishell_panic.git"
			echo "  3. cd minishell_panic"
			echo "  4. bash mpanic.sh"
			echo ""
			clean_exit
		else
			print_color ${RED} "\033[2K\rCompilation error\n${MAIN_COLOR}"
			echo "-------------"
			echo "${MAIN_COLOR}$MKFF${MAIN_COLOR}"
			echo "-------------"
			clean_exit
		fi
	else
		mkdir traces &> /dev/null
		cp ../minishell .
		chmod 777 minishell &> /dev/null
	fi
	print_color ${GRAY} "\033[2K\r\n Compilation done\n"
	rm -rf traces/
	mkdir traces/
	echo "exit" > .tmp/exec_read.txt
	< .tmp/exec_read.txt ./minishell &> .tmp/start.txt
	printf ${MAIN_COLOR}"\n CARE!\n This tester does not work if your prompt has a new line\n or changes during execution.\n"${MAIN_COLOR}

#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  PREPARE VARIABLES
	# PROMPT
		prmp=$(cat -e .tmp/start.txt | sed -e "2d")
		size_prom_cat_exit=${#prmp}
		size_prom=$(($size_prom_cat_exit - 5))
		PRMP=$(echo "$prmp" | cut -c 1-$size_prom)
	# SUMARY TEXT
		SUMARY=""
	# SUMARY TOTAL OK COUNT
		TOTAL_OK_COUNT=0
	# SUMARY TOTAL KO COUNT
		TOTAL_KO_COUNT=0
	# SUMARY TOTAL SF COUNT
		TOTAL_SF_COUNT=0
	# SUMARY OK COUNT
		OK_COUNT=0
	# SUMARY KO COUNT
		KO_COUNT=0
	# SUMARY SF COUNT
		SF_COUNT=0
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
	# Env done
		TTENV=""
	# Exit done
		TTEXIT=""
	# Dir done
		TTDIR=""
	# Parser done
		TTPARSER=""
	# Pipe done
		TTPIPE=""
	# Redirect done
		TTREDIRECT=""
	# Status done
		TTSTATUS=""
	# SHLVL done
		TTSHL=""
	# Panic mandatori done
		TTPM=""
	# Panic scapes done
		TTPS=""
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  EXECUTOR

	if [[ $IGNORE == "1" ]]; then
		for arg in "$@"
		do
			case "$arg" in
				"echo") TTECHO="1";;
				"export") TTEXPORT="1";;
				"env") TTENV="1";;
				"exit") TTEXIT="1";;
				"dir") TTDIR="1";;
				"parser") TTPARSER="1";;
				"pipe") TTPIPE="1";;
				"redirection") TTREDIRECT="1";;
				"status") TTSTATUS="1";;
				"shlvl") TTSHL;;
				"panicm") TTPM="1";;
				"panics") TTPS="1";;
				"your") TTYOUR="1";;
			esac
		done
			echo_test_call;
			export_test_call;
			env_test_call;
			exit_test_call;
			directory_test_call;
			parser_test_call;
			pipe_test_call;
			redirection_test_call;
			status_test_call;
			shlvl_test_call;
			panic_mandatory_test_call;
			# panic_scapes_test_call;
			your_test_call;
	else
		if [[ "$#" == "1" && ( "$1" == "-b" || "$1" == "--bonus" ) ]]; then
			echo_test_call;
			export_test_call;
			env_test_call;
			exit_test_call;
			directory_test_call;
			parser_test_call;
			pipe_test_call;
			redirection_test_call;
			status_test_call;
			shlvl_test_call;
			panic_mandatory_test_call;
			# panic_scapes_test_call;
			your_test_call;
		elif [[ "$#" != "0" ]]; then
			for arg in "$@"
			do
				case "$arg" in
					"echo") echo_test_call ;;
					"export") export_test_call ;;
					"env") env_test_call;;
					"exit") exit_test_call;;
					"directory") directory_test_call;;
					"parser") parser_test_call;;
					"pipe") pipe_test_call;;
					"redirection") redirection_test_call;;
					"status") status_test_call;;
					"shlvl") shlvl_test_call;;
					"panicm") panic_mandatory_test_call;;
					"panics") panic_scapes_test_call;;
					"your") your_test_call;;
				esac
			done
		else
			echo_test_call;
			export_test_call;
			env_test_call;
			exit_test_call;
			directory_test_call;
			parser_test_call;
			pipe_test_call;
			redirection_test_call;
			status_test_call;
			shlvl_test_call;
			panic_mandatory_test_call;
			# panic_scapes_test_call;
			your_test_call;
		fi
	fi
#

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  ENDER
	printf "${MAIN_COLOR}\n|============================================================|\n\n${MAIN_COLOR}"
	printf "  %-30s ${GREEN}%-5s${MAIN_COLOR} ${RED}%-5s${MAIN_COLOR} ${RED}%-5s${MAIN_COLOR} %-5s" "SUMARY" "[ OK ]" "[ KO ]" "[ SF ]" "[ TT ]"
	printf "${SUMARY}\n"
	printf "\n  %-30s ${GREEN}[%04d]${MAIN_COLOR} ${RED}[%04d]${MAIN_COLOR} ${RED}[%04d]${MAIN_COLOR} [%04d]" "total" ${TOTAL_OK_COUNT} ${TOTAL_KO_COUNT} ${TOTAL_SF_COUNT} $((TOTAL_OK_COUNT+TOTAL_KO_COUNT+TOTAL_SF_COUNT))
	printf "\n\n\n${MAIN_COLOR}  Any issue send via slack bmoll-pe, arebelo or ailopez-o\n\n${MAIN_COLOR}"
	clean_exit
#
