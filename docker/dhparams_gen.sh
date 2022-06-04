# run from script's location in the root of the docker folder, 
# or generate server certificate separately and move
# for copying, as appropriate

#local (staging)
openssl dhparam -outform=PEM -text -out ./proxy/ssl-options/dhparams.peml 1024

# remote (production)
#openssl dhparam -outform=PEM -text -out /etc/ssl/certs/dhparam.peml 4096


##############################################################################
# # # BONUS
# #
#
# sudo apt-get install --reinstall --purge docker.io docker-compose

# echo $(docker images --format '{{.Repository}}:{{.Tag}}'| grep 'appsnappr')

# delete all images, saving only those with <none> in the tag
# docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep '')

# delete all appsnappr images
#docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'appsnappr')

# sudo apt-get install --reinstall --purge docker.io docker-compose


