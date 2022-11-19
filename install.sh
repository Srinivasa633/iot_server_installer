#!/bin/bash

read -p "Please enter the token : " install_token

install_prereq () {
  sudo apt install -y zip unzip
  sudo apt-get install -y  jq
  pip3 install flask
  pip3 install waitress
}

setup_mqtt_server () {

  # Install MQTT server
  sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
  sudo apt-get update
  sudo apt-get install mosquitto
  sudo apt-get install mosquitto-clients

  # Configure MQTT server
  sudo mosquitto_passwd -c /etc/mosquitto/passwd mqtt

  sudo tee -a /etc/mosquitto/mosquitto.conf > /dev/null <<EOT
# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example
listener 1883
password_file /etc/mosquitto/passwd
allow_anonymous false
persistence true
persistence_location /var/lib/mosquitto/

log_dest file /var/log/mosquitto/mosquitto.log

include_dir /etc/mosquitto/conf.d
EOT

  # Restart MQTT server
  systemctl status mosquitto

}

setup_firmware_updater () {
  # Get latest release of the firmware updater code
  FIRMWARE_UPDATER_CODE_ZIP_URL=$(curl -s -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $install_token" https://api.github.com/repos/Srinivasa633/iot_server/releases/latest | jq -r '.zipball_url')
  echo "Fetching firmware updater form : $FIRMWARE_UPDATER_CODE_ZIP_URL"
  curl -sL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $install_token" $FIRMWARE_UPDATER_CODE_ZIP_URL > firmware_updater_repo.zip
  mkdir -p ./firmware_updater
  mv firmware_updater_repo.zip ./firmware_updater/
  cd firmware_updater
  unzip -jo firmware_updater_repo.zip
  rm -rf firmware_updater_repo.zip
  
  # Place firmware updater under /etc and run in background
  INSTALL_PATH=/home/ubuntu/iot_firmware_updater
  mkdir -p $INSTALL_PATH
  rm -rf $INSTALL_PATH/*
  mv * $INSTALL_PATH/
  cd $INSTALL_PATH
  source config
  python3 server.py & 
}

#install_prereq
#setup_mqtt_server
setup_firmware_updater
