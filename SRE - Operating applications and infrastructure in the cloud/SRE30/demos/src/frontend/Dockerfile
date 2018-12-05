FROM node:10.12.0-jessie as builder

ENV PRODUCT_SERVICE_BASE_URL '%%PRODUCT_SERVICE_BASE_URL%%'
ENV INVENTORY_SERVICE_BASE_URL '%%INVENTORY_SERVICE_BASE_URL%%'

RUN mkdir /frontend
WORKDIR /frontend
COPY . .
RUN npm install && npm run build

FROM alpine:latest

EXPOSE 8080
ENV PORT 8080
ENV PRODUCT_SERVICE_BASE_URL http://localhost:8000
ENV INVENTORY_SERVICE_BASE_URL http://localhost:5000

RUN apk add --no-cache curl bash \
    && curl https://getcaddy.com | bash -s personal \
    && mkdir -p /app/dist
WORKDIR /app/
COPY --from=builder /frontend/dist/ ./dist/
COPY --from=builder /frontend/docker-startup.sh .

CMD ./docker-startup.sh