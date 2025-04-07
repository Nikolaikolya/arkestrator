# Traefik - инструкция по запуску

## Быстрый запуск

```bash
# Запуск всех контейнеров
docker compose up -d

# Проверка статуса
docker compose ps
```

## Решение проблемы с перезапусками

Если Traefik постоянно перезапускается:

1. **Проверьте логи для выявления ошибок**:
   ```bash
   docker compose logs traefik | grep -i "error\|fatal\|panic"
   ```

2. **Используйте скрипт восстановления**:
   ```bash
   chmod +x fix-traefik.sh
   ./fix-traefik.sh
   ```

3. **Для перезапуска с проверками**:
   ```bash
   chmod +x update-dashboard.sh
   ./update-dashboard.sh
   ```

## Доступ к сервисам

Панель управления Traefik доступна по адресу:
- https://traefik.guide-it.ru (панель управления)
- http://localhost:8080 (прямой доступ к API)

Доступ к мониторингу:
- https://prometheus.guide-it.ru (Prometheus)
- https://grafana.guide-it.ru (Grafana)

Доступ защищен паролем:
- Пользователь: admin
- Пароль: admin

## Структура конфигурации

- **traefik.yml** - основные настройки Traefik
- **dynamic/dashboard.yml** - настройки панели управления
- **dynamic/usersfile** - файл с пользователями для аутентификации
- **config/middleware.yml** - настройки middleware для безопасности

## Доступ к панели управления

Панель управления Traefik доступна по нескольким URL:

1. **Основной URL панели управления:** 
   - https://traefik.guide-it.ru/dashboard/

2. **API Traefik:**
   - https://traefik.guide-it.ru/api/
   - https://traefik.guide-it.ru/api/overview
   - https://traefik.guide-it.ru/api/http/routers

3. **Прямой доступ через порт 8080:**
   - http://localhost:8080/dashboard/
   - http://localhost:8080/api/

Доступ защищен паролем:
- Пользователь: admin
- Пароль: admin

## Решение проблем с панелью управления

Если панель управления недоступна (ошибка 404):

1. **Проверьте прямой доступ через порт 8080**:
   ```bash
   curl -I http://localhost:8080/api/version
   ```
   Если доступен, значит проблема с маршрутизацией, а не с самим API.

2. **Проверьте конфигурацию**:
   ```bash
   # Настройки API в traefik.yml
   grep -A5 "api:" traefik/traefik.yml
   
   # Роутеры в docker compose.yml
   grep -A10 "labels:" traefik/docker compose.yml
   ```

3. **Проверьте логи Traefik**:
   ```bash
   docker compose logs -f traefik | grep -E "api|dashboard|router|middleware"
   ```

4. **Перезапустите Traefik с отладкой**:
   ```bash
   ./update-dashboard.sh
   ```

## Доступные утилиты

- **update-dashboard.sh** - перезапуск Traefik и проверка доступности панели управления
- **check-dashboard.sh** - подробная проверка всех возможных URL
- **reset-certs.sh** - сброс сертификатов при проблемах с HTTPS
- **check-cert.sh** - диагностика проблем с сертификатами

## Полезные команды

```bash
# Просмотр активных роутеров
curl -s http://localhost:8080/api/http/routers | grep -E "name|rule|service"

# Просмотр middleware
curl -s http://localhost:8080/api/http/middlewares | grep -E "name|type"

# Проверка конкретного URL
curl -k -I https://traefik.guide-it.ru/dashboard/

# Просмотр логов
docker compose logs -f traefik
``` 