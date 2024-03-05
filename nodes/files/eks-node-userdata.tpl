#!/bin/bash -xe

sudo /etc/eks/bootstrap.sh --apiserver-endpoint '${apiserver-endpoint}' --b64-cluster-ca '${b64-cluster-ca}' '${eks-cluster-name}'