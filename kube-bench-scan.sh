#!/bin/bash

#k8s-cluster-security-check.sh

kubectl apply -f sec-namespace.yaml

sleep 10


kubectl apply -n cissec  -f kube-bench-scan.yaml

sleep 20

podname=$(kubectl get po -n cissec | awk 'NR==2 {print $1}')

#total_fail=$(kubectl -n cissec logs $podname --json | jq .[].total_fail)

sleep 5

total_fail=$(kubectl logs --tail 6 $podname -n cissec | awk 'NR==3 {print $1}')

sleep 3

if [[ "$total_fail" -ne 0 ]];
        then
                echo "CIS Benchmark failed for k8s"
                exit 1;
        else
                echo "CIS Benchmark Passed for k8s"
fi; 

