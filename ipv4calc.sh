#!/bin/bash

# Take an IP and subnet mask (ex. 172.23.13.45 255.255.224.0)
# And return the Network address, the first and last hosts, the broadcast and the next network address.
# To run the script, the syntax should be: ./ipv4calc.sh [IP address] [subnet mask]
# 1st argument [$1] = IP address
# 2nd argument [$2]= subnet mask
[[ "$2" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]

target="$1 $2"
network=0
mask=0

for i in ${BASH_REMATCH[@]}; do
    if [[ $i == 255 ]]; then
        (( mask += 8 ))
        echo $i
    elif [[ $i > 0 && $i < 255 ]]; then
        echo interesting
    elif [[ $i == 0 ]]; then
        echo "network equals 0"
    fi
done
echo $mask

# break up the IP address into octets
[[ "$1" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
ip1=${BASH_REMATCH[1]}
ip2=${BASH_REMATCH[2]}
ip3=${BASH_REMATCH[3]}
ip4=${BASH_REMATCH[4]}

# echo $ip4


# function to process each octet

# if this octet is 255, this octet in the network address
# is equal to the corresponding octet of the given IP address
# if [[ $2 == 255 ]]; then
#     network=$1
# # if this octet is 0, the network address for this octet will be 0
# elif [[ $2 == 0 ]]; then
#     network=0
# # if this octet is not 255 or 0, the network address value for this octet
# # is the lowest multiple of 256 - V (the value of octet in question)
# else
#     network="interesting"
# fi

# echo "Your network octet is $network"