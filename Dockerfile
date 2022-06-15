FROM alpine:latest

RUN set -ex \
    && apk add --no-cache shadow \
    && apk add --no-cache apache2 apache2-ctl php81 php81-apache2 php81-dom php81-exif php81-fileinfo php81-mbstring php81-openssl php81-pdo php81-pdo_sqlite php81-pecl-imagick php81-xml php81-zip

RUN set -ex \
    && sed -Ei 's/#(LoadModule rewrite_module modules\/mod_rewrite.so)/\1/' /etc/apache2/httpd.conf \
    && sed -Ei 's/(ErrorLog|CustomLog) [^.]+\.log/\1 \/dev\/null/' /etc/apache2/httpd.conf \
    && sed -Ei 's/AllowOverride [nN]one/AllowOverride All/' /etc/apache2/httpd.conf \
    && printf 'MaxSpareServers 2\nMinSpareServers 1\n' >> /etc/apache2/httpd.conf

RUN set -ex \
    && chown -R apache:apache /var/www/localhost/htdocs \
    && groupmod -g 1000 apache \
    && usermod -u 1000 apache

RUN set -ex \
    && rm -f /var/www/localhost/htdocs/index.html

COPY --chown=apache wordpress /var/www/localhost/htdocs

ENTRYPOINT ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
