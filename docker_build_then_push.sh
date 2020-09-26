#!/bin/bash

if [ -z "$DOCKER_USER" ] || [ -z "$PASSWORD" ]; then
    echo "Please add DOCKER_USER and PASSWORD in env"
    exit 1
fi

TAG=$SEMVER
if [ "$DEV" == "true" ]; then
    HASH=$(echo $(git log -1 --pretty=%H) | awk '{print substr($0,1,8);exit}')
    TAG=$TAG-dev-$HASH
fi

echo "HOST = $HOST"
echo "ORG = $ORG"
echo "APPNAME = $APPNAME"
echo "TAG = $TAG"

echo $PASSWORD | docker login $HOST --username $DOCKER_USER --password-stdin || exit 1
time docker build -t $ORG/$APPNAME .
docker tag $ORG/$APPNAME $HOST/$ORG/$APPNAME:$TAG

if [ $DEV == false ]; then
    # Because it's not development image, then put latest
    # but don't use latest in your production
    docker tag $ORG/$APPNAME $HOST/$ORG/$APPNAME:latest
fi

# The following command will push all version in this repo
# In CI, will be only $TAG and latest
# but will be different if you run in your local machine
time docker push $HOST/$ORG/$APPNAME
