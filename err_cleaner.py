import re

# Abrir el archivo de salida de Bash
with open('.tmp/bash_error_outp.txt', 'r') as f:
    output = f.read()

# Seguimiento de los errores por línea
error_dict = {}

# Buscar errores en la salida
for line in output.splitlines():
    match = re.search(r'bash: line (\d+): (.+)', line)
    if match:
        line_num = int(match.group(1))
        error_msg = match.group(2)
        # Si el mensaje de error comienza con "syntax error near unexpected token",
        # solo se debe mantener esa parte del mensaje
        if error_msg.startswith('syntax error near unexpected token'):
            error_msg = ' '.join(error_msg.split()[0:5])
        if line_num in error_dict and error_msg != error_dict[line_num]:
            # Si ya hay un error registrado para esta línea y es diferente,
            # omitir esta línea
            continue
        error_dict[line_num] = error_msg

# Crear la salida limpia
clean_output = ''
for line_num, error_msg in error_dict.items():
    # Quitar la primera parte hasta después de "line x"
    error_msg = re.sub(r'bash: line \d+: ', '', error_msg)
    clean_output += f'{error_msg}\n'

# Escribir la salida limpia en el archivo
with open('.tmp/bash_error_outp_clean.txt', 'w') as f:
    f.write(clean_output)
