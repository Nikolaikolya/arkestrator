# Traefik - Базовая настройка

Этот репозиторий содержит базовую конфигурацию Traefik для использования с Docker.

## Структура проекта

```
.
├── traefik/
│   ├── traefik.yml          # Основная конфигурация Traefik
│   ├── docker-compose.yml   # Docker Compose для запуска Traefik
│   ├── .env                 # Переменные окружения
│   ├── certs/               # Каталог для сертификатов Let's Encrypt
│   │   └── acme.json        # Файл для хранения сертификатов
│   ├── logs/                # Каталог для логов Traefik
│   ├── config/              # Каталог конфигурации Traefik
│   │   ├── middleware.yml   # Конфигурация middleware (безопасность, авторизация)
│   │   └── nginx/           # Конфигурация для сервисов NGINX
│   ├── dynamic/             # Каталог динамической конфигурации
│   │   ├── dashboard.yml    # Конфигурация панели управления
│   │   ├── monitoring.yml   # Конфигурация мониторинга (Prometheus, Grafana)
│   │   └── usersfile        # Файл с пользователями для базовой аутентификации
│   └── prometheus/          # Конфигурация Prometheus
│       └── prometheus.yml   # Настройки сбора метрик
├── deploy-cmd/              # Утилита для деплоя приложений
│   ├── Dockerfile           # Dockerfile для сборки утилиты deploy-cmd
│   ├── .gitlab-ci.yml       # Конфигурация CI/CD для GitLab
│   └── deploy-config.yml    # Конфигурация деплоя
└── README.md                # Этот файл
```

## Подготовка к запуску (ручная)

1. Создайте необходимые каталоги (если отсутствуют):

```bash
mkdir -p traefik/certs traefik/dynamic traefik/logs traefik/config/nginx traefik/prometheus
```

2. Создайте файл для хранения сертификатов с правильными правами:

```bash
touch traefik/certs/acme.json
chmod 600 traefik/certs/acme.json  # Для Linux/Mac
```

3. Настройте доменные имена:
   - Откройте файл `.env` и измените значения доменов
   - Или отредактируйте напрямую файлы в `dynamic/`

## Генерация пароля для dashboard

Для создания пользователей и паролей для доступа к панели управления:

```bash
apt install apache2-utils  # Для Debian/Ubuntu
yum install httpd-tools    # Для CentOS/RHEL
htpasswd -nb admin НОВЫЙ_ПАРОЛЬ
```

Полученную строку нужно добавить в:
- `traefik/dynamic/usersfile` (каждого пользователя с новой строки)
- или обновить в `traefik/config/middleware.yml`

## Запуск Traefik

Для полной установки с копированием файла
```bash
chmod +x ./initial.sh && ./initial.sh
```

```bash
cd traefik
docker-compose up -d
```

## Доступ к панели управления и мониторингу

После запуска будут доступны:
- Панель управления: https://traefik.guide-it.ru
- Prometheus: https://prometheus.guide-it.ru
- Grafana: https://grafana.guide-it.ru

## Устранение неполадок с сертификатами

Если есть проблемы с получением сертификатов:

1. Проверьте, что домены настроены корректно и указывают на ваш сервер
2. Убедитесь, что порты 80 и 443 доступны из интернета и не заблокированы файрволом
3. Проверьте логи Traefik:
   ```bash
   docker-compose logs -f traefik
   ```
4. Если используется httpChallenge, убедитесь, что трафик на порт 80 попадает в Traefik
5. Для тестирования можно временно использовать самоподписанные сертификаты

Для полного сброса сертификатов:
```bash
rm traefik/certs/acme.json
touch traefik/certs/acme.json
chmod 600 traefik/certs/acme.json  # Для Linux/Mac
docker-compose down && docker-compose up -d
```

## Добавление новых сервисов

Для добавления нового сервиса используйте следующий шаблон:

```yaml
myservice:
  image: myimage
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.myservice.rule=Host(`myservice.guide-it.ru`)"
    - "traefik.http.routers.myservice.entrypoints=websecure"
    - "traefik.http.routers.myservice.tls.certResolver=myresolver"
    - "traefik.http.services.myservice.loadbalancer.server.port=8080"
```

## Рекомендации по безопасности

1. Используйте HTTPS (TLS) для всех сервисов
2. Регулярно обновляйте пароли для доступа к панели управления
3. Применяйте middleware для дополнительной защиты (rateLimit, ipWhiteList)
4. Используйте переменные окружения (.env) для хранения чувствительных данных
5. Регулярно обновляйте версии образов Docker

## Дополнительная информация

- [Официальная документация Traefik](https://doc.traefik.io/traefik/)
- [Примеры конфигурации Traefik](https://doc.traefik.io/traefik/user-guides/docker-compose/)
- [Reference динамической конфигурации](https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/)
