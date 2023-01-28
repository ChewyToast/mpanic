# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: smiro <smiro@student.42barcelona>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2022/12/07 04:53:46 by smiro             #+#    #+#              #

#                                                                              #
# **************************************************************************** #

################################################################################
### INIT
################################################################################

NAME		= minishell
INC			= ./inc/
INC_HEADERS	= $(INC)minishell.h

FT_INC		= $(FT)/libft.h

FT			= $(INC)libft/
FT_LNK		= -L$(FT) -lft
FT_LIB		= $(FT)libft.a

SRC_DIR		= src/
OBJ_DIR		= obj/
COMFLAGS	= -I/Users/$(USER)/.brew/opt/readline/include
LINKFLAGS	= -L/Users/$(USER)/.brew/opt/readline/lib -lreadline
CFLAGS		= -I $(INC) -MMD -Wall -Werror -Wextra #-fsanitize=address
RM			= rm -f

################################################################################
### COLORS
################################################################################

DEL_LINE =		\033[2K
ITALIC =		\033[3m
BOLD =			\033[1m
DEF_COLOR =		\033[0;39m
GRAY =			\033[0;90m
RED =			\033[0;91m
GREEN =			\033[0;92m
YELLOW =		\033[0;93m
BLUE =			\033[0;94m
MAGENTA =		\033[0;95m
CYAN =			\033[0;96m
WHITE =			\033[0;97m
BLACK =			\033[0;99m
ORANGE =		\033[38;5;209m
BROWN =			\033[38;2;184;143;29m
DARK_GRAY =		\033[38;5;234m
MID_GRAY =		\033[38;5;245m
DARK_GREEN =	\033[38;2;75;179;82m
DARK_YELLOW =	\033[38;5;143m

################################################################################
### OBJECTS
################################################################################

SRC_FILES	=	minishell.c \
				init.c \
				error_manager.c \
				handle_args.c \
				utils_args.c \
				delete_null_args.c \
				execute_cmd.c \
				utils.c \
				utils2.c \
				expand.c \
				expand_utils.c \
				expand_var.c \
				ft_echo.c \
				ft_cd.c \
				ft_pwd.c \
				ft_env.c \
				ft_unset.c \
				ft_export.c \
				pipes.c \
				ft_execve.c \
				ft_exit.c \
				signals.c \
				only_export.c \
				export_parse.c \
				redir.c \
				redir_utils.c \
				redir_file.c \
				utils_pipes.c \
				utils_env.c


SRC			=	$(addprefix $(SRC_DIR), $(SRC_FILES))
OBJ 		=	$(addprefix $(OBJ_DIR), $(SRC:.c=.o))
DEP			= 	$(addsuffix .d, $(basename $(OBJ)))
B_OBJ		=	$(OBJ)

################################################################################
### RULES
################################################################################

all:
		@$(MAKE) -C $(FT)
		@$(MAKE) $(NAME)

$(OBJ_DIR)%.o: %.c Makefile
			@mkdir -p $(dir $@)
			@echo "${BLUE} ◎ $(BROWN)Compiling   ${MAGENTA}→   $(CYAN)$< $(DEF_COLOR)"
			@$(CC) $(CFLAGS) $(COMFLAGS) -c $< -o $@

$(NAME):	$(OBJ)
			@$(CC) $(CFLAGS) $(OBJ) $(FT_LNK) $(LINKFLAGS) -o $(NAME)
			@echo "$(GREEN)\nCreated ${NAME} ✓$(DEF_COLOR)\n"

-include $(DEP)

bonus:		$(B_OBJ) $(NAME)

clean:
			@$(RM) -rf $(OBJ_DIR)
			@make clean -C $(FT)
			@echo "\n${BLUE} ◎ $(RED)All objects cleaned successfully ${BLUE}◎$(DEF_COLOR)\n"

fclean:		clean
			@$(RM) -f $(NAME)
			@$(RM) -f lib*.a
			@make fclean -C $(FT)
			@echo "\n${BLUE} ◎ $(RED)All objects and executable cleaned successfully${BLUE} ◎$(DEF_COLOR)\n"

re:			fclean all
			@echo "$(GREEN)Cleaned and rebuilt everything for fdf!$(DEF_COLOR)"

norm:
			@norminette $(SRC) $(INC)minishell.h $(FT) | grep -v Norme -B1 || true

.PHONY:		all clean fclean re norm
