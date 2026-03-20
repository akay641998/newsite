FROM nginxinc/nginx-unprivileged:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY main.js /usr/share/nginx/html/main.js

RUN chmod -R g=u /etc/nginx /usr/share/nginx/html /var/cache/nginx /var/run

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
