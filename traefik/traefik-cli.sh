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

reset_ssl() {
  echo "Полный сброс SSL-сертификатов..."
  
  # Остановка Traefik
  docker compose down
  
  # Удаление старых сертификатов
  if [ -f "./certs/acme.json" ]; then
    echo "Удаление файла acme.json..."
    rm -f ./certs/acme.json
  fi
  
  # Создание нового файла с правильными правами
  echo "Создание нового файла acme.json..."
  mkdir -p ./certs
  touch ./certs/acme.json
  chmod 600 ./certs/acme.json
  ls -la ./certs/acme.json
  
  # Запуск Traefik
  echo "Перезапуск Traefik..."
  docker compose up -d
  
  echo "Сертификаты сброшены. Проверьте логи для отслеживания процесса получения новых сертификатов:"
  echo "./traefik-cli.sh logs"
}

check_ssl() {
  echo "Проверка SSL-сертификатов..."
  
  # Проверка размера acme.json
  if [ -f "./certs/acme.json" ]; then
    size=$(stat -c%s "./certs/acme.json")
    if [ "$size" -gt 100 ]; then
      echo "Файл сертификатов имеет размер $size байт - вероятно сертификаты получены"
    else
      echo "Файл сертификатов пуст или очень мал ($size байт) - сертификаты не получены"
    fi
  else
    echo "Файл acme.json не существует!"
  fi
  
  # Проверка прав доступа
  if [ -f "./certs/acme.json" ]; then
    perms=$(stat -c "%a" "./certs/acme.json")
    if [ "$perms" != "600" ]; then
      echo "ОШИБКА: Неправильные права доступа: $perms (должно быть 600)"
      echo "Исправьте командой: ./traefik-cli.sh fix"
    else
      echo "Права доступа acme.json корректные: 600"
    fi
  fi
  
  # Проверка логов на ошибки SSL
  echo -e "\nПроверка логов на ошибки SSL:"
  docker compose logs traefik | grep -i "certificate\|error\|acme\|tls\|challenge" | tail -20
  
  # Проверка DNS для основного домена
  echo -e "\nПроверка DNS для домена traefik.guide-it.ru:"
  if command -v dig &> /dev/null; then
    echo "DNS запись: $(dig +short traefik.guide-it.ru)"
  elif command -v nslookup &> /dev/null; then
    echo "DNS запись: $(nslookup traefik.guide-it.ru | grep -i address | tail -1)"
  else
    echo "Не удалось проверить DNS - утилиты dig и nslookup не установлены"
  fi
  
  echo -e "\nДля полного сброса сертификатов используйте:"
  echo "./traefik-cli.sh reset-ssl"
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
  echo "  check-ssl    - Проверка SSL-сертификатов"
  echo "  reset-ssl    - Полный сброс SSL-сертификатов"
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
  check-ssl)
    check_ssl
    ;;
  reset-ssl)
    reset_ssl
    ;;
  help|*)
    show_help
    ;;
esac 