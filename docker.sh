

#############
#
#  usage:	
#		
#	docker -g|--generate <IP_ADDRESS>
#	docker -c|--clean
# 	docker -i|--install <IP_ADDRESS> 
#
#	This script uses the functions in ssl_functions.sh
#	It creates all the infrastructure for creating a protected docker 
#	daemon running on one host, being accessed from another host.
#
#	The output of this script is:
#	Client: client.cert, client.key
#	Server: server.cert, server.key
#	CA: ca.cert, ca.key (?)
#
#	Server files needs to be sent to the server along with the ca.cert
#	Client files needs to be sent to the client along with the ca.cert
#
#################


#!/bin/bash

. ssl_functions.sh

CA_CERT_FILE=ca.cert
CA_KEY_FILE=ca.key

SERVER_CERT_FILE=server.cert
SERVER_CSR_FILE=server.csr
SERVER_KEY_FILE=server.key

CLIENT_CERT_FILE=client.cert
CLIENT_CSR_FILE=client.csr
CLIENT_KEY_FILE=client.key

EXT_FILE=extfile.conf

function generate_ca() {
	echo "--- Generate CA ----"
	generate_private_key $CA_KEY_FILE
	generate_ca_cert $CA_KEY_FILE $CA_CERT_FILE	
}

function generate_server_cert() {
	local IP=$1
	echo "--- Generate Server Certificate --- "
	generate_private_key $SERVER_KEY_FILE
	echo "subjectAltName=IP:${IP}" >> $EXT_FILE
	issue_request $SERVER_KEY_FILE $SERVER_CSR_FILE
	sign_request $SERVER_CSR_FILE $CA_CERT_FILE $CA_KEY_FILE $SERVER_CERT_FILE $EXT_FILE
}

function generate_client_cert() {
	echo " --- Generate Client Certificate --- "
	generate_private_key $CLIENT_KEY_FILE
	issue_request $CLIENT_KEY_FILE $CLIENT_CSR_FILE
	sign_request $CLIENT_CSR_FILE $CA_CERT_FILE $CA_KEY_FILE $CLIENT_CERT_FILE
}


function clean_all() {
	rm $SERVER_CERT_FILE $SERVER_CSR_FILE $SERVER_KEY_FILE $CLIENT_CERT_FILE $CLIENT_CSR_FILE $CLIENT_KEY_FILE $CA_KEY_FILE $CA_CERT_FILE $EXT_FILE
	
}

function generate_files() {
	local IP=$1
	generate_ca
	generate_server_cert $IP
	generate_client_cert

}

function install_on_server() {
	local user_ip=$1
	local path=$2
	scp $SERVER_CERT_FILE $SERVER_KEY_FILE $CA_CERT_FILE $user_ip:$path
}

while [ -n "$1" ]; do
	case "$1" in
	
	-c|--clean) 
	clean_all
	shift
	;;
	
	-g|--generate) 
	if [ -z "$2" ]; then
		echo "Usage: docker.sh -g <IP>"
		exit
	fi
	generate_files $2
	
	shift
	shift
	;;
	
	-i|--install)
	if [ -z "$2" -o -z "$3" ]; then
		echo "Usage: docker.sh -i <USER>@<IP> <PATH>"
		exit
	fi
	
	install_on_server $2 $3
	shift
	shift
	shift
	;;
	*)
	shift
	;;
	
	esac

done



