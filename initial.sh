#!/bin/bash

# Переменные
INIT_TRAEFIK_FILE="traefik/start.sh"
SOURCE_FILE="deploy/deploy.yml"
DESTINATION_DIR="/home/gitlab-runner/"

if [ -f "$INIT_TRAEFIK_FILE" ]; then
    chmod +x $INIT_TRAEFIK_FILE
    echo "Запуск $INIT_TRAEFIK_FILE"
else
    echo "Файл $INIT_TRAEFIK_FILE не найден."
    exit 1
fi

# Проверка наличия пользователя gitlab-runner
if id "gitlab-runner" &>/dev/null; then
    echo "Пользователь gitlab-runner существует."
else
    echo "Пользователь gitlab-runner не найден."
    echo "Для запуска сначала установить gitlab-runner!"
    exit 1
fi

# Проверка наличия Docker
if command -v docker &>/dev/null; then
    echo "Docker установлен."
else
    echo "Docker не установлен."
    exit 1
fi

# Копирование файла

if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$DESTINATION_DIR"
    echo "Файл $SOURCE_FILE скопирован в $DESTINATION_DIR."
else
    echo "Файл $SOURCE_FILE не найден."
    exit 1
fi
