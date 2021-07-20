helm install test ./
cluster=default
kubeconfig="/root/.kube/config"
kubectl get pods
sleep 50
kubectl get pods
kubectl get jobs

genkey_pod_name=$(kubectl get pods --no-headers=true --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep gen-keys)

for n in $(seq 3); do
    n="0$n"
    kubectl cp $cluster/$genkey_pod_name:/ms-keys/b0mnode${n}_keys.txt k8s-yamls/b0mnode${n}_keys.txt --kubeconfig ${kubeconfig}
done

for n in $(seq 2); do
    n="0${n}"
    kubectl cp $cluster/$genkey_pod_name:/ms-keys/b0snode${n}_keys.txt k8s-yamls/b0snode${n}_keys.txt --kubeconfig ${kubeconfig}
done

for n in $(seq 6); do
    n="0${n}"
    kubectl cp $cluster/$genkey_pod_name:/blob-keys/b0bnode${n}_keys.txt k8s-yamls/b0bnode${n}_keys.txt --kubeconfig ${kubeconfig}
done

kubectl cp $cluster/$genkey_pod_name:/config/nodes.yaml k8s-yamls/nodes.yaml
kubectl cp $cluster/$genkey_pod_name:/zbox-keys/0box_keys_bls.txt k8s-yamls/0box_keys_bls.txt
kubectl cp $cluster/$genkey_pod_name:/worker-keys/blockworker_keys.txt k8s-yamls/blockworker_keys.txt

cat <<EOF >>k8s-yamls/nodes.yaml
magic_block_filename: "magicBlock"
EOF

kubectl create configmap nodes  --namespace ${cluster} --from-file=k8s-yamls/nodes.yaml --kubeconfig ${kubeconfig}
kubectl create configmap zbox-keys  --namespace ${cluster} --from-file=k8s-yamls/0box_keys_bls.txt --kubeconfig ${kubeconfig}
kubectl create configmap block-keys  --namespace ${cluster} --from-file=k8s-yamls/blockworker_keys.txt --kubeconfig ${kubeconfig}

for n in $(seq 2); do
    n="0${n}"
    kubectl create configmap b0snode${n}-keys  --namespace ${cluster} --from-file=k8s-yamls/b0snode${n}_keys.txt --kubeconfig ${kubeconfig}
done

for n in $(seq 3); do
    n="0${n}"
    kubectl create configmap b0mnode${n}-keys  --namespace ${cluster} --from-file=k8s-yamls/b0mnode${n}_keys.txt --kubeconfig ${kubeconfig}
done
for n in $(seq 6); do
    n="0${n}"
    kubectl create configmap b0bnode${n}-keys  --namespace ${cluster} --from-file=k8s-yamls/b0bnode${n}_keys.txt --kubeconfig ${kubeconfig}
done

# kubectl wait --for=condition=complete jobs/gen-keys -n ${cluster} --timeout=300s --kubeconfig $kubeconfig
kubectl create -f magic-block.yaml --kubeconfig $kubeconfig --namespace $cluster
sleep 20
magicblock_pod_name=$(kubectl get pods -n ${cluster} --kubeconfig ${kubeconfig} --no-headers=true --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep magic-block)

kubectl cp $cluster/$magicblock_pod_name:/config/magicBlock.json k8s-yamls/magicBlock.json --kubeconfig ${kubeconfig}

for n in $(seq 3); do
    c="0${n}"
    kubectl cp $cluster/$magicblock_pod_name:/config/b0mnode${n}_dkg.json k8s-yamls/b0mnode${c}_dkg.json --kubeconfig ${kubeconfig}
done

for n in $(seq 3); do
    n="0${n}"
    kubectl create configmap b0mnode${n}-dkg --namespace ${cluster} --from-file=k8s-yamls/b0mnode${n}_dkg.json --kubeconfig ${kubeconfig}
done

kubectl create configmap magicblock  --namespace ${cluster} --from-file=k8s-yamls/magicBlock.json --kubeconfig ${kubeconfig}
# kubectl wait --for=condition=complete jobs/magic-block -n ${cluster} --timeout=300s --kubeconfig $kubeconfig
echo "initialStates:" >>k8s-yamls/initial-state.yaml

ids=$(grep -oP '(?<="id": ")[^"]*' k8s-yamls/magicBlock.json | sort -t: -u -k1,1);
for id in $ids; do
    cat <<EOF >>k8s-yamls/initial-state.yaml
    - id: $id
    tokens: 10000000000
EOF
done

cat <<EOF >>k8s-yamls/initial-state.yaml
- id: 6dba10422e368813802877a85039d3985d96760ed844092319743fb3a76712d3
  tokens: 20000000000000000
EOF
kubectl create configmap initial-state  --namespace ${cluster} --from-file=k8s-yamls/initial-state.yaml --kubeconfig ${kubeconfig}
blobber_delegate_ID=$(./blobber_keygen --keys_file "./k8s-yamls/${cluster}_blob_keys.json")

#     popd
#     blobber_delegate_ID=${blobber_delegate_ID} block_worker_url=${block_worker_url} read_price=${read_price} write_price=${write_price} capacity=${capacity} envsubst <Blobbers_tmplt/$config_dir/configmap-blobber-config.template >Blobbers_tmplt/$config_dir/configmap-blobber-config.yaml
#   else
#     configure_standalone_dp
#   fi

kubectl create configmap n2n-delay-yaml --namespace default --from-file=./k8s-yamls/n2n_delay.yaml