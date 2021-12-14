
#############
# usage:
#	generate_private_key <name>
#	
#############
function gen_private_key() {
	local name=$1
	
	if [ -z "$name" ]; then
		echo "Usage: gen_private_key <name>"
		return
	fi
	openssl genrsa -out $name
}

###############
# usage:
#	generate_ca_cert <name>
#	
###############

function generate_ca_cert() {
	local cert_name=$1
	local key_name="ca.key"
	
	if [ -z "$cert_name" ]; then
		echo "Usage: generate_ca_cert <certificate_name>"
		return
	fi
	generate_private_key $key_name
	openssl req -new -x509 -days 365 -key $key_name -sha256 -out $cert_name
}

##############
# usage: 
#	issue_request <private_key> <csr_file_name>
#
#
###############
function gen_sign_request() {
	local key=$1
	local name=$2
	
	if [ -z "$key" ] || [ -z "$name" ]; then
		echo "Usage: sign_request <key> <name>"
		return
	fi
	
	openssl req -new -sha256  -key $key -out $name
}

############
# usage:
#	sign_request <request.csr> <ca.cert> <ca.key> <certfile> <extensions_file>
#
#############

function sign_request() {
	request=$1
	ca=$2
	ca_key=$3
	name=$4
	ext_file=$5
	
	if [[ -n $ext_file ]]; then
		echo "--- Extension file specified ---"
		echo ${#ext_file}
		echo $ext_file
		openssl x509 -req -days 365 -sha256 -in $request -CA $ca -CAkey $ca_key \
		-CAcreateserial -out $name -extfile $ext_file
	else
		openssl x509 -req -days 365 -sha256 -in $request -CA $ca -CAkey $ca_key \
		-CAcreateserial -out $name
	fi
}

function gen_server_certificate() {
	name=$1
	ca_cert=$2
	ca_key=$3
	if [ -z "$name" ]; then
		echo "Usage: gen_server_certificate <name>"
		return
	fi
	
	if [ -z "$ca_cert" ] || [ -z "$ca_key" ]; then
		echo "no CA certificate OR key supplied, creating CA"
		ca_cert="ca.crt"
		ca_key="ca.key"
		generate_ca_cert $ca_cert
		if [ ! -e $ca_cert ]; then
			echo "FAILED to create CA certificate"
			return
		fi
	elif [ ! -e "$ca_cert" ] || [ ! -e "$ca_key" ]; then
		echo "$ca_cert OR $ca_key not found.."
		return
	fi
	
	gen_private_key server.key
	gen_sign_request server.key server.csr
	sign_request server.csr $ca_cert $ca_key $name
	
	rm *.csr
			
}

