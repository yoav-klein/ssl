

function generate_private_key() {
	local name=$1
	openssl genrsa -out $name 4096
}

function generate_ca_cert() {
	local key_name=$1
	local cert_name=$2
	openssl req -new -x509 -days 365 -key $key_name -sha256 -out $cert_name
}

function issue_request() {
	
	local key=$1
	local name=$2
	local host=$3
	
	if [ -z $1 -o -z $2 -o -z $3 ]; then
		echo "sign_request <key> <name> <host>"
		return
	fi
	
	openssl req -subj "/CN=${host}" -sha256 -new -key $key -out $name
}

function sign_request() {
	request=$1
	ca=$2
	ca_key=$3
	name=$4
	ext_file=$5
	
	openssl x509 -req -days 365 -sha256 -in $request -CA $ca -CAkey $ca_key \
	-CAcreateserial -out $name -extfile $ext_file
}
