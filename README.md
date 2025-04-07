# Traefik - Базовая настройка

Этот репозиторий содержит базовую конфигурацию Traefik для использования с Docker.

## Структура проекта

```
.
├── docker-compose.yml       # Основной файл конфигурации Docker Compose (верхний уровень)
├── traefik/
│   ├── traefik.yml          # Основная конфигурация Traefik
│   ├── docker-compose.yml   # Docker Compose для запуска Traefik
│   ├── certs/               # Каталог для сертификатов Let's Encrypt
│   │   └── acme.json        # Файл для хранения сертификатов
│   ├── config/              # Каталог конфигурации Traefik
│   │   ├── middleware.yml   # Конфигурация middleware (безопасность, авторизация)
│   │   └── nginx/           # Конфигурация для сервисов NGINX
│   └── dynamic/             # Каталог динамической конфигурации
│       ├── dashboard.yml    # Конфигурация панели управления
│       └── usersfile        # Файл с пользователями для базовой аутентификации
└── README.md                # Этот файл
```

## Подготовка к запуску

1. Создайте необходимые каталоги (если отсутствуют):

```bash
mkdir -p traefik/certs traefik/dynamic traefik/config/nginx
```

2. Создайте файл для хранения сертификатов с правильными правами:

```bash
touch traefik/certs/acme.json
chmod 600 traefik/certs/acme.json
```

3. Настройте доменные имена в конфигурационных файлах:
   - В `traefik/dynamic/dashboard.yml` измените `traefik.your-domain.ru` на ваш домен
   - В `traefik/docker-compose.yml` измените `traefik.bp.guide-it.ru` на ваш домен

## Генерация пароля для dashboard

Для создания пользователей и паролей для доступа к панели управления:

```bash
apt install apache2-utils
htpasswd -nb admin НОВЫЙ_ПАРОЛЬ
```

Полученную строку нужно добавить в:
- `traefik/dynamic/usersfile` (каждого пользователя с новой строки)
- или обновить в `traefik/config/middleware.yml`

## Запуск Traefik

Запустите Traefik из директории `traefik`:

```bash
cd traefik
docker-compose up -d
```

## Доступ к панели управления

После запуска панель управления будет доступна по адресу:
- https://traefik.your-domain.ru (замените на ваш настроенный домен)

## Добавление новых сервисов

Для добавления нового сервиса используйте следующий шаблон в docker-compose:

```yaml
myservice:
  image: myimage
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.myservice.rule=Host(`myservice.your-domain.ru`)"
    - "traefik.http.routers.myservice.entrypoints=websecure"
    - "traefik.http.routers.myservice.tls.certResolver=myresolver"
    - "traefik.http.services.myservice.loadbalancer.server.port=8080"
```

## Деплой приложений через deploy-cmd

Проект включает инструменты для автоматизации деплоя:

1. Соберите образ deploy-cmd:
```bash
cd deploy-cmd
docker build -t bp/deploy-cmd .
```

2. Настройте GitLab CI/CD для использования образа bp/deploy-cmd

3. Конфигурация деплоя находится в файле `deploy-config.yml`

## Рекомендации по безопасности

1. Используйте HTTPS (TLS) для всех сервисов
2. Регулярно обновляйте пароли для доступа к панели управления
3. Применяйте middleware для дополнительной защиты (rateLimit, ipWhiteList)

## Дополнительная информация

- [Официальная документация Traefik](https://doc.traefik.io/traefik/)
- [Примеры конфигурации Traefik](https://doc.traefik.io/traefik/user-guides/docker-compose/)
- [Reference динамической конфигурации](https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/)
