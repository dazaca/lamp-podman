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

