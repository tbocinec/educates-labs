# Demonstrates WORKDIR instruction
# WORKDIR sets the working directory for RUN, COPY, CMD, etc.
# If the directory doesn't exist, Docker creates it automatically.

FROM alpine:latest

WORKDIR /myapp

RUN pwd > /myapp/build-dir.txt

CMD ["cat", "/myapp/build-dir.txt"]
