#!/usr/bin/env bash

# Setup site
cat <<EOF | tee /etc/nginx/conf.d/default.conf
server {

    listen 443;
    server_name ${SERVER_NAME};
    client_max_body_size 1000M;

    chunked_transfer_encoding on;

    ssl on;
    ssl_certificate           ${CRT_PATH};
    ssl_certificate_key       ${KEY_PATH};

    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    access_log            /var/log/nginx/${SERVER_NAME}.access.log;

    location / {

      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.
      proxy_pass          ${PROXY_PASS};
      proxy_read_timeout  90;

      proxy_redirect      ${PROXY_PASS} https://${SERVER_NAME};
    }
  }
EOF

# Start nginx
echo "Starting secure nginx server..."
nginx -g "daemon off;"