#!/bin/bash

echo "Проверка всех возможных URL панели управления Traefik"
echo "===================================================="

DOMAIN="traefik.guide-it.ru"
IP=$(curl -s ifconfig.me)
PORT=8080

# Проверка всех вариантов URL для dashboard
test_url() {
  local url=$1
  echo -e "\nТестирование URL: $url"
  local status=$(curl -s -o /dev/null -w "%{http_code}" -k -I "$url")
  echo "HTTP Status: $status"
  
  if [ "$status" -eq 200 ]; then
    echo "✅ URL доступен"
  elif [ "$status" -eq 302 ] || [ "$status" -eq 301 ]; then
    echo "↪️ Редирект (может быть нормальным)"
    local redirect=$(curl -s -k -I "$url" | grep -i Location)
    echo "  $redirect"
  else
    echo "❌ URL недоступен"
  fi
}

# Прямой доступ через порт 8080 (без TLS)
echo -e "\n🔍 Проверка доступа к порту 8080 (API)"
test_url "http://localhost:$PORT/api/overview"
test_url "http://$IP:$PORT/api/overview"
test_url "http://$DOMAIN:$PORT/api/overview"

# Проверка через HTTPS
echo -e "\n🔍 Проверка доступа через HTTPS"
test_url "https://$DOMAIN/"
test_url "https://$DOMAIN/dashboard/"
test_url "https://$DOMAIN/api/"
test_url "https://$DOMAIN/api/version"
test_url "https://$DOMAIN/api/overview"

# Проверка через HTTP
echo -e "\n🔍 Проверка доступа через HTTP (должен быть редирект на HTTPS)"
test_url "http://$DOMAIN/"
test_url "http://$DOMAIN/dashboard/"
test_url "http://$DOMAIN/api/overview"

# Вывод конфигурации роутеров
echo -e "\n🔍 Просмотр текущих роутеров в Traefik:"
echo "curl -s http://localhost:$PORT/api/http/routers | grep -E 'name|rule'"
curl -s "http://localhost:$PORT/api/http/routers" | grep -E "name|rule|service"

echo -e "\n📋 Рекомендации:"
echo "1. Если ни один URL не работает, проверьте:"
echo "   - Конфигурацию API в traefik.yml (api.dashboard должно быть true)"
echo "   - Правила маршрутизации в dashboard.yml"
echo "   - Логи Traefik (docker compose logs -f traefik)"
echo "2. Если порт 8080 доступен, но HTTPS нет, проверьте:"
echo "   - Настройки TLS и сертификатов"
echo "   - Правила маршрутизации для HTTPS"
echo "3. Попробуйте перезапустить Traefik:"
echo "   ./update-dashboard.sh" 