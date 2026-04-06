#!/bin/bash
err() {
    echo "$1" >&2
    exit 1
}

# Проверка прав
if [[ $EUID -ne 0 ]]; then
    err "Этот скрипт требует прав root. Запустите через sudo."
fi

PREFIX="${1:-NOT_SET}"
INTERFACE="$2"
SUBNET="$3"
HOST="$4"

# Проверка обязательных аргументов
if [[ "$PREFIX" == "NOT_SET" ]]; then
    err "PREFIX должен быть передан первым аргументом"
fi

if [[ -z "$INTERFACE" ]]; then
    err "INTERFACE должен быть передан вторым аргументом"
fi

# Проверка, что PREFIX введён правильно
if ! [[ "$PREFIX" =~ ^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]; then
    err "Недопустимое значение PREFIX. Введите 2 октета в диапазоне от 0 до 255, разделенных точкой."
fi

# Проверка существования сетевого интерфейса
if ! ip link show "$INTERFACE" &>/dev/null; then
   err "Интерфейс '$INTERFACE' не существует. Введите корректное значение."
fi

# Функция: проверка корректности октета для SUBNET и HOST
validoctet() {
    [[ "$1" =~ ^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$ ]]
}

# Проверка, что SUBNET и HOST введён правильно
if [[ -n "$SUBNET" ]] && ! validoctet "$SUBNET"; then
    err "Недопустимое значение SUBNET. Введите значение от 0 до 255."
fi

if [[ -n "$HOST" ]] && ! validoctet "$HOST"; then
    err "Недопустимое значение HOST. Введите значение от 0 до 255."
fi

# Функция: когда введены все 4 аргумента, выполняется arping для одного IP
scanip() {
    local ip="$1"
    echo "[*] Сканирую IP: $ip"
    arping -c 3 -i "$INTERFACE" "$ip" &>/dev/null
}

# Сканируем сеть
if [[ -n "$HOST" ]]; then
    # Сканируем один IP
    IP="$PREFIX.$SUBNET.$HOST"
    scanip "$IP"

elif [[ -n "$SUBNET" ]]; then
    # Сканируем одну подсеть (хосты 1–254)
    for h in {1..254}; do
    IP="$PREFIX.$SUBNET.$h"
    scanip "$IP"
    done

else
    # Сканируем всё: подсети 0–255, хосты 1–254 (исключаем .0 и .255 как broadcast/network)
    for s in {0..255}; do
        for h in {1..254}; do
            IP="$PREFIX.$s.$h"
            scanip "$IP"
        done
    done
fi
