#!/bin/sh

# NGINX
NGINX_VERSION=1.28.0

# LIBS
ZLIB_VERSION=1.3.1
PCRE_VERSION=10.45
OPENSSL_VERSION=3.5.0

ROOT_PATH=$(pwd)
LIBS_PATH=${ROOT_PATH}/libs
BUILD_PATH=${ROOT_PATH}/src

loadZLIB() {
local _NAME=zlib-${ZLIB_VERSION}
local _TAR_FILENAME=${_NAME}.tar.gz
local _BASE_URL=https://zlib.net
local _SOURCE_URL=${_BASE_URL}/${_TAR_FILENAME}

local _LIB_PATH=$(pwd)/lib

if [ -n "$LIBS_PATH" ]; then
	_LIB_PATH=$LIBS_PATH 
fi

local _SOURCE_PATH=${_LIB_PATH}/${_NAME}

curl -OL ${_SOURCE_URL} && \
mkdir -p $_LIB_PATH && \
tar -xf ${_TAR_FILENAME} -C ${_LIB_PATH} && \
rm ${_TAR_FILENAME}

ZLIB_SOURCE_PATH=$_SOURCE_PATH
}

loadPCRE() {
local _NAME=pcre2-${PCRE_VERSION}
local _TAR_FILENAME=${_NAME}.tar.gz
local _BASE_URL=https://github.com/PCRE2Project/pcre2/releases/download
local _SOURCE_URL=${_BASE_URL}/${_NAME}/${_TAR_FILENAME}

local _LIB_PATH=$(pwd)/lib

if [ -n "$LIBS_PATH" ]; then
	_LIB_PATH=$LIBS_PATH 
fi

local _SOURCE_PATH=${_LIB_PATH}/${_NAME}

curl -OL ${_SOURCE_URL} && \
mkdir -p $_LIB_PATH && \
tar -xf ${_TAR_FILENAME} -C ${_LIB_PATH} && \
rm ${_TAR_FILENAME}

PCRE_SOURCE_PATH=${_SOURCE_PATH}
}

loadOpenSSL() {
local _NAME=openssl-${OPENSSL_VERSION}
local _TAR_FILENAME=${_NAME}.tar.gz
local _BASE_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}"
local _SOURCE_URL=${_BASE_URL}/${_TAR_FILENAME}

local _LIB_PATH=$(pwd)/lib

if [ -n "$LIBS_PATH" ]; then
	_LIB_PATH=$LIBS_PATH 
fi

local _SOURCE_PATH=${_LIB_PATH}/${_NAME}

curl -OL ${_SOURCE_URL} && \
mkdir -p $_LIB_PATH && \
tar -xf ${_TAR_FILENAME} -C ${_LIB_PATH} && \
rm ${_TAR_FILENAME}

OPENSSL_SOURCE_PATH=$_SOURCE_PATH
}
 
loadNGINX() {
local _NAME=nginx-${NGINX_VERSION}
local _TAR_FILENAME=${_NAME}.tar.gz
local _BASE_URL=https://github.com/nginx/nginx/releases/download/release-${NGINX_VERSION}
local _SOURCE_URL=${_BASE_URL}/${_TAR_FILENAME}

local _BUILD_PATH=$(pwd)/nginx

if [ -n "$BUILD_PATH" ]; then
	_BUILD_PATH=$BUILD_PATH 
fi

curl -OL ${_SOURCE_URL} && \
mkdir -p $_BUILD_PATH  && \
tar -xf ${_TAR_FILENAME} -C ${_BUILD_PATH}  && \
rm ${_TAR_FILENAME}

NGINX_SOURCE_FOLDER=${_BUILD_PATH}/${_NAME}
}

loadNGINX && loadPCRE && loadZLIB && loadOpenSSL

cd ${NGINX_SOURCE_FOLDER}

# --with-debug --sbin-path=/usr/local/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log

./configure $@ \
 --with-pcre-jit \
 --with-http_v3_module \
 --with-openssl="${OPENSSL_SOURCE_PATH}" \
 --with-pcre="${PCRE_SOURCE_PATH}" \
 --with-zlib="${ZLIB_SOURCE_PATH}"

make