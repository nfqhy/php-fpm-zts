# php-fpm-zts
PHP FPM ZTS with parallel and pthreads for CLI

# Build and run
```
docker build . -t php-fpm-zts:parallel-ptheads
docker run -P -it --name=phpfpmthreads php-fpm-zts:parallel-ptheads bash
```
