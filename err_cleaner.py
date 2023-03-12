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
        if line_num in error_dict and error_msg != error_dict[line_num]:
            # Si ya hay un error registrado para esta línea y es diferente,
            # omitir esta línea
            continue
        error_dict[line_num] = error_msg

# Crear la salida limpia
clean_output = ''
for line_num, error_msg in error_dict.items():
    clean_output += f'{error_msg}\n'

# Escribir la salida limpia en el archivo
with open('.tmp/bash_error_outp_clean.txt', 'w') as f:
    f.write(clean_output)
