#!/bin/bash

# Take an IP and subnet mask (ex. 172.23.13.45 255.255.224.0)
# And return the Network address, the first and last hosts, the broadcast and the next network address.
# To run the script, the syntax should be: ./ipv4calc.sh [IP address] [subnet mask]
# 1st argument [$1] = random, or any valid IP address
# 2nd argument [$2]= any valid subnet mask

# initialize variables for later use

# given random ip address + subnet mask (taken from the user arguments $1 and $2)
target=()
# subnet mask from $2
mask=()
# will be calculated based on subnet mask
cidr=0
# network address for our mystery IP address
network=()
# last host address
lasthost=()
# broadcast address for our mystery IP address
broadcast=()
# next network address
next=()
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
    mask+=("$i")
    # if this subnet mask octet is 255,
    if [[ $i == 255 ]]; then
        # the network matches our target for this octet
        # append this octet to the network address variable
        network+=("${target[x]}")
        # append this octet to the next network address variable
        next+=("${target[x]}")
        # append this octet to the broadcast address variable
        broadcast+=("${target[x]}")
        # 8 bits added to cidr
        (( cidr+=8 ))
        # increment octet index counter
        (( x++ ))
        # if the current subnet mask octet we're iterating over is not equal to 0 or 255...
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
        # then the network value plus the magic number gives us our "next-network" octet value
        # add z + m to next network octet list
        (( nz=z+m ))
        # if nz reaches 256, increment the last octet by one and make this octet 0
        if [[ $nz == 256 ]]; then
            # this octet becomes 0
            (( next[$x] = 0 ))
            # w = index of previous octet
            (( w=x-2 ))
            # increment the previous octet by one
            (( next[$w] = ${next[$w]}+1 ))
            # make this octet 0
            (( next[$w+1] = 0 ))
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
        if [[ ${next[$i]} == 256 ]]; then
            # increment previous octet
            (( next[$i-1]++ ))
            # current octet becomes 0
            (( next[$i]=0 ))
        fi
        echo ${next[0]}
}

# for /8,/16,/24 increment the respective octet to find the next network address
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

echo "Target Address: ${target[@]}"
echo "Subnet mask: ${mask[@]}"
echo "CIDR: /"$cidr
echo "Network Address: ${network[@]}"
echo "First Host Address: ${network[@]:0:3} $(( ${network[3]}+1 ))"
echo "Last Host Address: ${lasthost[@]}"
echo "Broadcast Address: ${broadcast[@]}"
echo "Next Network Address: ${next[@]}"