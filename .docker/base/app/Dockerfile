FROM php:8.5.7-fpm-bookworm AS base

# install command for composer & php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# install packages
RUN apt-get update && apt-get install -y \
  busybox-static \
  curl \
  git \
  unzip \
  tar \
  nano \
  poppler-utils \
  tesseract-ocr \
  tesseract-ocr-jpn \
  libmagickwand-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install php extensions
RUN install-php-extensions \
  pdo_mysql \
  bcmath \
  mbstring \
  zip \
  opcache \
  gd \
  intl \
  imagick \
  redis

# install node
RUN curl -sL https://deb.nodesource.com/setup_24.x | bash -  \
  && apt-get update && apt-get install -y \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && npm install -g npm
