#!/bin/bash

# Verificar que se instaló dig
if ! command -v dig &> /dev/null; then
    echo "Error: La herramienta 'dig' no está instalada. Instálala con: pkg install dnsutils o apt install dnsutils"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Uso: ./dnscheck.sh [pagina.com o IP]"
    exit 1                                      
fi

target_dns="$1"
if [[ ! "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "\e[1;34m[FOCA AUTOMATICA]\e[0m Buscando DNS para: $1"
    found=$(dig +short NS $1 | head -n 1)
    if [ -z "$found" ]; then
        found=$(dig $1 | grep -A 1 "AUTHORITY SECTION" | tail -n 1 | awk "{print \$5}")
    fi
    if [ ! -z "$found" ]; then
        ip_found=$(dig +short $found | head -n 1)
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

# Lista interna de páginas categorizadas
paginas=(
"# BUSCADORES Y UTILIDADES" "google.com" "yahoo.com" "google.com.mx" "live.com" "://live.com" "wikipedia.org" "chatgpt.com" "github.com" "gitlab.com" "stackoverflow.com"
"# REDES SOCIALES Y FOROS" "facebook.com" "instagram.com" "whatsapp.com" "x.com" "tiktok.com" "reddit.com" "pinterest.com" "linkedin.com" "discord.com" "twitch.tv"
"# BANCARIAS Y FINANZAS" "bbva.mx" "banamex.com" "santander.com.mx" "banorte.com" "hsbc.com.mx" "binance.com" "coinbase.com"
"# MULTIMEDIA Y STREAMING" "youtube.com" "netflix.com" "spotify.com" "disneyplus.com" "max.com" "primevideo.com" "vix.com"
"# ENTREVISTAS Y CITAS" "tinder.com" "badoo.com" "bumble.com" "grindr.com" "happn.com" "skipthegames.com" "listcrawler.app" "mileroticos.com" "pasion.com" "scruff.com" "sniffies.com"
"# ENTRETENIMIENTO PARA ADULTOS" "xnxx.com" "pornhub.com" "xvideos.com" "xhamster.com" "stripchat.com" "chaturbate.com" "onlyfans.com" "fansly.com" "gaymaletube.com" "gaytube.com" "shemaletube.com" "ts-dating.com"
"# GUBERNAMENTALES Y TRÁMITES" "sat.gob.mx" "ine.mx" "gob.mx" "curp.gob.mx" "imss.gob.mx" "senado.gob.mx"
"# PELÍCULAS EN LÍNEA Y TORRENTS" "cuevana.pro" "cuevana4.me" "pelisplus.to" "gnula.nu" "thepiratebay.org" "1337x.to"
"# SECCIÓN DE CONTROL TRAMPA" "paginamexicanaquenoexisteabsolutamenteenningunlado.com"
)

for d in "${paginas[@]}"; do
    if [[ "$d" =~ ^# ]]; then
        echo -e "\n\e[1;36m==== $d ====\e[0m"
        continue
    fi
    res=$(dig @$target_dns $d +norecurse)
    if echo "$res" | grep -q "ANSWER SECTION" && ! echo "$res" | grep -q "status: SERVFAIL"; then
        echo -e "\e[1;32m[SI VISITADA]\e[0m $d"
        ((si_count++))
    else
        echo -e "\e[1;31m[NO VISITADA]\e[0m $d"
        ((no_count++))
    fi
done

total=$(($si_count + $no_count))
echo -e "\n\e[1;33m========================================\e[0m"
echo -e "\e[1;32mPÁGINAS VISITADAS ENCONTRADAS:\e[0m $si_count"
echo -e "\e[1;31mPÁGINAS NO VISITADAS:\e[0m $no_count"
echo -e "\e[1;34mTOTAL DE SITIOS AUDITADOS:\e[0m $total"
echo -e "\e[1;33m========================================\e[0m\n"
