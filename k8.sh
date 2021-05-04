#!/bin/bash

if [ "$DEBUG" = "true" ];
then
  set -x
fi

case ${1} in
  hlp)
    echo -e "summary of commands"
    echo -e "-------------------"
    echo -e "hlp                            - help (this list)"
    echo -e "ctx <param>                    - use the kube-config-{param}.yaml file"
    echo -e "inf                            - list useful info"
    echo -e "kgn                            - get nodes"
    echo -e "kdn <param>                    - describe node"
    echo -e "kjn                            - join node info"
    echo -e "kap <file>                     - apply file"
    echo -e "kga                            - get all (current porject namespace)"
    echo -e "kga <namespace>                - get all (namespace override)"
    echo -e "kgy <resource> <param>         - get resource with yaml"
    echo -e "kgr <resource> <param>         - get resource"
    echo -e "kdr <resource> <param>         - describe resource"
    echo -e "klg <resource> <param>         - logs for resource"
    echo -e "krm <resource> <param>         - delete resource"
    echo -e "kru <param> <image> <command>  - run image with command"
    echo -e "kex <param> <command>          - execute pod with command"
    echo -e "tlo <param>                    - tekton list object"
    echo -e "tdo <object> <param>           - tekton describe object"
    echo -e "tlg <object> <param>           - tekton show logs for object"
    echo -e "trm <object> <param>           - tekton delete object"
    echo -e "export PROJECT=namespace       - set current namespace (used in commands)"
    exit 0
  ;;
  ctx)
    cp kube-config-${2}.yaml .kube/config
    echo -e "changed to server ${2}"
    kubectl cluster-info
    exit 0
  ;;
  inf)
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
  kjn)
    kubeadm token create --print-join-command
    exit 0
  ;;
  kap)
    if [ "$#" -ne 2 ];
    then
      echo -e "usage -> k8 kap <file>"
      exit 0
    fi
    kubectl apply -f ${2} -n $PROJECT
    exit 0
  ;;
  kga)
    if [ "$#" -gt 1 ];
    then
      kubectl get all -n ${2}
      exit 0
    else
      kubectl get all -n $PROJECT
      exit 0
    fi
  ;;
  kgr)
    if [ "$PROJECT" = "" ];
    then
      kubectl get ${2} ${3}
      exit 0
    fi
    kubectl get ${2} ${3} -n $PROJECT
  exit 0
  ;;
  kgy)
    kubectl get ${2} ${3} -n $PROJECT -o yaml
    exit 0
  ;;
  kdr)
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

  tlo)
    tkn ${2} list -n $PROJECT
    e:xit 0
  ;;
  tdo)
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
