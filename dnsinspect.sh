#!/bin/bash

dnscheck_categorias() {
    # 1. Validación de argumentos
    if [ -z "$1" ]; then
        echo "Uso: ./dnsinspect.sh [pagina.com o IP]"
        exit 1
    fi
    # OBTENER LA RUTA DONDE ESTÁ EL SCRIPT
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PAGINAS_FILE="$SCRIPT_DIR/paginas.txt"

    # 2. Validación del archivo de páginas
    if [ ! -f "$PAGINAS_FILE" ]; then
        echo "Error: Crea primero el archivo ~/paginas.txt"
        exit 1
    fi
    
    # =================================================================
    # ENCABEZADO PERSONALIZADO
    # =================================================================
    echo -e "\e[1;33m========================================\e[0m"
    echo -e "\e[1;36m       FISGON by code-KxK\e[0m"
    echo -e "\e[1;36m       https://github.com/code-KxK\e[0m"
    echo -e "\e[1;33m========================================\e[0m\n"
    target_dns="$1"

    # 3. Resolución inteligente del DNS (FISGON AUTOMÁTICA)
    if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "\e[1;34m[FISGON AUTOMATICA]\e[0m BUSCANDO DNS DE: $1"
        found=$(dig +short NS "$1" | head -n 1)

        if [ -z "$found" ]; then
            found=$(dig "$1" | grep -A 1 "AUTHORITY SECTION" | tail -n 1 | awk '{print $5}')
        fi

        if [ ! -z "$found" ]; then
            ip_found=$(dig +short "$found" | head -n 1)
            if [ ! -z "$ip_found" ]; then
                target_dns="$ip_found"
            else
                target_dns="$found"
            fi
            echo -e "\e[1;32m[DNS DESCUBIERTO]:\e[0m $target_dns"
        else
            echo -e "\e[1;31m[ERROR]\e[0m No se pudo hallar el DNS de $1. Usando $1 directamente..."
        fi
    fi

    echo -e "\n\e[1;35m[INICIANDO ESCANEO DE PAGINAS]:\e[0m Objetivo DNS -> $target_dns\n"
    si_count=0
    no_count=0

    # 4. Bucle para leer el archivo ~/paginas.txt línea por línea
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ -z "$line" ]]; then
            continue
        fi

        # Si es un comentario/categoría, lo imprime bonito
        if [[ "$line" =~ ^# ]]; then
            echo -e "\n\e[1;36m==== $line ====\e[0m"
            continue
        fi

        # Consulta DNS no recursiva
        res=$(dig @"$target_dns" "$line" +norecurse)

        if echo "$res" | grep -q "ANSWER SECTION" && ! echo "$res" | grep -q "status: SERVFAIL"; then
            echo -e "\e[1;32m[SI VISITADA]\e[0m $line"
            ((si_count++))
        else
            echo -e "\e[1;31m[NO VISITADA]\e[0m $line"
            ((no_count++))
        fi
    done < "$PAGINAS_FILE"

    # 5. Impresión de estadísticas finales
    total=$((si_count + no_count))
    echo -e "\n\e[1;33m========================================\e[0m"
    echo -e "\e[1;36m       FISGON by code-KxK\e[0m"
    echo -e "\e[1;32mPÁGINAS VISITADAS ENCONTRADAS:\e[0m $si_count"
    echo -e "\e[1;31mPÁGINAS NO VISITADAS:\e[0m $no_count"
    echo -e "\e[1;34mTOTAL DE SITIOS AUDITADOS:\e[0m $total"
    echo -e "\e[1;33m========================================\e[0m\n"
}

# Ejecutar la función pasando el argumento del script
dnscheck_categorias "$1"
