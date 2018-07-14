#!/bin/bash

source vars

case "$1" in

'dxlclient')
  echo "Install Python3"
  sudo apt install -y python3
  sudo apt install python3-pip
  sudo pip3 install --upgrade pip setuptools
  if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
  if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \

  echo "Adding DXL Client Config to Config directory"
  rm -rf opendxl-client-python/
  git clone https://github.com/opendxl/opendxl-client-python.git
  cd opendxl-client-python/
  python setup.py install
  cp examples/dxlclient.config ../config
  #cd ..
  #python -m dxlclient updateconfig config ${epo} -t ${epoport} -u ${epouser} -p ${epopass}
;;

'cacert')
  echo "Building CA Cert"
  openssl genrsa -out config/ca.pem 2048
  openssl req -new -passout pass:${PEM_PASS} -x509 -days 365 -extensions v3_ca -keyout config/ca.key -out config/ca.crt -subj "/C=US/ST=Georgia/L=Atlanta/O=McAfee/OU=HQ/CN=${CA_CERT}"
;;

'clientcert')
  echo "Building DXL Client Certs"
  openssl genrsa -out config/client.key 2048
  openssl req -out config/client.csr -key config/client.key -new -subj "/C=US/ST=Georgia/L=Atlanta/O=McAfee/OU=HQ/CN=${CLIENT_CERT}" -passout pass:${PEM_PASS}
  openssl x509 -req -in config/client.csr -CA config/ca.crt -CAkey config/ca.key -CAcreateserial -out config/client.crt -days 365 -passin pass:${PEM_PASS}
;;

# Stop and Remove
'remove')
echo "Stopping and Removing Container ${NAME}"
sudo docker stop ${NAME};sudo docker rm ${NAME}
;;

# Build Container
'build')
echo "Bulding Container ${NAME}"
sudo docker build \
    --rm=true --force-rm=true \
    -t ${LOCATION} .
;;

# Run Container
#    --network=host \
'run')
echo "Run Container ${NAME}"
docker run -it -d \
    --name ${NAME} \
    --network=host \
    --restart=unless-stopped \
   ${LOCATION}
;;

# Purge All Containers
'purge-all')
echo "Purging All Containers ${NAME}"
sudo docker system prune -a
;;

# Purge Stopped Containers
'purge')
echo "Purge Stopped Containers ${NAME}"
sudo docker system prune
;;

*)
echo "Things you can do with this script:"
echo "Set container name and location in vars file"
echo "./container dxlclient - Install DXL Client"
echo "./container cacert - Build CA Certs"
echo "./container clientcert - Build Client Certs"
echo "./container init - Initialize Database"
echo "./container build - Build Container"
echo "./container remove - Remove Container"
echo "./container run - Run Container"
echo "./container purge-all - Purge all containers and images"
echo "./container purge - Purge stopped containers and images"
;;

esac