#!/bin/bash

echo "Перезапуск Traefik"
echo "=============================================="

# Перезапуск Traefik
echo "Перезапуск Traefik..."
docker compose down
docker compose up -d

# Ожидание запуска
echo "Ожидание запуска сервисов..."
sleep 10

# Проверка статуса контейнеров
echo -e "\nПроверка статуса контейнеров:"
docker compose ps

# Проверка логов на наличие ошибок
echo -e "\nПроверка логов на наличие ошибок:"
docker compose logs traefik | grep -i "error\|fatal\|panic" | tail -10

# Прямой доступ к API
echo -e "\nПроверка доступа к API через порт 8080:"
curl -s http://localhost:8080/api/version

echo -e "\nПроверка доступа к панели управления через HTTPS:"
curl -k -I https://traefik.guide-it.ru/dashboard/

echo -e "\nПроверка роутеров:"
curl -s http://localhost:8080/api/http/routers | grep -E "name|rule|service"

echo -e "\nВсе готово. Если Traefik продолжает перезапускаться, проверьте логи командой:"
echo "docker compose logs -f traefik" 