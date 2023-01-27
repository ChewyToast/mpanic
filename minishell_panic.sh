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
DARK_YELLOW='\033[0;96m'

function echo_test()
{
	TEST1=$(echo $@ "; exit" | ./minishell 2>&-)
	ES_1=$?
	TEST2=$(echo $@ "; exit" | bash 2>&-)
	ES_2=$?
	if [ "$TEST1" == "$TEST2" ] && [ "$ES_1" == "$ES_2" ]; then
		printf ${GREEN}"OK"
	else
		printf ${RED}"KO"
	fi
	# printf "$CYAN \"$@\" $RESET"
	# if [ "$TEST1" != "$TEST2" ]; then
	# 	echo
	# 	echo
	# 	printf $BOLDRED"Your output : \n%.20s\n$BOLDRED$TEST1\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
	# 	printf $BOLDGREEN"Expected output : \n%.20s\n$BOLDGREEN$TEST2\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
	# fi
	# if [ "$ES_1" != "$ES_2" ]; then
	# 	echo
	# 	echo
	# 	printf $BOLDRED"Your exit status : $BOLDRED$ES_1$RESET\n"
	# 	printf $BOLDGREEN"Expected exit status : $BOLDGREEN$ES_2$RESET\n"
	# fi
	# echo
	sleep 0.1
}

function cd_test()
{
	TEST1=$(echo $@ "; exit" | ./minishell 2>&-)
	ES_1=$?
	TEST2=$(echo $@ "; exit" | bash 2>&-)
	ES_2=$?
	if [ "$TEST1" == "$TEST2" ] && [ "$ES_1" == "$ES_2" ]; then
		printf " $BOLDGREEN%s$RESET" "✓ "
	else
		printf " $BOLDRED%s$RESET" "✗ "
	fi
	printf "$CYAN \"$@\" $RESET"
	if [ "$TEST1" != "$TEST2" ]; then
		echo
		echo
		printf $BOLDRED"Your output : \n%.20s\n$BOLDRED$TEST1\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
		printf $BOLDGREEN"Expected output : \n%.20s\n$BOLDGREEN$TEST2\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
	fi
	if [ "$ES_1" != "$ES_2" ]; then
		echo
		echo
		printf $BOLDRED"Your exit status : $BOLDRED$ES_1$RESET\n"
		printf $BOLDGREEN"Expected exit status : $BOLDGREEN$ES_2$RESET\n"
	fi
	echo
	sleep 0.1
}


printf ${DARK_YELLOW}"\n\t ****      **** /** /****     ** /**   ******** /**      ** /******** /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /**/**   **/** /** /**/**   /** /**  **//////  /**     /** /**/////  /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /**//** ** /** /** /**//**  /** /** /**        /**     /** /**       /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /** //***  /** /** /** //** /** /** /********* /********** /*******  /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /**  //*   /** /** /**  //**/** /** ////////** /**//////** /**////   /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /**   /    /** /** /**   //**** /**        /** /**     /** /**       /**       /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t /**        /** /** /**    //*** /**  ********  /**     /** /******** /******** /********\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t //         //  //  //      ///  //  ////////   //      //  ////////  ////////  ////////\n\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t    *******     **     /****     ** /**    ******\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /**////**   ****    /**/**   /** /**   **////**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /**   /**  **//**   /**//**  /** /**  **    //\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /*******  **  //**  /** //** /** /** /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /**////  ********** /**  //**/** /** /**\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /**     /**//////** /**   //**** /** //**    **\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   /**     /**     /** /**    //*** /**  //******\n"${DEF_COLOR};
printf ${DARK_YELLOW}"\t\t\t   //      //      //  //      ///  //    //////\n\n"${DEF_COLOR};

make re -C ../ > /dev/null
cp ../minishell .
chmod 755 minishell

# ECHO TESTS
printf ${BLUE}"\n\t\t=======================\n"${DEF_COLOR}
printf ${BLUE}"\nECHO TEST\n\n"${DEF_COLOR}
printf ${BLUE}"1["${DEF_COLOR}
echo_test 'echo test tout'
printf ${BLUE}"]\t"${DEF_COLOR}
printf ${BLUE}"2["${DEF_COLOR}
echo_test 'echo test      tout'
printf ${BLUE}"]\t"${DEF_COLOR}
printf ${BLUE}"3["${DEF_COLOR}
echo_test 'echo -n test tout'
printf ${BLUE}"]\t"${DEF_COLOR}
printf ${BLUE}"4["${DEF_COLOR}
echo_test 'echo -n -n -n test tout'
printf ${BLUE}"]\t"${DEF_COLOR}
printf ${BLUE}"\n\n\t\t=======================\n"${DEF_COLOR}
