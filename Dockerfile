ARG IMAGE_TARGET=arm32v6/python:3-alpine

#### FIRST STAGE QEMU ####
FROM alpine AS qemu
ARG QEMU_VERSION=v2.12.0
ARG QEMU=x86_64
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static

#### SECOND STAGE IS THE RUNTIME ENVIRONMENT ####
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/

ARG SRC_FOLDER=src
ARG INDEX_FILE=index.py
ARG HANDLER_FILE=handler.py
ARG OPEN_FAAS_VERSION=0.9.11
ARG ARCHITECTURE=arm32v6
ARG WATCHDOG_ARCH=-armhf

RUN mkdir -p /home/app
RUN apk --no-cache add curl \
    && echo "Pulling watchdog binary from Github for architecture ${WATCHDOG_ARCH}." \
    && curl -sSL https://github.com/openfaas/faas/releases/download/${OPEN_FAAS_VERSION}/fwatchdog${WATCHDOG_ARCH} > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && cp /usr/bin/fwatchdog /home/app \
    && apk del curl --no-cache
    
# Add non root user
RUN addgroup -S app && adduser app -S -G app
RUN chown app /home/app

USER app
ENV PATH=$PATH:/home/app/.local/bin 

WORKDIR /home/app
COPY ${INDEX_FILE} index.py
COPY requirements.txt requirements.txt
RUN pip3 install --user -r requirements.txt

RUN mkdir -p function
RUN touch ./function/__init__.py

WORKDIR /home/app/function
COPY ${SRC_FOLDER}/requirements.txt .
RUN pip3 install --user -r requirements.txt

WORKDIR /home/app
COPY ${SRC_FOLDER} function

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="python3 handler.py"
# Set to true to see request in function logs
ENV write_debug="true"

EXPOSE 8080
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1
CMD [ "fwatchdog" ]
