#!/bin/bash

# Take an IP and subnet mask (ex. 172.23.13.45 255.255.224.0)
# And return the Network address, the first and last hosts, the broadcast and the next network address.
# To run the script, the syntax should be: ./ipv4calc.sh [IP address] [subnet mask]
# 1st argument [$1] = random, or any valid IP address
# 2nd argument [$2]= any valid subnet mask

# initialize variables for later use

# given random ip address + subnet mask (taken from the user arguments $1 and $2)
target=()
# network address for our mystery IP address
network=()
# next network address
next=()
# will be calculated based on subnet mask
cidr=0
# x=octet index counter
x=0

# break up the IP address into a list of octets
[[ "$1" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
for i in ${BASH_REMATCH[@]:1:4}; do
    target+=("$i")
done

# get CIDR from subnet mask using regex groups
[[ "$2" =~ ([0-9]+).([0-9]+).([0-9]+).([0-9]+) ]]
# ${arr[@]:s:n}	Retrieve n elements starting at index s
for i in ${BASH_REMATCH[@]:1:4}; do
    # if this subnet mask octet is 255,
    if [[ $i == 255 ]]; then
        # the network matches our target for this octet
        # append this octet to the network address variable
        network+=("${target[x]}")
        # append this octet to the next network address variable
        next+=("${target[x]}")
        # 8 bits added to cidr
        (( cidr+=8 ))
        # increment octet index counter
        (( x++ ))
    elif [[ $i > 0 && $i < 255 ]]; then
        # m - magic number
        (( m=256-i ))
        # bash will use floored division automatically bc integer data type
        # d = floor divide current octet of target by the magic number
        d=$(( ${target[$x]}/m ))
        # z = network value for this octet
        z=$(( d*m ))
        # add z to network octet list
        network+=("$z")
        # add z + m -1 to next network octet list
        (( nz=z+m ))
        # if nz reaches 256, increment the last octet by one and make this octet 0
        if [[ $nz == 256 ]]; then
            # w = index of previous octet
            (( w=x-1 ))
            # increment the last octet by one
            (( next[$w] = ${next[$w]}+1 ))
            # make this octet 0
            next+=("0")
        else
            next+=("$nz")
        fi
        # increment octet index counter
        (( x++ ))
        # add correct number of bits for cidr
        # 128, 192, 224, 240, 248, 252, 254
        # oct - 128 > 0 then cidr+=1...etc.
        case $i in
            "128")
                (( cidr+=1 ))
                ;;
            "192")
                (( cidr+=2 ))
                ;;
            "224")
                (( cidr+=3 ))
                ;;
            "240")
                (( cidr+=4 ))
                ;;
            "248")
                (( cidr+=5 ))
                ;;
            "252")
                (( cidr+=6 ))
                ;;
            "254")
                (( cidr+=7 ))
                ;;
        esac
    elif [[ $i == 0 ]]; then
        network+=("0")
        next+=("0")
    fi
done

function increment() {
        # get octet index from cidr
        (( i = cidr * 4 / 32 - 1 ))
        # increment this octet for correct next network address
        (( next[$i]++ ))
}

# for /8,/16,/24 increment the respective octet to find the next network address
case $cidr in
    "24")
        increment
    ;;
    "16")
        increment
    ;;
    "8")
        increment
    ;;
esac
echo "Target Address: ${target[@]}"
echo "CIDR: /"$cidr
echo "Network Address: ${network[@]}"
echo "First Host Address: ${network[@]:0:3} $(( ${network[3]}+1 ))"
# echo "Last Host Address: $network"
# echo "Broadcast Address: $network"
echo "Next Network Address: ${next[@]}"