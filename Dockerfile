# ============================================================
# Dockerfile — Nginx static site
# Compatible with OpenShift (runs as non-root, port 8080)
# ============================================================

# Use the official unprivileged nginx image
FROM nginx:1.27-alpine

# Remove the default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static website files into the nginx web root
COPY index.html  /usr/share/nginx/html/index.html
COPY style.css   /usr/share/nginx/html/style.css
COPY main.js     /usr/share/nginx/html/main.js

# OpenShift runs containers as an arbitrary non-root UID.
# Grant the root group (GID 0) write permissions so nginx can run.
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx      && \
    chown -R nginx:nginx /var/log/nginx         && \
    chown -R nginx:nginx /etc/nginx/conf.d      && \
    touch /var/run/nginx.pid                    && \
    chown -R nginx:nginx /var/run/nginx.pid     && \
    chmod -R g+rwX /var/cache/nginx             && \
    chmod -R g+rwX /var/log/nginx               && \
    chmod -R g+rwX /var/run

# Switch to non-root user (required for OpenShift)
USER nginx

# Expose the port nginx listens on (8080 is standard for OpenShift)
EXPOSE 8080

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
