#!/bin/bash

telegram_token=$(cat .telegram_token)
telegram_chatid=$(cat .telegram_chatid)
repo="prometheus/alertmanager"
current_release=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | awk -F '"' '/tag_name/{print $4}' | sed 's/v//')
dockerfile_version=$(grep "ARG\ version=" Dockerfile | awk -F'=' '{print $NF}')

echo "Current Release: $current_release"
echo "Dockerfile Version: $dockerfile_version"
echo "---------------------------"
if [ "$dockerfile_version" != "$current_release" ]; then
  echo "$REPO ist out of date. Updating to $current_release"
  sed -i "s/$dockerfile_version/$current_release/g" Dockerfile
  git add -A
  git commit -m "update to $current_release"
  git push origin
  git tag $current_release
  git push origin $current_release
  curl -X  POST "https://api.telegram.org/bot$telegram_token/sendMessage?chat_id=$telegram_chatid&text=$repo updated to $current_release"
else
  echo "$REPO $dockerfile_version is up to date"
  exit 0
fi
