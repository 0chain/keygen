#!/bin/bash

echo "v1.0.15"

mkdir -p /keys
echo -e "Creating keys for node \n"
go run key_gen.go --signature_scheme "bls0chain" --keys_file_name "b0node_keys.txt" --keys_file_path "/keys" --generate_keys=true
