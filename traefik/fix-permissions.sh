#!/bin/bash

echo "Исправление проблем с правами доступа и портами"
echo "==============================================="

# Останавливаем контейнеры
echo "Останавливаю контейнеры..."
docker compose down

# Проверяем и освобождаем порты
echo "Проверяю, не занят ли порт 8080..."
if netstat -tuln | grep -q ":8080"; then
  echo "Порт 8080 занят! Пытаюсь найти процесс..."
  pid=$(lsof -t -i:8080)
  if [ -n "$pid" ]; then
    echo "Найден процесс с PID $pid, использующий порт 8080"
    read -p "Хотите завершить этот процесс? (y/n): " kill_proc
    if [ "$kill_proc" = "y" ]; then
      echo "Завершаю процесс $pid..."
      kill -9 $pid
    fi
  else
    echo "Не удалось определить процесс, занимающий порт 8080"
    echo "Попробуйте перезагрузить систему или изменить порт в traefik.yml"
  fi
fi

# Исправляем права доступа к acme.json
echo "Исправляю права доступа к файлу acme.json..."
if [ -f "./certs/acme.json" ]; then
  chmod 600 ./certs/acme.json
  echo "Права доступа установлены на 600"
else
  echo "Создаю файл acme.json с правильными правами..."
  mkdir -p ./certs
  touch ./certs/acme.json
  chmod 600 ./certs/acme.json
fi

# Проверяем права доступа
echo "Проверяю права доступа..."
ls -la ./certs/acme.json

# Запускаем контейнеры
echo "Запускаю контейнеры..."
docker compose up -d

# Проверяем состояние
echo "Статус контейнеров:"
sleep 5
docker compose ps

echo -e "\nЕсли Traefik по-прежнему перезапускается, проверьте логи:"
echo "docker compose logs -f traefik" 