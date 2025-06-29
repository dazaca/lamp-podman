¡Claro, David! Vamos a montar un entorno **LAMP con MariaDB** en **Podman**, desde cero, pasito a pasito. Usaremos **dos contenedores separados**: uno para Apache + PHP (con mysqli) y otro para la base de datos MariaDB. Todo se conectará usando una red de Podman. Prepárate porque… ¡va a estar genial! 🚀

---

## 🧱 Estructura general

- **Contenedor 1**: Apache + PHP + mysqli → Servidor web
- **Contenedor 2**: MariaDB → Base de datos
- Ambos conectados por una red virtual compartida

---

## 🧰 Paso 1: Crea carpeta del proyecto

```bash
mkdir -p ~/lamp-podman/web
cd ~/lamp-podman
```

En `web/` pondremos tu sitio PHP. Crea un archivo de prueba:

```bash
echo "<?php phpinfo(); ?>" > web/index.php
```

---

## 🌐 Paso 2: Crea red de Podman para que se comuniquen

```bash
podman network create redlamp
```

---

## 🧑‍🍳 Paso 3: Crea `Containerfile` para Apache + PHP

En el directorio raíz (`lamp-podman/`):

```bash
nano Containerfile
```

Y pega esto dentro:

```Dockerfile
FROM fedora:latest

RUN dnf -y install httpd php php-mysqlnd && \
    dnf clean all

COPY web/ /var/www/html/
EXPOSE 80

CMD ["httpd", "-DFOREGROUND"]
```

---

## 🏗️ Paso 4: Construye la imagen del servidor web

```bash
podman build -t servidor-web .
```

---

## 🛢️ Paso 5: Inicia el contenedor de MariaDB

```bash
podman run -d \
  --name mariadb \
  --network redlamp \
  -e MYSQL_ROOT_PASSWORD=clave123 \
  -e MYSQL_DATABASE=prueba \
  -e MYSQL_USER=usuario \
  -e MYSQL_PASSWORD=clave123 \
  docker.io/library/mariadb:latest
```

Esto lanza MariaDB con:
- base de datos `prueba`
- usuario: `usuario`
- contraseña: `clave123`

---

## 🚀 Paso 6: Inicia tu contenedor web

```bash
podman run -d \
  --name apachephp \
  --network redlamp \
  -p 8080:80 \
  servidor-web
```

---

## 🔎 Paso 7: Prueba en navegador

Abre en tu navegador:

```
http://localhost:8080
```

Deberías ver la página de `phpinfo()` mostrando que PHP y mysqli están activos 💡

---

## 🧪 Paso 8: ¿Cómo conectar PHP a MariaDB?

Crea un nuevo archivo en `web/test-db.php`:

```php
<?php
$conexion = new mysqli("mariadb", "usuario", "clave123", "prueba");

if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}
echo "✅ Conexión exitosa a la base de datos.";
?>
```

Luego actualiza el contenedor con:

```bash
podman cp web/test-db.php apachephp:/var/www/html/
```

Y visita:

```
http://localhost:8080/test-db.php
```

👉 Verás si se conecta correctamente.

---







¡Genial, David! Vamos a dejar tu contenedor **pulido y listo para desplegar con un solo `podman run`**: que cree el socket, arranque `php-fpm` y `httpd`, y te permita actualizar el código sin tener que reconstruir la imagen cada vez.

---

## 🧾 `Containerfile` con arranque automático + buenas prácticas

Guarda esto como tu `Containerfile` en el directorio `~/lamp-podman/`:

```Dockerfile
FROM fedora:latest

# Instala Apache, PHP, mysqli y FPM
RUN dnf -y install httpd php php-mysqlnd php-fpm && \
    dnf clean all

# Crea el socket directory de PHP-FPM
RUN mkdir -p /run/php-fpm

# Configura permisos por si Apache ejecuta como apache:apache
RUN chown -R apache:apache /run/php-fpm /var/lib/php /var/www/html

# Crea punto de montaje para código fuente desde el host (¡sin copiar!)
VOLUME ["/var/www/html"]

# Expón el puerto web
EXPOSE 80

# Comando que arranca php-fpm y luego httpd en primer plano
CMD /bin/bash -c "php-fpm && httpd -DFOREGROUND"
```

