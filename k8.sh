#!/bin/bash

if [ "$DEBUG" = "true" ];
then
  set -x
fi

case ${1} in
  h)
    echo -e "summary of commands"
    echo -e "-------------------"
    echo -e "context <param>                - use the kube-config-{param}.yaml file"
    echo -e "info                           - list useful info"
    echo -e "kgn                            - get nodes"
    echo -e "kdn <param>                    - describe node"
    echo -e "kj                             - join node info"
    echo -e "ka <file>                      - apply file"
    echo -e "kga <param>                    - get all (namespace override)"
    echo -e "kg <param> <param>             - get resource"
    echo -e "kd <param> <param>             - describe resource"
    echo -e "klg <param> <param>            - logs for resource"
    echo -e "krm <param> <param>            - delete resource"
    echo -e "kru <param> <image> <command>  - run image with command"
    echo -e "kex <param> <command>          - execute pod with command"
    echo -e "tl  <param>                    - tekton list object"
    echo -e "td  <object> <param>           - tekton describe object"
    echo -e "tlg <object> <param>           - tekton show logs for object"
    echo -e "trm <object> <param>           - tekton delete object"
    echo -e "export PROJECT=namespace       - set current namespace (used in commands)"
    exit 0
  ;;
  context)
    cp kube-config-${2}.yaml .kube/config
    echo -e "changed to server ${2}"
    kubectl cluster-info
    exit 0
  ;;
  info)
    echo -e "version - 1.1.0 03/2021"
    echo -e "context $(cat .kube/config | grep name | head -n 1)"
    echo -e "project - $PROJECT"
    exit 0
  ;;
  kgn)
    kubectl get nodes
    exit 0
  ;;
  kdn)
    kubectl describe node ${2}
    exit 0
  ;;
  kj)
    kubeadm token create --print-join-command
    exit 0
  ;;
  ka)
    if [ "$#" -ne 2 ];
    then
      echo -e "usage -> k8 ka <file>"
      exit 0
    fi
    kubectl apply -f ${2} -n $PROJECT
    exit 0
  ;;
  kga)
      kubectl get all -n ${2}
      exit 0
  ;;
  kg)
    if [ "$PROJECT" = "" ];
    then
      kubectl get ${2} ${3}
      exit 0
    fi
    kubectl get ${2} ${3} -n $PROJECT
  exit 0
  ;;
  ks)
    kubectl get ${2} ${3} -n $PROJECT -o yaml
    exit 0
  ;;
  kd)
    kubectl describe ${2} ${3}  -n $PROJECT
    exit 0
  ;;
  klg)
    kubectl logs ${2} ${3}  -n $PROJECT
    exit 0
  ;;
  krm)
    kubectl delete ${2} ${3} -n $PROJECT
    exit 0
  ;;
  kru)
    if [ "$#" -ne 4 ];
    then
      echo -e "usage -> k8 kru <name> <image> <command>"
      exit 0
    fi
    kubectl run -i -t ${2} -n $PROJECT --image=${3} --restart=Never -- ${4}
    exit 0
  ;;
  kex)
    kubectl exec -i -t ${2} -n $PROJECT -- ${3}
    exit 0
  ;;

  tl)
    tkn ${2} list -n $PROJECT
    e:xit 0
  ;;
  td)
    tkn ${2} describe ${3} -n $PROJECT
    exit 0
  ;;
  tlg)
    tkn ${2} logs ${3} -n $PROJECT
    exit 0
  ;;
  trm)
    tkn ${2} delete ${3} -n $PROJECT
    exit 0
  ;;
esac
