#!/bin/bash

# Остановка Traefik
echo "Останавливаю Traefik..."
docker compose down

# Удаление старых сертификатов
echo "Удаляю старые сертификаты..."
rm -f ./certs/acme.json

# Создание нового файла с правильными правами
echo "Создаю новый файл acme.json с правами 600..."
mkdir -p ./certs
touch ./certs/acme.json
chmod 600 ./certs/acme.json
ls -la ./certs/acme.json

# Проверка каталога letsencrypt
echo "Проверяю доступность каталога letsencrypt внутри контейнера..."
docker run --rm -v $(pwd)/certs:/letsencrypt alpine ls -la /letsencrypt
echo "Все должно быть доступно для чтения и записи."

# Запуск Traefik
echo "Запускаю Traefik..."
docker compose up -d

echo "Запуск завершен."
