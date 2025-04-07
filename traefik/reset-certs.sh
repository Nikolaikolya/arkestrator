#!/bin/bash

# Остановка контейнеров
echo "Останавливаю контейнеры..."
docker compose down

# Удаление сертификатов
echo "Удаляю файл acme.json..."
rm -f ./certs/acme.json

# Создание нового файла для сертификатов
echo "Создаю новый файл acme.json..."
touch ./certs/acme.json
chmod 600 ./certs/acme.json

# Перезапуск контейнеров
echo "Перезапускаю контейнеры..."
docker compose up -d

# Вывод логов
echo "Вывод логов Traefik (Ctrl+C для выхода):"
docker compose logs -f traefik 