# Traefik - инструкция по запуску

## Быстрый запуск

```bash
# Запуск Traefik
docker compose up -d

# Проверка состояния
docker compose ps

# Просмотр логов
docker compose logs -f traefik
```

## Проверка работоспособности

1. **Панель управления**: https://traefik.guide-it.ru/dashboard/
2. **API**: https://traefik.guide-it.ru/api/overview

Доступ защищен паролем:
- Пользователь: admin
- Пароль: admin

## Решение проблем

### 1. Проблемы с сертификатами

```bash
# Запуск диагностики
./check-cert.sh

# Принудительный сброс сертификатов
./reset-certs.sh
```

### 2. Проблемы с доступом к панели управления (404)

Если видите ошибку 404 при попытке доступа к панели управления:

1. Убедитесь, что в traefik.yml опция api.dashboard включена:
   ```yaml
   api:
     dashboard: true
   ```

2. Убедитесь, что в dynamic/dashboard.yml правильно настроен роутер:
   ```yaml
   http:
     routers:
       api:
         rule: "Host(`traefik.guide-it.ru`)"
         service: api@internal
   ```

3. Перезапустите Traefik:
   ```bash
   docker compose down
   docker compose up -d
   ```

### 3. Тестирование доступности

```bash
# Выполнить тесты доступности
./test-redirect.sh
``` 