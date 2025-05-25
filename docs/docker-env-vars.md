# Service Environment Variables

## go-coffeeshop-web
- REVERSE_PROXY_URL: proxy-service:5000
- WEB_PORT: 8888

## go-coffeeshop-proxy
- APP_NAME
- GRPC_PRODUCT_HOST: product-service
- GRPC_PRODUCT_PORT: 5001
- GRPC_COUNTER_HOST: counter-service
- GRPC_COUNTER_PORT: 5002

## go-coffeeshop-barista / kitchen / counter
- APP_NAME
- IN_DOCKER: "true"
- PG_URL
- PG_DSN_URL
- RABBITMQ_URL

## go-coffeeshop-product
- APP_NAME
- POSTGRES_DB
- POSTGRES_USER
- POSTGRES_PASSWORD

## Ports
- PostgreSQL: 5432
- RabbitMQ: 5672 (amqp), 15672 (UI)
- Web: 8888
- Product: 5001
- Counter: 5002
- Proxy: 5000

