<h1 align="center">
	MINISHELL PANIC
</h1>

<p align="center">
	<b><i>An epic tester to make you panic when testing your minishell</i></b><br>
</p>

<p align="center">
	<img src="https://github.com/ChewyToast/mpanic/blob/main/.img/mpanic.jpg?raw=true" />
</p>


## Description

The mpanic tester has been developed to help you throught the process of testing your minishell. There are some other test in GitHub, but mpanic is quite special for two important features:

- You dont need to modify your minishell to work with -C flag. Mpanic is able to catch your minishell exit and test against bash.
- We have develop kind of pseoudo-code to give you the ability to add your own test without going deep in the code, just modifying the txt files of the test.

## How to use

Clone this repo inside your minishell folder

```bash
git clone git@github.com:ChewyToast/mpanic.git
```

Execute the script. First time you execute MPANIC, you get all the options you have to execute the test
```bash
bash mpanic
```

<p align="center">
	<br>
	<img src="https://github.com/ChewyToast/mpanic/blob/main/.img/mpanic_usage.png?raw=true" style="width:65%"/>
</p>


## Make your own test

This tester has developed kind of meta-lenguaje to meke easy to add new test to the blocks that already exist (parser, echo, export... ) or to your own block

Testing some commands is not easy because you need to prepare some files or variables, or you need to delete some files after the test. Mpanic is ready to manage all this situations due his own lenguaje.

Mainly, each line that yoy write in the .txt of the tests will be executed in minishell and in bash. Then the stdout, the error status and the errout will be compared and must be the same to get an OK.

### Basic testing

This secuence of lines will be executed in both (minishell and bash) and comapre the results.

```bash
echo hola
echo hola | cat -n
echo hola > file1
cat file1
```


### Preparing testing

In some test you will neeed to prepare some files to check the correct behaivour of theur menishell. For example you will nedd to create a file without permissions to chec that a redirect fails y yoy don'n have rights.

For thsi situation we haved developed the # statement. Each line tha you write before # will be executed in the terminal but without compare nothig. Just like yo do that in the terminal. 

For example this secuence will create a testfolder file without rights and then will execute all this tests. At the end is good practice to delete the file in the same way. We also recomend to redirects all the fd of the comnmand (&> /dev/null) after # statement to avoid random messages

```bash
# chmod 000 testfolder &> /dev/null
echo hi > testfolder
echo hi >> testfolder
echo hi 2> testfolder
echo hi 2>> testfolder
# rm testfolder
```








