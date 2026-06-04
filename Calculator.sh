#!/bin/bash

function print_color() {
    NC='\033[0m'

    case $1 in 
      "green") color='\033[0;32m' ;;
      "red") color='\033[0;31m' ;;
      "*") color='\033[0m' ;;
    esac

    echo -e "${color} $2 ${NC}"
}

function read_number() {
    read -p "Enter Number1: " number1
    read -p "Enter Number2: " number2
} 

while true  
do 
    print_color "green" "......Calculator......"
    echo "1)Addition"
    echo "2)Subtraction"
    echo "3)Multiplication"
    echo "4)Division"
    echo "5)Exit"
    read -p "Choose from the above options: " choice

case $choice in 

    1)
        read_number
        print_color "green" "Answer=$(( $number1 + $number2 ))"
    ;;
    2)
        read_number
        print_color "green" "Answer=$(( $number1 - $number2 ))"
    ;;
    3)
        read_number
        print_color "green" "Answer=$(( $number1 * $number2 ))"
    ;;
    4)
        read_number
        print_color "green" "Answer=$(( $number1 / $number2 ))"
    ;;
    5)
        break
    ;;

esac
done