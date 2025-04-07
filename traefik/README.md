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
./traefik-cli.sh start      # Запуск Traefik
./traefik-cli.sh stop       # Остановка Traefik
./traefik-cli.sh restart    # Перезапуск Traefik
./traefik-cli.sh logs       # Просмотр логов
./traefik-cli.sh status     # Проверка статуса
./traefik-cli.sh fix        # Исправление прав доступа
./traefik-cli.sh check-ssl  # Проверка SSL-сертификатов
./traefik-cli.sh reset-ssl  # Полный сброс SSL-сертификатов
./traefik-cli.sh help       # Показать справку
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

## Устранение неполадок с SSL

### Диагностика проблем с сертификатами

Для проверки статуса сертификатов:

```bash
# Проверить текущее состояние SSL
./traefik-cli.sh check-ssl

# Полный сброс сертификатов
./traefik-cli.sh reset-ssl
```

### Типичные проблемы и решения

1. **Отсутствие сертификатов**
   - Проверьте, что домены доступны из интернета
   - Временно отключите редирект с HTTP на HTTPS в traefik.yml
   - Проверьте, что порт 80 доступен для HTTP challenge

2. **Проблемы с правами доступа**
   - Для acme.json требуются права 600
   ```bash
   ./traefik-cli.sh fix
   ```

3. **Превышение лимитов Let's Encrypt**
   - Используйте staging-сервер для тестирования:
   ```yaml
   caServer: "https://acme-staging-v02.api.letsencrypt.org/directory"
   ```

4. **Ошибки в логах**
   - Проверьте логи на ошибки получения сертификатов:
   ```bash
   ./traefik-cli.sh logs | grep -i "certificate\|acme\|error"
   ```

### Использование HTTP для отладки

Если SSL не работает, вы можете временно получить доступ к панели через HTTP:
- http://traefik.guide-it.ru (требуется включенный роутер dashboard-http)

## Полезные команды

```bash
# Проверка прав доступа к acme.json
ls -la traefik/certs/acme.json
chmod 600 traefik/certs/acme.json

# Проверка DNS-записей
dig +short traefik.guide-it.ru

# Просмотр активных роутеров
curl -s http://localhost:8081/api/http/routers | grep -E "name|rule|service"

# Просмотр логов
docker compose logs -f traefik
``` 