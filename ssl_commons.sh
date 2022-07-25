

##### Log functions ####
ssl_log_success() {
    [ -n "$1" ] && [ -n "$2" ] && echo -e "\e[32;1m=== ssl_commons::$1: $2 \e[0m"
}


ssl_log_error() {
    [ -n "$1" ] && [ -n "$2" ] &&  echo -e "\e[31;1m=== ssl_commons::$1: $2 \e[0m"
}

ssl_log() {
    [ -n "$1" ] && [ -n "$2" ] && echo "---> ssl_commons::$1: $2"
}


#########################
#
#    gen_private_key
#
#    Generates a private key
#
#######################
function gen_private_key() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo "Usage: gen_private_key <name>"
        return
    fi
    openssl genrsa -out $name > /dev/null || ssl_log_error "gen_private_key" "Failed to generate $name" &&  return 1
    ssl_log_success "Generated private key $name"
}

###############
# 
#    gen_ca_cert
#
#    Generates a CA certificate	
#
#   USAGE: 
#       gen_ca_cert [path] [config_file]
#   
#   RETURNS
#       0 on success
#       1 on failure
#
###############

function gen_ca_cert() {  
    local path=$1
    if [ -z "$path" ]; then
        path="."
    fi
    
    local cert_path="$path/ca.crt"
    local key_path="$path/ca.key"
    local config=$2
    gen_private_key $key_path
    if [ -z "$config" ]; then
        ssl_log "gen_ca_cert" "No config file"
        openssl req -new -x509 -days 365 -key $key_path -sha256 -out $cert_path
    else
        ssl_log "gen_ca_cert" "generating with config file"
        openssl req -new -x509 -days 365 -key $key_path -config $config -out $cert_path
    fi
    if [ $? = 0 ]; then
        ssl_log_success "gen_ca_cert" "SUCCESSFULLY generated CA certificate"
        return 0
    else
        ssl_log_error "gen_ca_cert" "Failed generating CA certificate"
        return 1
    fi
}


##############
# 
#    gen_sign_request()
#
#    Creates a Certificate Signing Request
#
#   USAGE: 
#       gen_sign_request <key> <name> [config_file]
#
#   RETURNS
#       0 on success
#       1 on error
#
###############

function gen_sign_request() {
    local key=$1
    local name=$2
    local config=$3
    if [ -z "$key" ] || [ -z "$name" ]; then
    	ssl_log_error "gen_sign_request" "Usage: sign_request <key> <name> [config_file]"
    	return 1
    fi
    
    if [ -n "$config" ]; then
        ssl_log "gen_sign_request" "with config file"
        openssl req -new -key $key -out $name -config $config
    else
        ssl_log "gen_sign_request" "no config file"
        openssl req -new -sha256 -key $key -out $name
    fi
    if [ $? = 0 ]; then
        ssl_log_success "gen_sign_request" "SUCCESSFULLY generated CSR $name"
        return 0
    else
        ssl_log_error "gen_sign_request ""FAILED generating CSR $name"
        return 1
    fi
}

############
#
#    sign_request
#
#    Signs a CSR 
#    
#    USAGE: 
#    $ sign_request <csr> <ca.cert> <ca.key> <certificate_name> [extensions_file]
#
#   RETURNS
#       0 on success
#       1 on error
#
#############

function sign_request() {
    local csr=$1
    local ca=$2
    local ca_key=$3
    local name=$4
    local ext_file=$5
    local extensions=$6
    
    [ -f "$ca" ] || { ssl_log_error "sign_request" "$ca not found" && return 1; }
    [ -f "$ca_key" ] || { ssl_log_error "sign_request" "$ca_key not found" && return 1; }
    [ -f "$csr" ] || { ssl_log_error "sign_request" "$csr not found" && return 1; }
    [ -n "$name" ] || { ssl_log_error "sign_request" "Usage: sign_request <csr> <ca_certificate> <ca_key> <certificate_name> [extension_file <extension_section>]" && return 1; }
    
    
    if [ -n "$ext_file" ]; then
        ssl_log "sign_request" "Extension file specified"
        if [ ! -f $ext_file ] || [ -z "$extensions"  ]; then
            ssl_log_error "sign_request" "extension file wasn't found, or extensions not given"
    	    return
        fi
    	
    	openssl x509 -req -days 365 -sha256 -in $csr -CA $ca -CAkey $ca_key \
    	-CAcreateserial -out $name -extfile $ext_file -extensions $extensions
    else
    	openssl x509 -req -days 365 -sha256 -in $csr -CA $ca -CAkey $ca_key \
    	-CAcreateserial -out $name
    fi

    if [ $? = 0 ]; then
        ssl_log_success "sign_request" "SUCCESSFULLY signed request and generated $name"
    else
        ssl_log_error "sign_request" "couldn't sign request"
        exit 1
    fi
}

#############
#
#    gen_server_certificate
#
#    Does the whole process needed to generate a server certificate.
#    including: generating a CA certificate, CSR and signing the CSR.
#
#    Usage: 
#    $ gen_server_certificate <name> [<ca_cert> <ca_key>]
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
    	gen_ca_cert # $ca_cert
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




