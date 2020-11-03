

# usage:
#	generate_private_key <name>
#	
#
function generate_private_key() {
	local name=$1
	openssl genrsa -out $name 4096
}

# usage:
#	generate_ca_cert <keyfile> <cacertfile_name>
#	
#
function generate_ca_cert() {
	local key_name=$1
	local cert_name=$2
	openssl req -new -x509 -days 365 -key $key_name -sha256 -out $cert_name
}

# usage: 
#	issue_request <private_key> <csr_file_name>
#
#

function issue_request() {
	local key=$1
	local name=$2
	local host=$3
	
	if [ -z $1 -o -z $2 -o -z $3 ]; then
		echo "sign_request <key> <name> <host>"
		return
	fi
	
	openssl req -new -sha256  -key $key -out $name
}

# usage:
#	sign_request <request.csr> <ca.cert> <ca.key> <certfile> <extensions_file>
#
#

function sign_request() {
	request=$1
	ca=$2
	ca_key=$3
	name=$4
	ext_file=$5
	
	openssl x509 -req -days 365 -sha256 -in $request -CA $ca -CAkey $ca_key \
	-CAcreateserial -out $name -extfile $ext_file
}



