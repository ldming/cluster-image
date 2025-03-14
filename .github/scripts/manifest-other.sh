#!/bin/bash

set -eu

readonly ARCH=${arch:-}
readonly IMAGE_NAME=${app?}
readonly IMAGE_TAG=${version?}
readonly IMAGE_HUB_REGISTRY=${registry?}
readonly IMAGE_HUB_REPO=${repo?}
readonly IMAGE_HUB_USERNAME=${username?}
readonly IMAGE_HUB_PASSWORD=${password?}
readonly IMAGE_NAME_FULL=${IMAGE_HUB_REGISTRY}/${IMAGE_HUB_REPO}/${IMAGE_NAME}:${IMAGE_TAG}

# for host action ,Don't delete this code
sudo sealos rmi "$IMAGE_NAME_FULL" || true

sudo sealos manifest create "$IMAGE_NAME_FULL"
case $ARCH in
amd64 | arm64)
  sudo sealos manifest add "$IMAGE_NAME_FULL" docker://"$IMAGE_NAME_FULL-$ARCH"
  ;;
*)
  sudo sealos manifest add "$IMAGE_NAME_FULL" docker://"$IMAGE_NAME_FULL-amd64"
  sudo sealos manifest add "$IMAGE_NAME_FULL" docker://"$IMAGE_NAME_FULL-arm64"
  ;;
esac
sudo sealos images

sudo sealos login -u "$IMAGE_HUB_USERNAME" -p "$IMAGE_HUB_PASSWORD" "$IMAGE_HUB_REGISTRY" &&
  sudo sealos manifest push --all "$IMAGE_NAME_FULL" docker://"$IMAGE_NAME_FULL" && echo "$IMAGE_NAME_FULL push success"
sudo sealos manifest inspect $IMAGE_NAME_FULL

# for host action ,Don't delete this code
sudo sealos rmi "$IMAGE_NAME_FULL" || true
