#!/bin/sh

export PATH="$PATH:${NGINX_PATH}/sbin/"
nginx -g "daemon off;"