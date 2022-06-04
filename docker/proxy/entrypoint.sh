#!/bin/bash

#set -xv 
set -a

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Create a self-signed default certificate, so Ngix can start on a secure port, then running secure locally in staging, or in production as a bootstrap stage necessary for Let's Encrypt to engage in obtaining signing authority certificates.

# Manage obtaining and renewing Let's Encrypt certificates when run with a FQDN in production.

# Original created by André Ilhicas dos Santos 'Ilhicas', blog@ilhicas.com
# https://ilhicas.com/2019/03/02/Nginx-Letsencrypt-Docker.html

# Also:

# https://stackoverflow.com/questions/56649582/substitute-environment-variables-in-nginx-config-from-docker-compose
# https://codefather.tech/blog/bash-error-bad-substitution/

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function dhparam_gen_warn() {
  # warning every container launch -- server key certificate generation
  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
  echo "WARNING: docker root folder, dhparam_gen.sh, re. production site server key"
  echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
}

echo ${AS_FQDN}.conf.conf

mv /etc/nginx/templates/appsnappr.conf /etc/nginx/templates/${AS_FQDN}.conf.conf
rm -f /etc/nginx/conf.d/default.conf

template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"
# output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/conf.d}"
output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/sites-available}"
output_conf=/etc/nginx/conf.d

echo "template_dir=$template_dir"
echo "output_dir=$output_dir"
echo "suffix=$suffix"

template=${template_dir}/${AS_FQDN}${suffix}${suffix}
echo "template=$template"

echo "$template"

# input_vars=$(printf '${%s} ' $(env | cut -d= -f1))
input_vars=$(printf '${%s} ' ${!AS_*})
echo "$input_vars"
envsubst "${input_vars}" < ${template} > ${output_conf}/default.conf
# envsubst $input_vars < $template > $output_conf/default.conf

# ln -s /mnt/usr/lib/* /usr/lib/
# ( mkdir -p /etc/nginx/sites-enabled; cd /etc/nginx; ln -s -T /etc/nginx/sites-available/"${FQDN:-example.com}" /etc/nginx/sites-enabled/"${FQDN:-example.com}" )

#set +xv

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dhparam_gen_warn

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

function cert() {

  if [[ ! -d /var/www/certbot ]]; then
    mkdir -p /var/www/certbot
  fi

  certbot certonly \
    --config-dir "${LETSENCRYPT_DIR:-/etc/letsencrypt}" \
    --agree-tos \
    --domains "$AS_FQDN" \
    --email "$AS_ADMINEMAIL" \
    --expand \
    --noninteractive \
    --webroot \
    --webroot-path /var/www/certbot \
    $OPTIONS || true

  if [[ -f "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$FQDN/privkey.pem" ]]; then
    cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$FQDN/privkey.pem" /usr/share/nginx/certificates/privkey.pem
    cp "${LETSENCRYPT_DIR:-/etc/letsencrypt}/live/$FQDN/fullchain.pem" /usr/share/nginx/certificates/fullchain.pem
  fi

}

# $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

#Ensure we have folders available
if [[ ! -d /usr/share/nginx/certificates ]]; then
  mkdir -p /usr/share/nginx/certificates
fi

if [[ ! -d /etc/letsencrypt ]]; then
  mkdir -p /etc/letsencrypt
fi

if [[ ! -f /usr/share/nginx/certificates/fullchain.pem ]]; then
  mkdir -p /usr/share/nginx/certificates
fi

if [[ ! -f /usr/share/nginx/certificates/cert.crt ]]; then
  openssl genrsa -out /usr/share/nginx/certificates/privkey.pem 4096
  openssl req -new -key /usr/share/nginx/certificates/privkey.pem -out /usr/share/nginx/certificates/cert.csr -nodes -subj \
    "/C=PT/ST=World/L=World/O=${AS_FQDN:-example.com}/OU=${AS_HOSTNAME:-example}/CN=${AS_FQDN:-example.com}/EMAIL=${AS_ADMINEMAIL:-info@example.com}"
  openssl x509 -req -days 365 -in /usr/share/nginx/certificates/cert.csr -signkey /usr/share/nginx/certificates/privkey.pem -out /usr/share/nginx/certificates/fullchain.pem
fi

if [ $STAGE = "prod" ]; then
  echo -n "ACME certificate issuance or renewal underway -- project in production"

  ### Send certbot Emission/Renewal to background
  # $(while :; do /opt/certbot.sh; sleep "${RENEW_INTERVAL:-12h}"; done) &
  $(while :; do
    cert
    sleep "${RENEW_INTERVAL:-12h}"
  done) &

  ### Check for changes in the certificate (i.e renewals or first start)
  $(while inotifywait -e close_write /usr/share/nginx/certificates; do nginx -s reload; done) &
else
  echo "self-signed certificates -- project in ${STAGE}"
fi

#case "$STAGE" in
#
#  "dev")
#    echo -n "self-signed certificates -- project in development"
#    ;;
#
#  "prod")
#    echo -n "production ACME certificate issuance or renewal underway"
#
#    ### Send certbot Emission/Renewal to background
#    # $(while :; do /opt/certbot.sh; sleep "${RENEW_INTERVAL:-12h}"; done) &
#    $(while :; do cert; sleep "${RENEW_INTERVAL:-12h}"; done) &
#
#    ### Check for changes in the certificate (i.e renewals or first start)
#    $(while inotifywait -e close_write /usr/share/nginx/certificates; do nginx -s reload; done) &
#    ;;
#
#  "cicd")
#    echo -n "self-signed certificates -- continuous integretion"
#    ;;
#
#esac

dhparam_gen_warn
#nginx-debug -g "daemon off;"
nginx -g "daemon off;"
