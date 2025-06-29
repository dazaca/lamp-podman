# Makefile para levantar y apagar el entorno LAMP con Podman Compose

up:
    @echo "🔼 Iniciando entorno..."
    @podman-compose up -d

down:
    @echo "🔻 Apagando entorno..."
    @podman-compose down

logs:
    @podman-compose logs -f

ps:
    @podman ps

restart:
    @podman-compose down
    @podman-compose up -d

