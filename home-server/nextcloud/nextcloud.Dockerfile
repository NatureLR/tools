FROM nextcloud:latest

RUN sed -i -E 's/(deb|security).debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt update  && \
    apt install -y smbclient && \
    apt install -y libsmbclient-dev && \
    pecl install smbclient && \
    docker-php-ext-enable smbclient

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \