ARG CENTOS_VERSION=8.3.2011
ARG NGINX_VERSION=1.21.0
ARG GEOLITE2_LICENSE_KEY=

FROM centos:$CENTOS_VERSION

RUN set -x \
    && groupadd -f -r -g 101 nginx \
    && useradd -r -m -d /var/cache/nginx -s /sbin/nologin -u 101 -G nginx -g nginx nginx

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf -y upgrade
RUN dnf -y install autoconf automake gd-devel git libtool libxml2-devel libxslt-devel make openssl-devel pcre-devel perl-ExtUtils-Embed wget zlib-devel

WORKDIR /tmp/build

ARG GEOLITE2_LICENSE_KEY
RUN mkdir {/usr/share/maxmind,GeoLite2-Country,GeoLite2-City} \
    && wget -qO- "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=$GEOLITE2_LICENSE_KEY&suffix=tar.gz" \
    | tar -xzv -C GeoLite2-Country --strip-components=1 \
    && mv GeoLite2-Country/*.mmdb /usr/share/maxmind \
    && wget -qO- "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$GEOLITE2_LICENSE_KEY&suffix=tar.gz" \
    | tar -xzv -C GeoLite2-City --strip-components=1 \
    && mv GeoLite2-City/*.mmdb /usr/share/maxmind

RUN git clone --recursive https://github.com/maxmind/libmaxminddb \
    && cd libmaxminddb/ \
    && ./bootstrap \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make check \
    && make install \
    && echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf \
    && ldconfig

RUN git clone https://github.com/leev/ngx_http_geoip2_module

ARG NGINX_VERSION
RUN wget -qO- "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
    | tar -xzv \
    && cd nginx-$NGINX_VERSION/ \
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_body_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_perl_module=dynamic \
    --with-http_auth_request_module \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-pcre \
    --with-pcre-jit \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-debug \
    --with-cc-opt='-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E' \
    --add-module=/tmp/build/ngx_http_geoip2_module \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && nginx -V

WORKDIR /

COPY nginx /etc/nginx

RUN rm -rf /tmp/build

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
