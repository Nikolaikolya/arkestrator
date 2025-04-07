#!/bin/bash

echo "Исправление проблем с SSL в Traefik"
echo "=================================="

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

# Ожидание запуска
echo "Ожидаю запуск сервисов (30 секунд)..."
sleep 30

# Тестирование HTTP -> HTTPS редиректа
echo "Тестирую HTTP редирект..."
curl -I -L http://traefik.guide-it.ru

# Вывод статуса
echo "Текущий статус контейнеров:"
docker compose ps

echo "Просмотр последних логов для проверки получения сертификатов:"
docker compose logs --tail 50 traefik | grep -i "certif\|acme"

echo "Если сертификаты все еще не работают, выполните:"
echo "docker compose logs -f traefik"
echo "для просмотра полных логов и диагностики проблемы." 