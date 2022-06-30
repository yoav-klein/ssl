
##### Log functions ####
log_success() {
    echo -e "\e[32;1m=== $1 \e[0m"
}


log_error() {
    echo -e "\e[31;1m=== $1 \e[0m"
}

log() {
    echo "---> $1"
}


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
	openssl genrsa -out $name > /dev/null 2>&1
    log_success "Generated private key $name"
}

###############
# 
#	gen_ca_cert
#
#	Generates a CA certificate	
#
#   USAGE: 
#       gen_ca_cert [config_file]
#
###############

function gen_ca_cert() {
	local cert_name="ca.crt"
	local key_name="ca.key"
	local config=$1

	gen_private_key $key_name
    if [ -z "$1" ]; then
        log "gen_ca_cert: No config file"
	    openssl req -new -x509 -days 365 -key $key_name -sha256 -out $cert_name > /dev/null 2>&1
    else
        log "gen_ca_cert: generating with config file"
        openssl req -new -x509 -days 365 -key $key_name -config $config -out $cert_name > /dev/null 2>&1
    fi
    if [ $? = 0 ]; then
        log_success "SUCCESSFULLY generated CA certificate"
    else
        log_error "Failed generating CA certificate"
    fi
}


##############
# 
#	gen_sign_request()
#
#	Creates a Certificate Signing Request
#
#   USAGE: 
#       gen_sign_request <key> <name> [config_file]
#
###############

function gen_sign_request() {
	local key=$1
	local name=$2
	local config=$3
	if [ -z "$key" ] || [ -z "$name" ]; then
		echo "Usage: sign_request <key> <name> [config_file]"
		return
	fi
	
    if [ -n "$config" ]; then
        log "gen_sign_request: with config file"
        openssl req -new -key $key -out $name -config $config
    else
        log "gen_sign_request: no config file"
        openssl req -new -sha256 -key $key -out $name
    fi
    if [ $? = 0 ]; then
        log_success "SUCCESSFULLY generated CSR $name"
    else
        log_error "FAILED generating CSR $name"
    fi
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
    local csr=$1
    local ca=$2
    local ca_key=$3
    local name=$4
    local ext_file=$5
    local extensions=$6
    
	
	if [ ! -e "$ca" ] || [ ! -e "$ca_key" ] || [ ! -e "$csr" ] || [ -z "$name" ]; then
		echo "Usage: sign_request <csr> <ca_certificate> <ca_key> <certificate_name> [extension_file]"
		return
	fi
	
	if [ -n "$ext_file" ]; then
		log "Extension file specified"
		if [ ! -f $ext_file ] || [ -z "$extensions"  ]; then
			log_error "extension file wasn't found, or extensions not given"
			return
		fi
		
		openssl x509 -req -days 365 -sha256 -in $csr -CA $ca -CAkey $ca_key \
		-CAcreateserial -out $name -extfile $ext_file -extensions $extensions
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

