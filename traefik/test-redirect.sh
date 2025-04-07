#!/bin/bash

echo "Тест доступности панели управления Traefik"
echo "=========================================="

# Тест HTTP -> HTTPS редиректа
echo -e "\nТестирование редиректа HTTP -> HTTPS:"
echo "curl -I http://traefik.guide-it.ru"
curl -I http://traefik.guide-it.ru
echo

# Тест HTTPS доступности
echo -e "\nТестирование доступности HTTPS:"
echo "curl -k -I https://traefik.guide-it.ru"
curl -k -I https://traefik.guide-it.ru
echo

# Полный тест с проверкой статуса и заголовков
echo -e "\nПолный тест с проверкой статуса и заголовков:"
echo "curl -k -v https://traefik.guide-it.ru"
curl -k -v https://traefik.guide-it.ru 2>&1 | grep -E "HTTP|Location|[><]"
echo

# Тест API
echo -e "\nТестирование API Traefik:"
echo "curl -k -s https://traefik.guide-it.ru/api/version"
curl -k -s https://traefik.guide-it.ru/api/version
echo

echo -e "\nПроверка роутеров через API:"
echo "curl -k -s https://traefik.guide-it.ru/api/http/routers | grep -E 'name|rule'"
curl -k -s https://traefik.guide-it.ru/api/http/routers | grep -E "name|rule" 