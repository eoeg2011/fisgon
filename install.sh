#!/bin/bash

# FISGON - Instalador de comando global
# https://github.com/code-KxK/fisgon

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="/usr/local/bin/fisgon"

echo -e "\e[1;36m[+] Instalando FISGON de forma global...\e[0m"

# 1. Crear el script lanzador en /usr/local/bin
# Esto permite que corra desde cualquier parte sin importar si usan Bash o Zsh
sudo bash -c "cat << 'EOF' > $BIN_PATH
#!/bin/bash
cd '$SCRIPT_DIR' && ./dnsinspect.sh \"\$1\"
EOF"

# 2. Dar permisos de ejecución tanto al script principal como al lanzador
if [ -f "$BIN_PATH" ]; then
    sudo chmod +x $BIN_PATH
    chmod +x "$SCRIPT_DIR/dnsinspect.sh"
    echo -e "\e[1;32m[✓] ¡Instalación exitosa!\e[0m"
    echo -e "Ya puedes usar el comando tecleando simplemente: \e[1;33mfisgon dominio.com\e[0m"
else
    echo -e "\e[1;31m[-] Error al crear el acceso global. Intenta ejecutar con sudo.\e[0m"
    exit 1
fi
