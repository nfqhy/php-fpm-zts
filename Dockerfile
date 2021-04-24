FROM php:7.2-fpm
# FROM php:7.2-zts

ENV PHP_EXTRA_CONFIGURE_ARGS='--enable-maintainer-zts --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-cgi'
#RUN set -eux; \
#    savedAptMark="$(apt-mark showmanual)"; \
#    apt-get update; \
#    apt-get install -y --no-install-recommends gnupg dirmngr; \
#    rm -rf /var/lib/apt/lists/*; \
#    mkdir -p /usr/src; \
#    cd /usr/src; \
#    curl -fsSL -o php.tar.xz "$PHP_URL"; \
#    if [ -n "$PHP_SHA256" ]; then echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; 	fi; if [ -n "$PHP_ASC_URL" ]; then 		curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; 		export GNUPGHOME="$(mktemp -d)"; 		for key in $GPG_KEYS; do 			gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; 		done; 		gpg --batch --verify php.tar.xz.asc php.tar.xz; 		gpgconf --kill all; 		rm -rf "$GNUPGHOME"; 	fi; 		apt-mark auto '.*' > /dev/null; 	apt-mark manual $savedAptMark > /dev/null; 	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libargon2-dev libcurl4-openssl-dev libedit-dev \
    libsodium-dev libsqlite3-dev libssl-dev libxml2-dev \
    zlib1g-dev ${PHP_EXTRA_BUILD_DEPS:-} ; \
    rm -rf /var/lib/apt/lists/*; \
    export 	CFLAGS="$PHP_CFLAGS"  CPPFLAGS="$PHP_CPPFLAGS" 	LDFLAGS="$PHP_LDFLAGS" 	; \
    docker-php-source extract; \
    cd /usr/src/php; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; 	\
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    ./configure  --build="$gnuArch" --with-config-file-path="$PHP_INI_DIR"  --with-config-file-scan-dir="$PHP_INI_DIR/conf.d"  \
    --enable-option-checking=fatal  --with-mhash  --with-pic --enable-ftp --enable-mbstring   --enable-mysqlnd  --with-password-argon2  \
    --with-sodium=shared  --with-pdo-sqlite=/usr  --with-sqlite3=/usr  --with-curl  --with-libedit  --with-openssl  --with-zlib \
    $(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit')  --with-libdir="lib/$debMultiarch" ${PHP_EXTRA_CONFIGURE_ARGS:-} ; \
    make -j "$(nproc)"; find -type f -name '*.a' -delete; 	make install; \
    find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; \
    make clean; cp -v php.ini-* "$PHP_INI_DIR/"; cd /; \
    docker-php-source delete; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search  | cut -d: -f1 | sort -u | xargs -r apt-mark manual 	; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    pecl update-channels; 	rm -rf /tmp/pear ~/.pearrc; \
    php --version

# if [ ! -d /usr/include/curl ]; then 		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; 	fi;  \
# RUN set -eux; 		savedAptMark="$(apt-mark showmanual)"; 	apt-get update; 	apt-get install -y --no-install-recommends 		libargon2-dev 		libcurl4-openssl-dev 		libedit-dev 		libsodium-dev 		libsqlite3-dev 		libssl-dev 		libxml2-dev 		zlib1g-dev 		${PHP_EXTRA_BUILD_DEPS:-} 	; 	rm -rf /var/lib/apt/lists/*; 		export 		CFLAGS="$PHP_CFLAGS" 		CPPFLAGS="$PHP_CPPFLAGS" 		LDFLAGS="$PHP_LDFLAGS" 	; 	docker-php-source extract; 	cd /usr/src/php; 	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; 	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; 	if [ ! -d /usr/include/curl ]; then 		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; 	fi; 	./configure 		--build="$gnuArch" 		--with-config-file-path="$PHP_INI_DIR" 		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" 				--enable-option-checking=fatal 				--with-mhash 				--with-pic 				--enable-ftp 		--enable-mbstring 		--enable-mysqlnd 		--with-password-argon2 		--with-sodium=shared 		--with-pdo-sqlite=/usr 		--with-sqlite3=/usr 				--with-curl 		--with-libedit 		--with-openssl 		--with-zlib 				$(test "$gnuArch" = 's390x-linux-gnu' && echo '--without-pcre-jit') 		--with-libdir="lib/$debMultiarch" 				${PHP_EXTRA_CONFIGURE_ARGS:-} 	; 	make -j "$(nproc)"; 	find -type f -name '*.a' -delete; 	make install; 	find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; 	make clean; 		cp -v php.ini-* "$PHP_INI_DIR/"; 		cd /; 	docker-php-source delete; 		apt-mark auto '.*' > /dev/null; 	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; 	find /usr/local -type f -executable -exec ldd '{}' ';' 		| awk '/=>/ { print $(NF-1) }' 		| sort -u 		| xargs -r dpkg-query --search 		| cut -d: -f1 		| sort -u 		| xargs -r apt-mark manual 	; 	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; 		pecl update-channels; 	rm -rf /tmp/pear ~/.pearrc; 		php --version

RUN docker-php-ext-enable sodium
RUN { echo '#!/bin/sh'; echo 'exec pkg-config "$@" freetype2'; } > /usr/local/bin/freetype-config && chmod +x /usr/local/bin/freetype-config
RUN set -eux; 	cd /usr/local/etc; 	if [ -d php-fpm.d ]; then 		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; 		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; 	else 		mkdir php-fpm.d; 		cp php-fpm.conf.default php-fpm.d/www.conf; 		{ 			echo '[global]'; 			echo 'include=etc/php-fpm.d/*.conf'; 		} | tee php-fpm.conf; 	fi; 	{ 		echo '[global]'; 		echo 'error_log = /proc/self/fd/2'; 		echo; 		echo '[www]'; 		echo '; if we send this to /proc/self/fd/1, it never appears'; 		echo 'access.log = /proc/self/fd/2'; 		echo; 		echo 'clear_env = no'; 		echo; 		echo '; Ensure worker stdout and stderr are sent to the main error log.'; 		echo 'catch_workers_output = yes'; 	} | tee php-fpm.d/docker.conf; 	{ 		echo '[global]'; 		echo 'daemonize = no'; 		echo; 		echo '[www]'; 		echo 'listen = 9000'; 	} | tee php-fpm.d/zz-docker.conf

# Install PHP and composer dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    git curl openssl libicu-dev libmcrypt-dev zlib1g-dev libjpeg-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev libbz2-dev zip unzip \
    libcurl4-openssl-dev pkg-config libssl-dev \
    libzip-dev bison lsb-base autoconf build-essential \
    libltdl-dev libxml2-dev libxslt1-dev libpspell-dev libenchant-dev \
    libjpeg62-turbo-dev libmariadb-dev-compat libmariadb-dev libreadline-dev

# Clear out the local repository of retrieved package files
RUN apt-get clean

# semaphore functions are now available
RUN docker-php-ext-install sysvmsg sysvsem sysvshm

# Shared Memory
RUN docker-php-ext-install shmop

# Install needed PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl soap pcntl pspell enchant gettext exif calendar simplexml wddx opcache pdo_mysql zip bcmath sockets

# Install needed PECL extensions
RUN pecl config-set php_ini "${PHP_INI_DIR}/php.ini"
RUN pecl install mongodb mcrypt-1.0.2 && docker-php-ext-enable mongodb mcrypt

# Install GD
RUN docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Sync
RUN pecl install sync

# Parallel
RUN pecl install parallel && echo "extension=parallel.so" > /usr/local/etc/php/conf.d/docker-php-ext-parallel.ini

# './configure'  '--build=x86_64-linux-gnu' '--with-config-file-path=/usr/local/etc/php' '--with-config-file-scan-dir=/usr/local/etc/php/conf.d' '--enable-option-checking=fatal' '--with-mhash' '--with-pic' '--enable-ftp' '--enable-mbstring' '--enable-mysqlnd' '--with-password-argon2' '--with-sodium=shared' '--with-pdo-sqlite=/usr' '--with-sqlite3=/usr' '--with-curl' '--with-libedit' '--with-openssl' '--with-zlib' '--with-libdir=lib/x86_64-linux-gnu' '--enable-maintainer-zts' '--disable-cgi' 'build_alias=x86_64-linux-gnu'
# pthreads
RUN debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    curdir=`pwd` && phpConfig=`which php-config` && cd /tmp && git clone https://github.com/krakjoe/pthreads.git && \
    cd pthreads && phpize && \
    ./configure --with-libdir="lib/$debMultiarch" --enable-pthreads=shared --with-php-config=$phpConfig && \
    make && make install && cd $curdir && rm -rf /tmp/pthreads && echo "extension=pthreads.so" > "${PHP_INI_DIR}/php-ext-pthreads.ini"

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN php -r "echo PHP_ZTS;" && php -r "print_r(class_exists('Thread'));"

WORKDIR /var/www
