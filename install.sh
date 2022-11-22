#!/bin/bash

read -p "Please enter the token : " install_token

get_server_repo () {
  # Get latest release of the firmware updater code
  FIRMWARE_UPDATER_CODE_ZIP_URL=$(curl -s -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $install_token" https://api.github.com/repos/Srinivasa633/iot_server/releases/latest | jq -r '.zipball_url')
  echo "Fetching firmware updater form : $FIRMWARE_UPDATER_CODE_ZIP_URL"
  curl -sL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $install_token" $FIRMWARE_UPDATER_CODE_ZIP_URL > firmware_updater_repo.zip
  mkdir -p ./firmware_updater
  mv firmware_updater_repo.zip ./firmware_updater/
  cd firmware_updater
  unzip -jo firmware_updater_repo.zip
  rm -rf firmware_updater_repo.zip
  
  bash install.sh
}

get_server_repo
