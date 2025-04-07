#!/bin/bash

echo "Восстановление Traefik после проблем"
echo "===================================="

# Остановка и удаление всех контейнеров
echo "Останавливаю все контейнеры..."
docker compose down

# Удаление томов (опционально)
read -p "Удалить тома Docker? (y/n): " remove_volumes
if [ "$remove_volumes" = "y" ]; then
  echo "Удаление томов..."
  docker volume rm traefik_prometheus_data traefik_grafana_data
fi

# Очистка старых сертификатов
echo "Сброс сертификатов..."
rm -f certs/acme.json
touch certs/acme.json
chmod 600 certs/acme.json

# Проверка конфигурации Traefik
echo "Проверка конфигурации Traefik..."
docker run --rm -v $(pwd)/traefik.yml:/traefik.yml traefik:v3.0 traefik version

# Запуск Traefik в отладочном режиме
echo "Запуск Traefik..."
docker compose up -d

# Проверка логов
echo "Проверка логов (первые 20 строк)..."
sleep 5
docker compose logs traefik | head -20

echo "Статус контейнеров:"
docker compose ps

echo -e "\nДля просмотра логов в реальном времени используйте:"
echo "docker compose logs -f traefik" 