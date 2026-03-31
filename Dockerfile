# Stage 1 — Build nginx with otel module
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    libssl-dev \
    libpcre2-dev \
    zlib1g-dev \
    libgrpc-dev \
    libprotobuf-dev \
    protobuf-compiler \
    protobuf-compiler-grpc \
    libre2-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

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
    make && make install && \
    mkdir -p /usr/lib/nginx/modules && \
    find / -name "ngx_otel_module.so" 2>/dev/null && \
    cp /nginx-${NGINX_VERSION}/objs/ngx_otel_module.so /usr/lib/nginx/modules/

# Stage 2 — Runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libpcre2-8-0 \
    libssl3 \
    zlib1g \
    libgrpc++1.51 \
    libprotobuf32 \
    libre2-9 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r nginx \
    && useradd -r -g nginx nginx

COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/lib/nginx/modules/ngx_otel_module.so /usr/lib/nginx/modules/ngx_otel_module.so

RUN mkdir -p /var/log/nginx /var/cache/nginx /run /usr/share/nginx/html && \
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /etc/nginx /run /usr/share/nginx/html

COPY index.html /usr/share/nginx/html/index.html
COPY style.css  /usr/share/nginx/html/style.css
COPY main.js    /usr/share/nginx/html/main.js
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080
USER nginx
CMD ["nginx", "-g", "daemon off;"]
