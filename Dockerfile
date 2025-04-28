FROM nginx:alpine

COPY ./index.html /usr/share/nginx/html/index.html
COPY ./style.css /usr/share/nginx/html/style.css

CMD ["nginx", "-g", "daemon off;"]

VOLUME /usr/share/nginx/html

EXPOSE 80
