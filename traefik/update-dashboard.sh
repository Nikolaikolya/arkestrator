#!/bin/bash

echo "Обновление и проверка панели управления Traefik"
echo "=============================================="

# Перезапуск Traefik
echo "Перезапуск Traefik..."
docker compose down
docker compose up -d

# Ожидание запуска
echo "Ожидание запуска сервисов..."
sleep 5

# Проверка работоспособности
echo -e "\nПроверка прямого доступа к API через порт 8080:"
echo "curl -s http://localhost:8080/api/version"
curl -s http://localhost:8080/api/version
echo

# Проверка доступа через HTTPS
echo -e "\nПроверка доступа к dashboard через HTTPS:"
echo "curl -k -I https://traefik.guide-it.ru/dashboard/"
curl -k -I https://traefik.guide-it.ru/dashboard/
echo

# Проверка доступа к API
echo -e "\nПроверка доступа к API через HTTPS:"
echo "curl -k -I https://traefik.guide-it.ru/api/overview"
curl -k -I https://traefik.guide-it.ru/api/overview
echo

# Проверка доступа к корню (должен быть редирект)
echo -e "\nПроверка редиректа с корня домена:"
echo "curl -k -I https://traefik.guide-it.ru/"
curl -k -I -L https://traefik.guide-it.ru/
echo

# Отображение роутеров
echo -e "\nАктивные роутеры Traefik:"
curl -s http://localhost:8080/api/http/routers | grep -E "status|service|rule"
echo

echo -e "\nВсе готово! Traefik должен быть доступен по адресу:"
echo "- Dashboard: https://traefik.guide-it.ru/dashboard/"
echo "- API:       https://traefik.guide-it.ru/api/"
echo
echo "Для устранения проблем с доступом проверьте логи:"
echo "docker compose logs -f traefik" 