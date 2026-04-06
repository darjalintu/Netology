#!/bin/bash
err() {
    echo "$1" >&2
    exit 1
}

# Проверка прав
if [[ $EUID -ne 0 ]]; then
    err "Этот скрипт требует прав root. Запустите через sudo."
fi

INTERFACE="$1"

# Проверка обязательных аргументов
if [[ -z "$INTERFACE" ]]; then
    err "Введите INTERFACE"
fi

# Проверка существования сетевого интерфейса
if ! ip link show "$INTERFACE" &>/dev/null; then
   err "Интерфейс '$INTERFACE' не существует. Введите корректное значение."
fi

# Получаем IPv4-запись в формате CIDR
CIDR=$(ip -4 addr show dev "$INTERFACE" | awk '/inet/ {print $2; exit}')
if [[ -z "$CIDR" ]]; then
    err "На интерфейсе '$INTERFACE' не найдено IPv4-адреса."
fi

scanip() {
    echo "[*] Просканирован IP: $CIDR"
    sudo arp-scan --interface="$INTERFACE" "$CIDR" &>/dev/null
}

# Сканируем сеть
if [[ -n "$CIDR" ]]; then
    # Сканируем подсеть
    scanip "$CIDR"

fi
