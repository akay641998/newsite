FROM nginxinc/nginx-unprivileged:stable-alpine

COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY main.js /usr/share/nginx/html/main.js

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
