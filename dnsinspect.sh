_dnscheck_categorias() {
    # 1. Validación de argumentos
    if [ -z "$1" ]; then 
        echo "Uso: dnscheck [pagina.com o IP]"
        return
    fi

    # 2. Validación del archivo de páginas
    if [ ! -f ~/paginas.txt ]; then 
        echo "Error: Crea primero el archivo ~/paginas.txt"
        return
    fi

    target_dns="$1"

    # 3. Resolución inteligente del DNS (FOCA AUTOMÁTICA)
    if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "\e[1;34m[FOCA AUTOMATICA]\e[0m Buscando DNS para: $1"
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
            echo -e "\e[1;32m[DNS ASIGNADO]:\e[0m $target_dns"
        else
            echo -e "\e[1;31m[ERROR]\e[0m No se pudo hallar el DNS de $1. Usando $1 directamente..."
        fi
    fi

    echo -e "\n\e[1;35m[INICIANDO ESCANEO ORGANIZADO]:\e[0m Objetivo DNS -> $target_dns\n"
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
    done < ~/paginas.txt

    # 5. Impresión de estadísticas finales
    total=$((si_count + no_count))
    echo -e "\n\e[1;33m========================================\e[0m"
    echo -e "\e[1;32mPÁGINAS VISITADAS ENCONTRADAS:\e[0m $si_count"
    echo -e "\e[1;31mPÁGINAS NO VISITADAS:\e[0m $no_count"
    echo -e "\e[1;34mTOTAL DE SITIOS AUDITADOS:\e[0m $total"
    echo -e "\e[1;33m========================================\e[0m\n"
