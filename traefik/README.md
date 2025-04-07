# Traefik - Руководство по использованию

Готовый к использованию прокси-сервер Traefik с поддержкой автоматического получения SSL-сертификатов, мониторингом и панелью управления.

## Быстрый запуск

```bash
# Сделать скрипт управления исполняемым
chmod +x traefik-cli.sh

# Исправление прав доступа (выполнить один раз перед запуском)
./traefik-cli.sh fix

# Запуск всех контейнеров
./traefik-cli.sh start

# Проверка статуса
./traefik-cli.sh status
```

## Команды управления

```bash
./traefik-cli.sh start    # Запуск Traefik
./traefik-cli.sh stop     # Остановка Traefik
./traefik-cli.sh restart  # Перезапуск Traefik
./traefik-cli.sh logs     # Просмотр логов
./traefik-cli.sh status   # Проверка статуса
./traefik-cli.sh fix      # Исправление прав доступа
./traefik-cli.sh help     # Показать справку
```

## Доступ к сервисам

После запуска доступны следующие сервисы:

- **Панель управления Traefik:**
  - https://traefik.guide-it.ru
  - http://localhost:8081 (прямой доступ к API)

- **Мониторинг:**
  - https://prometheus.guide-it.ru (Prometheus)
  - https://grafana.guide-it.ru (Grafana)

Доступ защищен паролем:
- Пользователь: admin
- Пароль: admin

## Структура проекта

```
traefik/
├── traefik.yml           # Основная конфигурация Traefik
├── docker-compose.yml    # Конфигурация Docker Compose
├── traefik-cli.sh        # Скрипт для управления Traefik
├── certs/                # Каталог для сертификатов
│   └── acme.json         # Файл с сертификатами (создается автоматически)
├── config/               # Статическая конфигурация 
│   └── middleware.yml    # Middleware для безопасности
├── dynamic/              # Динамическая конфигурация
│   ├── dashboard.yml     # Настройка панели управления 
│   └── usersfile         # Файл с пользователями для аутентификации
└── prometheus/           # Конфигурация Prometheus
    └── prometheus.yml    # Настройки Prometheus
```

## Добавление новых сервисов

Для добавления нового сервиса используйте следующий шаблон в `docker-compose.yml`:

```yaml
my-service:
  image: my-image
  container_name: my-service
  networks:
    - traefik-net
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.my-service.rule=Host(`my-service.example.com`)"
    - "traefik.http.routers.my-service.entrypoints=websecure"
    - "traefik.http.routers.my-service.tls.certresolver=myresolver"
    - "traefik.http.services.my-service.loadbalancer.server.port=8080"
```

## Устранение неполадок

### Проблемы с сертификатами

Если возникают проблемы с получением сертификатов:

1. Убедитесь, что правильно настроены DNS-записи
   ```bash
   # Проверка IP, на который указывает домен
   dig +short traefik.guide-it.ru
   # Сравните с IP вашего сервера
   curl -s ifconfig.me
   ```

2. Проверьте права доступа к файлу сертификатов:
   ```bash
   # Исправление прав доступа
   ./traefik-cli.sh fix
   ```

3. Проверьте логи на ошибки:
   ```bash
   ./traefik-cli.sh logs
   ```

### Проблемы с доступом к панели управления

Если панель управления недоступна:

1. Проверьте, запущен ли Traefik:
   ```bash
   ./traefik-cli.sh status
   ```

2. Проверьте прямой доступ через порт 8081:
   ```bash
   curl -s http://localhost:8081/api/version
   ```

3. Проверьте конфигурацию роутеров:
   ```bash
   curl -s http://localhost:8081/api/http/routers | grep -E "name|rule|service"
   ```

## Доступные утилиты

- **update-dashboard.sh** - перезапуск Traefik и проверка доступности панели управления
- **check-dashboard.sh** - подробная проверка всех возможных URL
- **reset-certs.sh** - сброс сертификатов при проблемах с HTTPS
- **check-cert.sh** - диагностика проблем с сертификатами

## Полезные команды

```bash
# Проверка прав доступа к acme.json
ls -la traefik/certs/acme.json
chmod 600 traefik/certs/acme.json

# Просмотр активных роутеров
curl -s http://localhost:8081/api/http/routers | grep -E "name|rule|service"

# Проверка конкретного URL
curl -k -I https://traefik.guide-it.ru/dashboard/

# Просмотр логов
docker compose logs -f traefik

# Перезапуск с проверками
./update-dashboard.sh
``` 