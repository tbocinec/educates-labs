# Demonstrates ARG instruction
# ARG defines variables that exist ONLY during the build — NOT at runtime.
# You can set them from the CLI with: docker build --build-arg BUILD_DATE=2025-01-01
#
# Notice: BUILD_DATE is used to set LABEL during build,
# but at runtime the CMD will show "not available at runtime".

FROM alpine:latest

ARG BUILD_DATE=unknown

LABEL build_date=$BUILD_DATE

CMD echo "BUILD_DATE is: ${BUILD_DATE:-not available at runtime}"
