# Dockerfile for building NGINX with HTTP/3 support
ARG nginx_path=/opt/nginx
ARG tag=latest
ARG os=alpine

FROM ${os}:${tag} AS builder

# Install dependencies based on the OS type
ARG os
ARG tag

# Install dependencies for Alpine Linux
RUN [ "${os}" = "alpine" ] && apk upgrade --no-cache || echo "Skipping..." 
RUN [ "${os}" = "alpine" ] && apk add build-base perl linux-headers || echo "Skipping..." 

# Install dependencies for Ubuntu Linux
RUN [ "${os}" = "ubuntu" ] && apt-get update || echo "Skipping..." 
RUN [ "${os}" = "ubuntu" ] && apt-get install -y build-essential || echo "Skipping..." 

# Install dependencies for Debian Linux
RUN [ "${os}" = "debian" ] && apt-get update || echo "Skipping..." 
RUN [ "${os}" = "debian" ] && apt-get install -y build-essential || echo "Skipping..." 

# Install dependencies for Amazonlinux Linux
RUN [ "${os}" = "amazonlinux" ] && yum -y install tar gzip perl gcc || echo "Skipping..."

# Versions of NGINX and its dependencies
# NGINX
ARG NGINX_VERSION=1.28.0

# LIBS
ARG ZLIB_VERSION=1.3.1
ARG PCRE_VERSION=10.45
ARG OPENSSL_VERSION=3.5.0

WORKDIR /tmp

# Download NGINX and its dependencies
ADD https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz .
ADD https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz .
ADD https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz .
ADD https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz .

# Extract the downloaded archives
# Remove the downloaded archives to save space
RUN tar -xzf openssl-${OPENSSL_VERSION}.tar.gz && rm openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -xzf pcre2-${PCRE_VERSION}.tar.gz && rm pcre2-${PCRE_VERSION}.tar.gz \
    && tar -xzf zlib-${ZLIB_VERSION}.tar.gz && rm zlib-${ZLIB_VERSION}.tar.gz \
    && tar -xzf nginx-${NGINX_VERSION}.tar.gz && rm nginx-${NGINX_VERSION}.tar.gz

WORKDIR /tmp/nginx-${NGINX_VERSION}

# Build NGINX
# Configure NGINX with the necessary modules and libraries
ARG nginx_path

RUN ./configure \
    --prefix=${nginx_path} \
    --with-pcre-jit \
    --with-http_v3_module \
    --with-openssl=../openssl-${OPENSSL_VERSION} \
    --with-pcre=../pcre2-${PCRE_VERSION} \
    --with-zlib=../zlib-${ZLIB_VERSION} \
    && make && make install \
    && rm -rf /tmp/*

# --------------------------------------
# Final stage to create the NGINX image
# --------------------------------------

FROM ${os}:${tag}

# Set the path where NGINX will be installed
ARG nginx_path

COPY --from=builder ${nginx_path} ${nginx_path}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV NGINX_PATH=${nginx_path}

# Expose the necessary ports
EXPOSE 80 443

# start NGINX
ENTRYPOINT ["/entrypoint.sh"]
