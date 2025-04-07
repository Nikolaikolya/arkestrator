#!/bin/bash

# Функции для управления Traefik
start_traefik() {
  echo "Запуск Traefik..."
  docker compose up -d
  sleep 2
  docker compose ps
}

stop_traefik() {
  echo "Остановка Traefik..."
  docker compose down
}

restart_traefik() {
  echo "Перезапуск Traefik..."
  docker compose down
  docker compose up -d
  sleep 2
  docker compose ps
}

show_logs() {
  echo "Вывод логов Traefik..."
  docker compose logs -f traefik
}

check_status() {
  echo "Статус контейнеров:"
  docker compose ps
  
  echo -e "\nПроверка доступности API:"
  curl -s http://localhost:8081/api/version
  
  echo -e "\nАктивные роутеры:"
  curl -s http://localhost:8081/api/http/routers | grep -E "name|rule|service" | head -20
}

fix_permissions() {
  echo "Исправление прав доступа к acme.json..."
  if [ -f "./certs/acme.json" ]; then
    chmod 600 ./certs/acme.json
    echo "Права установлены на 600"
    ls -la ./certs/acme.json
  else
    echo "Файл не существует, создаю..."
    mkdir -p ./certs
    touch ./certs/acme.json
    chmod 600 ./certs/acme.json
  fi
}

show_help() {
  echo "Использование: $0 [команда]"
  echo "Команды:"
  echo "  start        - Запуск Traefik"
  echo "  stop         - Остановка Traefik"
  echo "  restart      - Перезапуск Traefik"
  echo "  logs         - Просмотр логов"
  echo "  status       - Проверка статуса"
  echo "  fix          - Исправление прав доступа"
  echo "  help         - Показать эту справку"
}

# Главная логика
case "$1" in
  start)
    start_traefik
    ;;
  stop)
    stop_traefik
    ;;
  restart)
    restart_traefik
    ;;
  logs)
    show_logs
    ;;
  status)
    check_status
    ;;
  fix)
    fix_permissions
    ;;
  help|*)
    show_help
    ;;
esac 