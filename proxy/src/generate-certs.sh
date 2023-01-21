#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# License found in the LICENSE file in the root directory
# of this source tree.

echo "----------------------------"
echo "| SSL Certificate Generation |"
echo "----------------------------"
echo

export RANDOM_CA=$(head -c 60 /dev/urandom | tr -dc 'a-zA-Z0-9')
export CA_KEY="ca-key.pem"
export CA_CERT="ca.pem"
export CA_SUBJECT="${RANDOM_CA}"
export CA_EXPIRE="36500" # 100 years

export SSL_CONFIG="openssl.cnf"
export SSL_KEY="key.pem"
export SSL_CSR="key.csr"
export SSL_CERT="cert.pem"
export SSL_SIZE="4096"
export SSL_EXPIRE="3650" # 10 years

export RANDOM_SSL=$(head -c 60 /dev/urandom | tr -dc 'a-zA-Z0-9')
export SSL_SUBJECT="${RANDOM_SSL}.net"
export SSL_DNS=${SSL_DNS}
export SSL_IP=${SSL_IP}

export DEBUG=${DEBUG:=1}

echo "--> Certificate Authority"
echo "Generating certs for ${SSL_SUBJECT}"

if [[ -e ./${CA_KEY} ]]; then
    echo "====> Using existing CA Key ${CA_KEY}"
else
    echo "====> Generating new CA key ${CA_KEY}"
    openssl genrsa -out ${CA_KEY} 4096
fi

if [[ -e ./${CA_CERT} ]]; then
    echo "====> Using existing CA Certificate ${CA_CERT}"
else
    echo "====> Generating new CA Certificate ${CA_CERT}"
    openssl req -x509 -new -nodes -key ${CA_KEY} -days ${CA_EXPIRE} -out ${CA_CERT} -subj "/CN=${CA_SUBJECT}"  || exit 1
fi

[[ -n $DEBUG ]] && cat $CA_CERT

echo "====> Generating new config file ${SSL_CONFIG}"
cat > ${SSL_CONFIG} <<EOM
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOM

if [[ -n ${SSL_DNS} || -n ${SSL_IP} ]]; then
    cat >> ${SSL_CONFIG} <<EOM
subjectAltName = @alt_names
[alt_names]
EOM

    IFS=","
    dns=(${SSL_DNS})
    dns+=(${SSL_SUBJECT})
    for i in "${!dns[@]}"; do
      echo DNS.$((i+1)) = ${dns[$i]} >> ${SSL_CONFIG}
    done

    if [[ -n ${SSL_IP} ]]; then
        ip=(${SSL_IP})
        for i in "${!ip[@]}"; do
          echo IP.$((i+1)) = ${ip[$i]} >> ${SSL_CONFIG}
        done
    fi
fi

echo "====> Generating new SSL KEY ${SSL_KEY}"
openssl genrsa -out ${SSL_KEY} ${SSL_SIZE}  || exit 1

echo "====> Generating new SSL CSR ${SSL_CSR}"
openssl req -new -key ${SSL_KEY} -out ${SSL_CSR} -subj "/CN=${SSL_SUBJECT}" -config ${SSL_CONFIG}  || exit 1

echo "====> Generating new SSL CERT ${SSL_CERT}"
openssl x509 -req -in ${SSL_CSR} -CA ${CA_CERT} -CAkey ${CA_KEY} -CAcreateserial -out ${SSL_CERT} \
    -days ${SSL_EXPIRE} -extensions v3_req -extfile ${SSL_CONFIG}  || exit 1

echo "====> Generating SSL CERT / KEY COMBO proxy.whatsapp.net.pem"
cat ${SSL_KEY} > proxy.whatsapp.net.pem
cat ${SSL_CERT} >> proxy.whatsapp.net.pem

echo "Certificate generation completed."

