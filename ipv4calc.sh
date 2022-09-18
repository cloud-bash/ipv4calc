#!/bin/bash

# This script returns the network, first and last hosts, broadcast and the next network address
# The information will be provided in the following format

# echo """Target       : ${target[@]}
# Subnet mask  : ${mask[@]}
# CIDR         : /$cidr
# of Hosts     : $(( 2**((32-cidr))-2 ))
# Network      : ${network[@]}
# First Host   : ${network[@]:0:3} $(( ${network[3]}+1 ))
# Last Host    : ${lasthost[@]}
# Broadcast    : ${broadcast[@]}
# Next Network : ${next[@]}"""


# To run the script, the syntax should be:
# ./ipv4calc.sh [IP address] [subnet mask]
# 1st argument [$1] = any valid IPv4 address
# 2nd argument [$2]= any valid subnet mask

# initialize variables

target=()
mask=()
cidr=0
network=()
lasthost=()
broadcast=()
next=()
# counter for octet index
x=0

# ${arr[@]:s:n}	Retrieve n elements starting at index s

# break up the IP address into a list of octets
[[ "$1" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
for i in ${BASH_REMATCH[@]:1:4}; do
    target+=("$i")
done

# break up the subnet mask into a list of octets
[[ "$2" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
for i in ${BASH_REMATCH[@]:1:4}; do
    mask+=("$i")
    if [[ $i == 255 ]]; then
        # network matches target for this octet
        network+=("${target[x]}")
        # broadcast matches target for this octet
        broadcast+=("${target[x]}")
        # next network address will match unless incremented by next octet reaching 256
        next+=("${target[x]}")
        # 8 bits added to cidr
        ((cidr+=8))
        # increment octet index counter
        ((x++))
    elif [[ $i > 0 && $i < 255 ]]; then
        # m - magic number = number of addresses per network
        ((m=256-i))
        # d = floor divide current octet of target by the magic number (bash shell floored divides integers automatically)
        d=$((${target[$x]}/m))
        # n = d times magic number = network value for this octet
        n=$((d*m))
        # add n to network octet list
        network+=("$n")
        # network octet plus magic number = next network octet
        # add n + m to next network octet list
        ((nm=n+m))
        broadcast+=("$((nm-1))")
        case $x in
            "1")
            broadcast+=("255" "255")
            lasthost+=(${broadcast[@]:0:3} $((broadcast[3]-1)))
            # if this octet index == 1, then the two remaining broadcast octets = 255
            ;;
            "2")
            broadcast+=("255")
            lasthost+=(${broadcast[@]:0:3} $((broadcast[3]-1)))
            # if this octet index == 2, then the last remaining broadcast octet = 255
            ;;
            "3")
            lasthost+=(${broadcast[@]:0:3} $((broadcast[3]-1)))
            # if this octet index == 3, then the broadcast is already calculated
            ;;
        esac
        # if nm reaches 256, increment the last octet by one and make this octet 0
        if [[ $nm == 256 ]]; then
            # this octet becomes 0
            ((next[$x]=0))
            # w = index of previous octet
            ((w=x-1))
            # increment the previous octet by one
            ((next[$w]++))
            if [[ ${next[$w]} == 256 ]]; then
                ((next[$w]=0))
                # w = index of previous octet
                ((w--))
                # increment the previous octet by one
                ((next[$w]++))
                if [[ ${next[$w]} == 256 ]]; then
                    ((next[$w]=0))
                    # w = index of previous octet
                    ((w--))
                    # increment the previous octet by one
                    ((next[$w]++))
                fi    
            fi
            # this octet becomes 0
            ((next[$w+1]=0))
        else
            next+=("$nm")
        fi
        (( x++ ))
        case $i in
        # add correct number of bits to cidr
        # TODO: Implement bitwise operator to derive cidr?
            "128")
                ((cidr+=1))
                ;;
            "192")
                ((cidr+=2))
                ;;
            "224")
                ((cidr+=3))
                ;;
            "240")
                ((cidr+=4))
                ;;
            "248")
                ((cidr+=5))
                ;;
            "252")
                ((cidr+=6))
                ;;
            "254")
                ((cidr+=7))
                ;;
        esac
    elif [[ $i == 0 ]]; then
        network+=("0")
        next+=("0")
    fi
done

function increment() {
        # get octet index from cidr
        ((i=cidr*4/32-1))
        # increment this octet for correct next network address
        ((next[$i]++))
        if [[ ${next[$i]} == 256 ]]; then
            # increment previous octet
            ((next[$i-1]++))
            # current octet becomes 0
            ((next[$i]=0))
        fi
}

# for cidr /8,/16,/24 increment the respective octet to find the next network address
case $cidr in
    "24")
        increment
        # broadcast will be 255 for 4th octet
        broadcast+=("255")
        # last host = x.x.x.254
        lasthost=(${network[@]:0:3} 254)
    ;;
    "16")
        increment
        # broadcast will be x.x.255.255
        broadcast+=("255 255")
        # last host = x.x.255.254
        lasthost=(${network[@]:0:2} 255 254)
    ;;
    "8")
        increment
        # broadcast will be x.255.255.255
        broadcast+=("255 255 255")
        # last host = x.255.255.254
        lasthost=(${network[@]:0:1} 255 255 254)
    ;;
esac

echo """Target       : ${target[@]}
Subnet mask  : ${mask[@]}
CIDR         : /$cidr
# of Hosts   : $((2**((32-cidr))-2))
Network      : ${network[@]}
First Host   : ${network[@]:0:3} $((${network[3]}+1))
Last Host    : ${lasthost[@]}
Broadcast    : ${broadcast[@]}
Next Network : ${next[@]}"""