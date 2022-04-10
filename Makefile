.DEFAULT_GOAL	:= a
UTILS			= $(addprefix utils/, sigsegv.cpp color.cpp check.cpp leaks.cpp)
PARENT_DIR		= $(shell dirname $(shell pwd))
LIBFT_PATH		= $(PARENT_DIR)
TESTS_PATH		= tests/
MANDATORY		= memset bzero memcpy memmove memchr memcmp strlen isalpha isdigit isalnum \
				isascii isprint toupper tolower strchr strrchr strncmp strlcpy strlcat strnstr \
				atoi calloc strdup substr strjoin strtrim split itoa strmapi putchar_fd putstr_fd \
				putendl_fd putnbr_fd striteri
MANDATORY00		= isalpha isdigit isalnum isascii isprint strlen memset bzero memcpy memmove strlcpy strlcat
MANDATORY01		= toupper tolower strchr strrchr strncmp memchr memcmp strnstr atoi
MANDATORY02		= calloc strdup substr strjoin strtrim split itoa
BONUS			= lstnew lstadd_front lstsize lstlast lstadd_back lstdelone lstclear lstiter lstmap
VSOPEN			= $(addprefix vs, $(MANDATORY)) $(addprefix vs, $(BONUS))
LIBFT00			= libft00.a
LIBFT01			= libft01.a
LIBFT02			= libft02.a
MANDATORY00_OBJ	= $(addprefix $(LIBFT_PATH)/ft_,$(addsuffix .o, $(MANDATORY00)))
MANDATORY01_OBJ	= $(addprefix $(LIBFT_PATH)/ft_,$(addsuffix .o, $(MANDATORY01)))
MANDATORY02_OBJ	= $(addprefix $(LIBFT_PATH)/ft_,$(addsuffix .o, $(MANDATORY02)))

_CC		= clang++
_CFLAGS	= -g3 -ldl -std=c++11 -I utils/ -I$(LIBFT_PATH) 
CFLAGS	= -Wall -Wextra -Werror
UNAME = $(shell uname -s)
ifeq ($(UNAME), Linux)
	VALGRIND = valgrind -q --leak-check=full
endif
ifeq ($(IN_DOCKER),TRUE)
	LIBFT_PATH = /project/
endif

$(MANDATORY):
	@$(_CC) $(_CFLAGS) $(UTILS) $(TESTS_PATH)ft_$*_test.cpp -L$(LIBFT_PATH) -lft && $(VALGRIND) ./a.out && rm -f a.out

$(BONUS): %: bonus_start
	@$(_CC) $(_CFLAGS) $(UTILS) $(TESTS_PATH)ft_$*_test.cpp -L$(LIBFT_PATH) -lft && $(VALGRIND) ./a.out && rm -f a.out

$(VSOPEN): vs%:
	@code $(TESTS_PATH)ft_$*_test.cpp

$(LIBFT00): $(MANDATORY00_OBJ)
	ar rc $(LIBFT_PATH)/$@ $^
	cp $(LIBFT_PATH)/$@ $(LIBFT_PATH)/libft.a

$(LIBFT01): $(MANDATORY01_OBJ)
	ar rc $(LIBFT_PATH)/$@ $^
	cp $(LIBFT_PATH)/$@ $(LIBFT_PATH)/libft.a

$(LIBFT02): $(MANDATORY02_OBJ)
	ar rc $(LIBFT_PATH)/$@ $^
	cp $(LIBFT_PATH)/$@ $(LIBFT_PATH)/libft.a

mandatory_start: update message
	@tput setaf 6
	make -C $(LIBFT_PATH)
	@tput setaf 4 && echo [Mandatory]

mandatory00_start: update
	@tput setaf 6
	make $(LIBFT00)
	@tput setaf 4 && echo [Mandatory-00]

mandatory01_start: update
	@tput setaf 6
	make $(LIBFT01)
	@tput setaf 4 && echo [Mandatory-01]

mandatory02_start: update
	@tput setaf 6
	make $(LIBFT02)
	@tput setaf 4 && echo [Mandatory-02]

bonus_start: update message
	@tput setaf 6
	make bonus -C $(LIBFT_PATH)
	@tput setaf 5 && echo [Bonus]

update:
	@git pull

message: checkmakefile
	@tput setaf 3 && echo "If all your tests are OK and the moulinette KO you, please run the tester with valgrind (see README)"

checkmakefile:
	@ls $(LIBFT_PATH) | grep Makefile > /dev/null 2>&1 || (tput setaf 1 && echo Makefile not found. && exit 1)

$(addprefix docker, $(MANDATORY)) $(addprefix docker, $(BONUS)) dockerm dockerb dockera: docker%:
	@docker rm -f mc > /dev/null 2>&1 || true
	docker build -qt mi .
	docker run -e IN_DOCKER=TRUE -dti --name mc -v $(LIBFT_PATH):/project/ -v $(PARENT_DIR)/libftTester:/project/libftTester mi
	docker exec -ti mc make $* -C libftTester || true
	@docker rm -f mc > /dev/null 2>&1

m: mandatory_start $(MANDATORY)
m0: mandatory00_start $(MANDATORY00)
m1: mandatory01_start $(MANDATORY01)
m2: mandatory02_start $(MANDATORY02)
b: $(BONUS)
a: m b 

clean:
	make clean -C $(LIBFT_PATH) && rm -rf a.out*

fclean:
	make fclean -C $(LIBFT_PATH) && rm -rf a.out*

.PHONY:	mandatory_start m bonus_start b a fclean clean update message $(VSOPEN) $(MAIL)
