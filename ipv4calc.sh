#!/bin/bash

# Take an IP and subnet mask (ex. 172.23.13.45 255.255.224.0)
# And return the Network address, the first and last hosts, the broadcast and the next network address.
# To run the script, the syntax should be: ./ipv4calc.sh [IP address] [subnet mask]
# 1st argument [$1] = random, or target IP address
# 2nd argument [$2]= subnet mask

# initialize variables for later use
target=()
network=""
cidr=0

# break up the IP address into octets
[[ "$1" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
for i in ${BASH_REMATCH[@]:1:4}; do
    target+=("$i")
done

echo ${target[@]}

# ${arr[@]:s:n}	Retrieve n elements starting at index s
# get CIDR from subnet mask using regex groups
# [[ "$2" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
# ${arr[@]:s:n}	Retrieve n elements starting at index s
# for i in ${BASH_REMATCH[@]:1:4}; do
#     echo $i
#     x=0
#     if [[ $i == 255 ]]; then

#         (( cidr += 8 ))
#         network+="${ip[x]}"
#         (( x++ ))
#         echo $x
#     elif [[ $i > 0 && $i < 255 ]]; then
#         network+="?"
#         # echo interesting
#     elif [[ $i == 0 ]]; then
#         network+="0"
#         echo "network octet equals 0"
#     fi
# done
# echo $mask
# echo $network

# echo "Network Address: $network"
# echo "First Host Address: $network"
# echo "Last Host Address: $network"
# echo "Broadcast Address: $network"
# echo "Next Network Address: $network"


# # function to process each octet

# # if this octet is 255, this octet in the network address
# # is equal to the corresponding octet of the given IP address
# # if [[ $2 == 255 ]]; then
# #     network=$1
# # # if this octet is 0, the network address for this octet will be 0
# # elif [[ $2 == 0 ]]; then
# #     network=0
# # # if this octet is not 255 or 0, the network address value for this octet
# # # is the lowest multiple of 256 - V (the value of octet in question)
# # else
# #     network="interesting"
# # fi

# # echo "Your network octet is $network"

# # for i in ${filenamearray[@]}; do
# #   [[ "$i" =~ (${user})([0-9]+) ]]
# #   # echo "${BASH_REMATCH[2]}"
# #   filenumberarray+=(${BASH_REMATCH[2]})
# # done