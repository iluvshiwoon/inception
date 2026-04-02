FROM debian:bookworm

RUN apt-get update && apt-get install -y wget php8.2 php8.2-mysql

RUN mkdir -p /var/www/html

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/index.php

WORKDIR /var/www/html

EXPOSE 8080

# Start PHP server on index.php
CMD ["php", "-S", "0.0.0.0:8080", "index.php"]
