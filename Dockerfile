# Estágio de construção das dependências do Composer
FROM composer:2.7 AS vendor
COPY database/ database/
COPY composer.json composer.json
COPY composer.lock composer.lock
RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

# Imagem final usando FrankenPHP
FROM dunglas/frankenphp:1.1-php8.4-alpine

# Instalar extensões necessárias (ajuste conforme seu app)
RUN install-php-extensions \
    pcntl \
    gd \
    intl \
    zip \
    opcache

# Configurações de produção do PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copiar os arquivos da aplicação
COPY . /app
COPY --from=vendor /app/vendor /app/vendor

# Definir diretório de trabalho
WORKDIR /app

# Variáveis de ambiente para o Octane/FrankenPHP
ENV AUTOCONF_CADDYFILE_SERVER_NAME="0.0.0.0"
ENV SERVER_NAME=":8080"
ENV LARAVEL_OCTANE_SERVER="frankenphp"

# Permissões de escrita para o storage e cache
RUN chmod -R 775 storage bootstrap/cache

# Otimização do Laravel (Crucial para Cloud Run)
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

# Expor a porta que o Cloud Run espera (padrão 8080)
EXPOSE 8080

# Comando para iniciar o Octane com FrankenPHP
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8080"]
