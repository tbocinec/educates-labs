# Demonstrates ENV instruction
# ENV sets environment variables available during build AND at runtime.
# Values can be overridden at runtime with: docker run -e APP_ENV=development

FROM alpine:latest

ENV APP_VERSION=1.0.0
ENV APP_ENV=production

CMD echo "Running $APP_VERSION in $APP_ENV"
