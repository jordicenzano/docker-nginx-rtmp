# Generate a docker for nginx+rtmp+ffmpeg
# by Jordi Cenzano (from: https://github.com/brocaar/nginx-rtmp-dockerfile)
# VERSION               1.0.0

FROM ubuntu:trusty
MAINTAINER jordi.cenzano@gmail.com

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/nginx/sbin

# Versions
ENV NGINX_VERSION nginx-1.7.5
ENV NGINX_RTMP_MODULE_VERSION 1.1.6

# Update OS
RUN apt-get update -y && \
    apt-get update -y && \
    apt-get clean

# Install dependencies
RUN apt-get install -y --no-install-recommends build-essential \
    software-properties-common \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    git \
    wget 

# create directories
RUN mkdir /src /config /logs /data /static

# Download and decompress Nginx
WORKDIR /src
RUN wget https://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxf ${NGINX_VERSION}.tar.gz && \
    rm ${NGINX_VERSION}.tar.gz

# Download and decompress RTMP module
WORKDIR /src
RUN wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    tar -zxf v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    rm v${NGINX_RTMP_MODULE_VERSION}.tar.gz
    
# Build and install Nginx + RTMP module
# The default puts everything under /usr/local/nginx, so it's needed to change it explicitly.
WORKDIR /src/${NGINX_VERSION}
RUN ./configure --add-module=/src/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} \
    --conf-path=/config/nginx.conf \
    --error-log-path=/logs/error.log \
    --http-log-path=/logs/access.log && \
    make && \
    make install

# Forward logs to Docker
RUN ln -sf /dev/stdout /logs/access.log && \
    ln -sf /dev/stderr /logs/error.log

# Set up config file
COPY ./conf/nginx.conf /config/nginx.conf

# Copy static contents
COPY static /static

#Expose RTMP port
EXPOSE 1935

# Entry point
ENTRYPOINT ["nginx"]