# Stage 1 — Build nginx with otel module
FROM alpine:3.19 AS builder

RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    curl \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    grpc-dev \
    protobuf-dev \
    re2-dev \
    abseil-cpp-dev

ENV NGINX_VERSION=1.27.4
RUN curl -O http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xzf nginx-${NGINX_VERSION}.tar.gz

RUN git clone --depth 1 --recurse-submodules \
    https://github.com/nginxinc/nginx-otel.git

RUN cd nginx-${NGINX_VERSION} && \
    ./configure \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/run/nginx.pid \
      --user=nginx \
      --group=nginx \
      --with-compat \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_stub_status_module \
      --add-dynamic-module=../nginx-otel && \
    make && make install

# Stage 2 — Runtime image
FROM alpine:3.19

RUN apk add --no-cache \
    pcre2 \
    openssl \
    grpc \
    protobuf \
    re2 \
    abseil-cpp && \
    addgroup -S nginx && \
    adduser -S -G nginx nginx

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/lib/nginx/modules /usr/lib/nginx/modules

RUN mkdir -p /var/log/nginx /var/cache/nginx /run /usr/share/nginx/html && \
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /etc/nginx /run /usr/share/nginx/html

COPY index.html /usr/share/nginx/html/index.html
COPY style.css  /usr/share/nginx/html/style.css
COPY main.js    /usr/share/nginx/html/main.js
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]
