#!/bin/bash
shopt -s expand_aliases
source  ~/.bash_profile

export HERE=$PWD
export CHART_NAME=k8s-watcher-operator
export CHART_DIR=$PWD/helm/
export PAGES_DOMAIN=kxdroid.github.io

docker run --rm -it \
    -v $PWD:/go/src \
    --platform linux/amd64 \
    -v $CHART_DIR:/chart \
    -w /go/src \
    6zar/kubebuilder \
    bash -c "kustomize build config/default >  /chart/charts/$CHART_NAME/templates/deploy.yaml"


docker run -it --rm \
    -v $CHART_DIR:/chart \
    --platform linux/amd64 \
    arielev/pybump:1.9.3 \
    bump --file /chart/charts/$CHART_NAME/Chart.yaml --level minor


docker run --rm -it \
    -v $CHART_DIR:/chart \
    --platform linux/amd64 \
    -w /chart \
    6zar/kubebuilder \
    helm package charts/$CHART_NAME/

docker run --rm -it \
    -w /chart \
    --platform linux/amd64 \
    -v $CHART_DIR:/chart \
    6zar/kubebuilder \
    helm repo index --url https://$PAGES_DOMAIN/$CHART_NAME/ --merge index.yaml .