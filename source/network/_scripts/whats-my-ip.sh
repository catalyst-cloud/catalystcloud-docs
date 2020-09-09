#!/bin/bash

EXIT=0;

# valid ip function
valid_ip() {
    regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    echo "$1" | egrep "$regex" &>/dev/null
    return $?
}

hash curl 2>/dev/null || {
    echo "Curl command line client is not available, please install it before proceeding";
    EXIT=1;
}

hash dig 2>/dev/null || {
    echo "Dig command line client is not available, please install it before proceeding";
    EXIT=1;
}

if [ "$EXIT" -eq 1 ]; then
    exit 1;
fi

echo finding your external ip ...
hash dig 2>/dev/null && {
    CC_EXTERNAL_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
}
for curl_ip in http://ipinfo.io/ip http://ifconfig.me/ip http://curlmyip.com; do
    CC_EXTERNAL_IP=$( curl -s $curl_ip )
    if valid_ip "$CC_EXTERNAL_IP"; then
        break
    fi
done

if ! valid_ip "$CC_EXTERNAL_IP"; then
    echo "Could not determine your external IP address";
    exit 1;
fi

echo "Your external IP address is: $CC_EXTERNAL_IP"
