<h1 align="center">
	MINISHELL PANIC
</h1>

<p align="center">
	<b><i>An epic tester to make you panic when testing your minishell</i></b><br>
</p>

<p align="center">
	<img src="https://github.com/ChewyToast/mpanic/blob/main/.img/mpanic_v4.png?raw=true" />
	
	
</p>
<br/>

# Description

The mpanic tester has been developed to help you throught the process of testing your minishell. There are some other test, but mpanic is quite special for two important features:

- You dont need to modify your minishell to work with -C flag. Mpanic is able to catch your minishell exit and test against bash.
- We have develop kind of pseoudo-code to give you the ability to add your own test without going deep in the code, just modifying the txt files of the test.

<br/>

# Potential Issues
One thing to keep in mind is that if you have the standard input file descriptors redirected to a non-terminal file, the exit command should not be printed. You can check whether a file descriptor is a terminal or not using the isatty() function.

Here's an example of how you can use isatty() to check whether standard output is being redirected:

```bash

line = readline("minishell $");
if (!line)
{
    if (isatty(STDIN_FILENO))
	write(2, "exit\n", 6);
    exit (exit_code);
}
```

 { >>> WARNIG <<<< } IF YOUR MINISHELL does not have this implementation, THE TESTER WILL FAIL COMPLETLY.


<br/>

# How to use

Clone this repo inside your minishell folder

```bash
git clone git@github.com:ChewyToast/mpanic.git
```

Execute the script. First time you execute MPANIC, you get all the options you have to execute the test
```bash
bash mpanic.sh
```

<p align="center">
	<br>
	<img src="https://github.com/ChewyToast/mpanic/blob/main/.img/mpanic_usage.png?raw=true" style="width:65%"/>
</p>

<br/>

# Make your own test

This tester has developed kind of meta-lenguaje to make easy to add new test to the blocks that already exist (parser, echo, export... ) or to your own block.

Testing some commands is not easy because you need to prepare some files or variables, or you need to delete some files after the test. MPANIC is ready to manage all this situations due his own lenguaje.

Mainly, each line that you write in the .txt of the tests files will be executed in minishell and in bash. Then the stdout, the error status and the errout will be compared and must be the same to get an OK.

<br/>

## Basic testing

We will execute this sequence of lines in minishell and bash and compare the results.

```bash
echo hola
echo hola | cat -e
echo hola > file1
cat file1
```

<br/>

## Preparing testing

In some test you will neeed to prepare some files to check the correct behaviour of your minishell. For example you will nedd to create a file without permissions to check that a redirect fails if you don't have rights.

For this situation we haved developed the '#' statement. Each line you write before '#' will be executed in the terminal but without compare nothig. Just like yo do that in the terminal. 

For example this secuence will create a testfile file without rights and then will execute all this tests. At the end is good practice to delete the file in the same way. We also recomend to redirects all the fd of the comnmand (&> /dev/null) after '#' statement to avoid random messages.

In this lines, the '#' statements will executed quietly. You will see nothing about this lines in the testing.

```bash
# chmod 000 testfile &> /dev/null
echo hi > testfile
echo hi >> testfile
echo hi 2> testfile
echo hi 2>> testfile
# (chmod 666 testfile && rm testfile) &> /dev/null
```

<br/>

## Batch testing

Is there some situations you can not resolve easily, for example if you execute this secuence, the echo will print nothing. This is because each line is executed in new minishell & bash. So the second minishell & bash have no variable called A.

```bash
export A="mpanic"
echo $A
```

To solve this sititions you can do batch testing and send a secuence of commands to the same instance of minishell & bash. You only have to put the commands in arow separated by ';'

In this secuence the result will be mpanic in stdout.

```bash
export A="mpanic"; echo $A
```
Remember that you don't need to have the ';' operator implemented in your minishell !

<br/>

## Comments

The tester will be print last command of the ';' separated secuence to recognice the test. But in some situations this last line is not representative of the test. For example

```bash
echo hi > testfolder; rm testfolder
```

To solve this you can add the text you want to show the tester adding at the end an '@' followe by the line yoy want.

```bash
echo hi > testfolder; rm testfolder @This is the line the tester will print to identify this test
```
