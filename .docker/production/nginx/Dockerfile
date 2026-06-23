FROM nginx:1.31.2

COPY ./.docker/production/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./.docker/production/html/index.html /usr/share/nginx/html/

RUN echo "start nginx"
