# minishell_panic

--------------------
env -i ./minishell
export
echo $PATH
--------------------
echo ~
echo ~bmoll-pe
echo ~sdfsdgfs
(~ es igual a /Users, despues se le añade el usuario escrito si la ruta es valida, sino lo va a tomar como texto normal)
--------------------
env | grep PWD
cd (algo existente)
env | grep PWD
unset PWD
cd ..
env | grep PWD
(OLDPWD se crea/actualiza al cambiar de directorio, cogiendo el valor de PWD, si PWD no existe, OLDPWD se borra tambien)
-------------------
lo de exportar y imprimir variables con y sin comillas como echo "$ANA" y ANA=".         hola.         asiod"
-------------------