---

## 📁 Ventaja de usar `VOLUME` en lugar de `COPY`

Usando `VOLUME`:

- Puedes mantener tu código en el host (tu carpeta `web/`)
- No necesitas reconstruir la imagen al modificar los archivos
- Facilita el desarrollo en tiempo real

---

## 🏁 Cómo usarlo

### 1. Asegúrate de tener tu código fuente en una carpeta como `~/lamp-podman/web/`

Por ejemplo, algo como:

```bash
echo '<?php echo "Hola desde el contenedor!"; ?>' > ~/lamp-podman/web/index.php
```

---

### 2. Construye la imagen

```bash
cd ~/lamp-podman
podman build -t servidor-web .
```

---

### 3. Lanza el contenedor montando el código

```bash
podman run -d \
  --name apachephp \
  --network redlamp \
  -p 8080:80 \
  -v ~/lamp-podman/web:/var/www/html:Z \
  servidor-web
```

💡 El sufijo `:Z` aplica contexto SELinux si está habilitado en Fedora.

---

## 🎯 ¿Qué has logrado ahora?

- Apache y `php-fpm` arrancan solos
- Tu código vive en tu host, editable desde fuera
- Puedes usar VS Code para modificar tus archivos sin reiniciar el contenedor
- PHP ya puede conectar con MariaDB gracias a la red `redlamp`

---
------------------------------------------------------------------------------------------------------------------------

¡Perfecto, David! Vamos a crear un archivo `podman-compose.yml` (compatible con `docker-compose` y `podman-compose`) para que con un solo comando puedas levantar:

- Tu servidor web (Apache + PHP + PHP-FPM)
- Tu base de datos (MariaDB)
- Una red común que los conecte
- Volúmenes persistentes para el código fuente y los datos de la base 💾

---

## 🧾 Paso 1: Crea el archivo `podman-compose.yml`

En tu carpeta `~/lamp-podman/`, crea un nuevo archivo llamado `podman-compose.yml` (o si usas `docker-compose`, simplemente `docker-compose.yml` también funciona con Podman):

```yaml
version: '3.8'

services:
  apachephp:
    image: servidor-web
    container_name: apachephp
    build:
      context: .
      dockerfile: Containerfile
    ports:
      - "8080:80"
    volumes:
      - ./web:/var/www/html:Z
    networks:
      - redlamp
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:latest
    container_name: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: clave123
      MYSQL_DATABASE: prueba
      MYSQL_USER: usuario
      MYSQL_PASSWORD: clave123
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - redlamp

networks:
  redlamp:

volumes:
  mariadb_data:
```

---

## 📁 Estructura esperada

Tu carpeta `~/lamp-podman` ahora debe tener:

```
lamp-podman/
├── Containerfile
├── podman-compose.yml
└── web/
    ├── index.php
    └── test-db.php (si quieres probar la base)
```

---

## 🚀 Paso 2: Inicia todo el stack

Desde la carpeta raíz del proyecto, ejecuta:

```bash
podman-compose up -d
```

Esto construirá la imagen `servidor-web` (si no existe), creará ambas redes y servicios, y lanzará todo automáticamente en segundo plano 🧙‍♂️

---

## 🧪 Paso 3: Prueba la conexión entre PHP y la base de datos

En tu archivo `web/test-db.php`, pon algo así:

```php
<?php
$conn = new mysqli("mariadb", "usuario", "clave123", "prueba");

if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}
echo "✅ Conexión exitosa a la base de datos.";
?>
```

Luego abre en el navegador:

```
http://localhost:8080/test-db.php
```

---

## 🎯 Ventajas

- Un solo comando `podman-compose up -d` lo inicia todo
- Volúmenes persistentes para que los datos sobrevivan reinicios
- Código fuente editable sin reconstruir la imagen

---













¿Quieres que te prepare también un `Makefile` o script `.sh` para levantarlo y detenerlo con comandos tipo `make start` / `make stop`? 😄





