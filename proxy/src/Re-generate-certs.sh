#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <hostname> <valid days>"
  exit 1
fi

# Ensure the input is valid
hostname=$1
if [[ ! $hostname =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo "Error: Invalid hostname"
  exit 1
fi

valid_days=$2
if ! [[ "$valid_days" =~ ^[0-9]+$ ]] || [[ "$valid_days" -lt 1 ]]; then
  echo "Error: Invalid number of days"
  exit 1
fi

# Use a strong encryption algorithm
key_size=4096
algorithm=ecdsa

# Generate the certificate and private key
certutil -S -x -n $hostname -s "CN=$hostname" -k $algorithm -g $key_size -d sql:. -t ",," -v $valid_days -a -z /dev/urandom

echo "Certificate generation completed."
# Encrypt the private key
echo "Please enter a passphrase to encrypt the private key with:"
read -s passphrase

certutil -K -d sql:. -f $passphrase -P "" -n $hostname

# Create a PKCS#12 file
echo "Please enter a filename for the PKCS#12 file (e.g. mycert.p12):"
read p12file

echo "Please enter a passphrase for the PKCS#12 file:"
read -s p12passphrase

pk12util -o $p12file -n $hostname -d sql:. -k $passphrase -w $p12passphrase

# Remove the unencrypted private key
certutil -D -n $hostname -d sql:.

# Change the ownership and permissions of the files
chmod 600 $p12file
chown root:root $p12file

echo "PKCS#12 file creation completed."
