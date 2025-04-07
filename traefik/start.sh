#!/bin/bash

# Создаем директории, если они не существуют
mkdir -p certs logs prometheus config/nginx

# Создаем файл для сертификатов с правильными правами
touch certs/acme.json
chmod 600 certs/acme.json

# Останавливаем предыдущий экземпляр, если запущен
docker-compose down

# Запускаем сервисы
docker-compose up -d

# Проверяем статус
echo "Проверка статуса контейнеров:"
docker-compose ps

# Показываем логи Traefik
echo "Логи Traefik (Ctrl+C для выхода):"
docker-compose logs -f traefik 