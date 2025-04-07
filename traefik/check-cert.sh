#!/bin/bash

echo "Проверка настройки сертификатов Traefik"
echo "======================================"

# Проверка файла acme.json
if [ ! -f ./certs/acme.json ]; then
  echo "[ОШИБКА] Файл acme.json не существует!"
  echo "Создаю файл..."
  mkdir -p ./certs
  touch ./certs/acme.json
  chmod 600 ./certs/acme.json
else
  echo "[OK] Файл acme.json существует"
  
  # Проверка прав доступа
  permissions=$(stat -c %a ./certs/acme.json)
  if [ "$permissions" != "600" ]; then
    echo "[ОШИБКА] Неправильные права доступа: $permissions (должно быть 600)"
    echo "Исправляю права доступа..."
    chmod 600 ./certs/acme.json
  else
    echo "[OK] Права доступа файла acme.json: 600"
  fi
  
  # Проверка содержимого файла
  file_size=$(stat -c %s ./certs/acme.json)
  if [ "$file_size" -gt 0 ]; then
    echo "[INFO] Размер acme.json: $file_size байт (файл не пустой)"
  else
    echo "[ВНИМАНИЕ] Файл acme.json пуст - сертификаты еще не были получены"
  fi
fi

# Проверка статуса Traefik
echo -e "\nПроверка статуса контейнера Traefik:"
if docker ps | grep -q traefik; then
  echo "[OK] Контейнер traefik запущен"
else
  echo "[ОШИБКА] Контейнер traefik не запущен!"
fi

# Проверка доступности портов
echo -e "\nПроверка доступности портов:"
if netstat -tuln | grep -q ":80 "; then
  echo "[OK] Порт 80 доступен"
else
  echo "[ОШИБКА] Порт 80 НЕ доступен - HTTP challenge не будет работать!"
fi

if netstat -tuln | grep -q ":443 "; then
  echo "[OK] Порт 443 доступен"
else
  echo "[ОШИБКА] Порт 443 НЕ доступен - HTTPS не будет работать!"
fi

# Проверка DNS
echo -e "\nПроверка DNS-записей:"
domain="traefik.guide-it.ru"
ip=$(dig +short $domain)
server_ip=$(curl -s ifconfig.me)

echo "Domain: $domain"
echo "DNS IP:  $ip"
echo "Server IP: $server_ip"

if [ "$ip" = "$server_ip" ]; then
  echo "[OK] DNS запись для $domain указывает на IP-адрес сервера"
else
  echo "[ОШИБКА] DNS запись для $domain НЕ указывает на IP-адрес сервера!"
  echo "DNS должен обновиться до: $server_ip"
fi

# Проверка логов
echo -e "\nПроследние 20 строк логов traefik (ищем ошибки):"
docker logs traefik --tail 20

echo -e "\nПроверяем логи на наличие ошибок сертификатов:"
docker logs traefik | grep -i "certif\|acme\|tls\|challenge" | tail -20

echo -e "\n============================================"
echo "Для принудительного обновления сертификатов:"
echo "1. Удалите файл acme.json:"
echo "   rm ./certs/acme.json"
echo "2. Создайте новый пустой файл:"
echo "   touch ./certs/acme.json"
echo "   chmod 600 ./certs/acme.json"
echo "3. Перезапустите Traefik:"
echo "   docker compose down && docker compose up -d"
echo "4. Проверьте логи:"
echo "   docker compose logs -f traefik" 