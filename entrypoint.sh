#!/bin/bash
#set -x
# MINER=3 # miner count
# SHARDER=2 # sharder count
# BLOBBER=4 # blobber count
# PUBLIC_ENDPOINT=localhost   # or ip or  domain pointing to your instance
# PUBLIC_IP=10.20.30.40  # ip of your instance
# MPORT=707
# SPORT=717
# BPORT=
# DTYPE=PUBLIC

echo "v1.0.15"

validate_port() {
  if [[ $1 -lt 10 ]]; then
    echo "0$1"
  else
    echo $1
  fi
}

key_gen_miner() {
  echo "${5}s:" >>/config/nodes.yaml
  for n in $(seq 1 $(($1 + 0))); do
    on=$n
    port=${3}${n}
    path=${5}7${n}
    n=$(validate_port $n)
    echo -e "Creating keys for $5-${n}.. \n"
    go run key_gen.go --signature_scheme "bls0chain" --keys_file_name "b0$4node${n}_keys.txt" --keys_file_path "/ms-keys" --generate_keys=true --print_private=true --print=true  >>/config/nodes.yaml
    status=$?
    local n2n_ip="$5-${n}"
    [[ $DTYPE == "PUBLIC" ]] && n2n_ip=$2
    if [[ "$status" -eq "0" ]]; then
      cat <<EOF >>/ms-keys/b0$4node${n}_keys.txt
${PUBLIC_ENDPOINT}
$PUBLIC_IP
${3}${n}
${5}${n}
description for ${5}${n}
EOF
      cat <<EOF >>/config/nodes.yaml
  n2n_ip: ${n2n_ip}
  public_ip: $2
  port: ${3}${n}
  path: ${5}${n}
  description: localhost.$4${n}
  set_index: $((${on} - 1))
EOF
    else
      echo "Key generation failed"
      exit $retValue
    fi

  done
}

key_gen() {
  echo "${5}s:" >>/config/nodes.yaml
  for n in $(seq 1 $(($1 + 0))); do
    n=$(validate_port $n)
    echo -e "Creating keys for $5-${n}.. \n"
    go run key_gen.go --signature_scheme "bls0chain" --keys_file_name "b0$4node${n}_keys.txt" --keys_file_path "/ms-keys" --generate_keys true --print=true >>/config/nodes.yaml
    status=$?
    local n2n_ip="$5-${n}"
    [[ $DTYPE == "PUBLIC" ]] && n2n_ip=$2
    if [[ "$status" -eq "0" ]]; then
      cat <<EOF >>/ms-keys/b0$4node${n}_keys.txt
${PUBLIC_ENDPOINT}
$PUBLIC_IP
${3}${n}
${5}${n}
description for ${5}${n}
EOF
      cat <<EOF >>/config/nodes.yaml
  n2n_ip: ${n2n_ip}
  public_ip: $2
  port: ${3}${n}
  path: ${5}${n}
  description: localhost.$4${n}
EOF
    else
      echo "Key generation failed"
      exit $retValue
    fi

  done
}
mkdir -p /ms-keys
mkdir -p /config
mkdir -p /blob-keys

key_gen_blobber() {
  echo "${5}s:" >>/config/nodes.yaml
  for n in $(seq 1 $(($1 + 0))); do
    n=$(validate_port $n)
    port=${3}${n}
    path=${5}${n}
    echo -e "Creating keys for $5-${n}.. \n"
    go run key_gen.go --signature_scheme "bls0chain" --keys_file_name "b0bnode${n}_keys.txt" --keys_file_path "/blob-keys" --generate_keys true
    status=$?
    local n2n_ip="$5-${n}"
    [[ $DTYPE == "PUBLIC" ]] && n2n_ip=$2
    if [[ "$status" -eq "0" ]]; then
      cat <<EOF >>/blob-keys/b0bnode${n}_keys.txt
${PUBLIC_ENDPOINT}
$PUBLIC_IP
${3}${n}
${5}${n}
description for ${5}${n}
EOF
      cat <<EOF >>/config/nodes.yaml
  n2n_ip: ${n2n_ip}
  public_ip: $2
  port: ${3}${n}
  path: ${5}${n}
  description: localhost.$4${n}
EOF
    else
      echo "Key generation failed"
      exit $retValue
    fi

  done
}
if [[ "$MINER" -ne "0" ]]; then
  echo -e "Creating keys for miners \n"
  key_gen_miner $MINER $PUBLIC_ENDPOINT $MPORT m miner 
fi

if [[ "$SHARDER" -ne "0" ]]; then
  echo -e "Creating keys for sharders \n"
  key_gen $SHARDER $PUBLIC_ENDPOINT $SPORT s sharder
fi
if [[ "$BLOBBER" -ne "0" ]]; then
  echo -e "Creating keys for Blobbers.. \n"
  key_gen_blobber $BLOBBER $PUBLIC_ENDPOINT $BPORT b blobber
fi
cat <<EOF >>/config/nodes.yaml

message: "Straight from development"
magic_block_number: 1
starting_round: 0
t_percent: 67
k_percent: 75
EOF
#exec $@
