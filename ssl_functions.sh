
#########################
#
#	gen_private_key
#
#	Generates a private key
#
#######################
function gen_private_key() {
	local name=$1
	
	if [ -z "$name" ]; then
		echo "Usage: gen_private_key <name>"
		return
	fi
	openssl genrsa -out $name
}

###############
# 
#	gen_ca_cert
#
#	Generates a CA certificate	
#
###############

function gen_ca_cert() {
	local cert_name="ca.crt"
	local key_name="ca.key"
	
	gen_private_key $key_name
	openssl req -new -x509 -days 365 -key $key_name -sha256 -out $cert_name
}

##############
# 
#	gen_sign_request()
#
#	Creates a Certificate Signing Request
#
###############

function gen_sign_request() {
	local key=$1
	local name=$2
	
	if [ -z "$key" ] || [ -z "$name" ]; then
		echo "Usage: sign_request <key> <name>"
		return
	fi
	
	openssl req -new -sha256 -key $key -out $name
}

############
#
#	sign_request
#
#	Signs a CSR 
#	
#	Usage: 
#	$ sign_request <csr> <ca.cert> <ca.key> <certificate_name> [extensions_file]
#
#############

function sign_request() {
	csr=$1
	ca=$2
	ca_key=$3
	name=$4
	ext_file=$5
	
	if [ ! -e "$ca" ] || [ ! -e "$ca_key" ] || [ ! -e "$csr" ] || [ -z "$name" ]; then
		echo "Usage: sign_request <csr> <ca_certificate> <ca_key> <certificate_name> [extension_file]"
		return
	fi
	
	if [ -n "$ext_file" ]; then
		echo "--- Extension file specified ---"
		if [ ! -e $ext_file ]; then
			echo "extension file wasn't found !"
			return
		fi
		
		openssl x509 -req -days 365 -sha256 -in $csr -CA $ca -CAkey $ca_key \
		-CAcreateserial -out $name -extfile $ext_file
	else
		openssl x509 -req -days 365 -sha256 -in $csr -CA $ca -CAkey $ca_key \
		-CAcreateserial -out $name
	fi
}

#############
#
#	gen_server_certificate
#
#	Does the whole process needed to generate a server certificate.
#	including: generating a CA certificate, CSR and signing the CSR.
#
#	Usage: 
#	$ gen_server_certificate <name> [<ca_cert> <ca_key>]
#
#############

function gen_server_certificate() {
	name=$1
	ca_cert=$2
	ca_key=$3
	
	if [ -z "$name" ]; then
		echo "Usage: gen_server_certificate <name> [<ca_cert> <ca_key>]"
		return
	fi
	
	if [ -z "$ca_cert" ] || [ -z "$ca_key" ]; then
		echo "no CA certificate OR key supplied, creating CA"
		ca_cert="ca.crt"
		ca_key="ca.key"
		gen_ca_cert $ca_cert
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

