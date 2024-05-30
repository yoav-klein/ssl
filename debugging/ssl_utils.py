"""
A utility script that can help you:

- Print list of all certificates in a directory
- Find all certificates for a specific CN in a directory
- Find all certificates for a specific CN in a certificate bundle (useful for searching in /etc/ssl/certs/ca-certificates.crt)

"""


import argparse
import os

from cryptography import x509
from cryptography.hazmat.backends import default_backend

def read_bundle(cert_file):
    with open(cert_file, 'rb') as f:
        cert_data = f.read()
    
    cert = x509.load_pem_x509_certificates(cert_data)
    return cert

def read_certificate(cert_file):
    with open(cert_file, 'rb') as f:
        cert_data = f.read()

    cert = x509.load_pem_x509_certificate(cert_data, default_backend())
    return cert

def extract_cn_from_dn(dn):
    for rdn in dn:
        print(rdn.rfc4514_attribute_name)
        print(rdn.value)
    return None

def extract_certificate_data(cert):
    subject = cert.subject
    issuer = cert.issuer
    serial_number = cert.serial_number
    not_valid_before = cert.not_valid_before
    not_valid_after = cert.not_valid_after

    return {
        "subject": subject,
        "issuer": issuer,
        "serial_number": serial_number,
        "not_valid_before": not_valid_before,
        "not_valid_after": not_valid_after
    }


def list_certificates_in_dir(directory):
    cert_list = []
    files = os.listdir(directory)
    for file in files:
        if file.endswith(".crt"):
            cert = read_certificate(directory + "/" + file)
            cert_data = extract_certificate_data(cert)
            cert_list.append((file, cert_data))

    return cert_list


def display_cert(cert):
    def extract_cn(field):
        for rdn in field:
            if rdn.rfc4514_attribute_name == "CN":
                return rdn.value

    print(f"Subject CN: {extract_cn(cert['subject'])}")
    print(f"ISsuer CN: {extract_cn(cert['issuer'])}")
    print(f"Not before: {cert['not_valid_before']}")
    print(f"Not after: {cert['not_valid_after']}")


def find_cert_by_cn(cn: str, path: str):
    count = 0
    cert_list = list_certificates_in_dir(path)
    for cert in cert_list:
        subject = cert[1]['subject']
        for rdn in subject:
            if rdn.rfc4514_attribute_name == "CN":
                if rdn.value == cn:
                    count+=1
                    display_cert(cert[1])
                    print(f"file: {cert[0]}")

    print(f"Found: {count}")


def find_cert_in_bundle(cn: str, path: str):
    count = 0
    cert_list = read_bundle(path)
    for cert_data in cert_list:
        cert = extract_certificate_data(cert_data)
        subject = cert['subject']
        for rdn in subject:
            if rdn.rfc4514_attribute_name == "CN":
                if rdn.value == cn:
                    count += 1
                    display_cert(cert)

    print(f"Found: {count}")        


def display_list(path: str):
    cert_list = list_certificates_in_dir(path)
    for cert in cert_list:
        print("=====")
        display_cert(cert[1])


def parse_arguments():
    parser = argparse.ArgumentParser(description="SSL Diagnostics Tool")
    subparsers = parser.add_subparsers(dest="command", required=True, help="Choose a command")

    list_parser = subparsers.add_parser("list-certs", help="List certificates in directory")
    list_parser.add_argument("--path", type=str, help="Path to directory", required=True)

    find_cert_parser = subparsers.add_parser("find-cert", help="Find certificate in directory")
    find_cert_parser.add_argument("--cn", type=str, help="CN to find", required=True)
    find_cert_parser.add_argument("--path", type=str, help="Path to directory", required=True)

    find_cert_parser1 = subparsers.add_parser("find-cert-in-bundle", help="Find certificate in directory")
    find_cert_parser1.add_argument("--cn", type=str, help="CN to find", required=True)
    find_cert_parser1.add_argument("--path", type=str, help="Path to bundle", required=True)



    return parser.parse_args()

def main():
    args = parse_arguments()

    if args.command == "list-certs":
        display_list(args.path)

    if args.command == "find-cert":
        find_cert_by_cn(args.cn, args.path)

    if args.command == "find-cert-in-bundle":
        find_cert_in_bundle(args.cn, args.path)


if __name__ == "__main__":
    main()
