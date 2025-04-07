# Traefik - инструкция по запуску

## Быстрый запуск

```bash
# Перезапуск Traefik с новыми настройками
chmod +x update-dashboard.sh
./update-dashboard.sh

# Проверка доступности панели управления
chmod +x check-dashboard.sh
./check-dashboard.sh
```

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
   
   # Роутеры в docker-compose.yml
   grep -A10 "labels:" traefik/docker-compose.yml
   ```

3. **Проверьте логи Traefik**:
   ```bash
   docker-compose logs -f traefik | grep -E "api|dashboard|router|middleware"
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
docker-compose logs -f traefik
``` 