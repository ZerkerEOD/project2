#!/bin/bash
set -e
set -u
set -o pipefail


#Inserting a contact
insert_contact () {
	printf "%s:%s:%s:%s\n" "$1" "$2" "$3" "$4" >> contact.txt
}

#Prints the contacts to the display
print_contact () {
	printf "%10s %10s %25s %15s\n" "$1" "$2" "$3" "$4"
}

#Prints the header for the contacts
print_header () {
	printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
}

#Complete contact print
comp_print () {
	print_header
	for i in "${f_name[@]}"
	do
		tmp_f_name= f_name[@]
		tmp_l_name= l_name[@]
		tmp_e_mail= e_mail[@]
		tmp_phone= phone[@]
		print_contact $tmp_l_name $tmp_f_name $tmp_e_mail $tmp_phone
	done
}

#Reads the file with field deliminator of colon and stores values to 4 arrays
rs_contact () {
	awk -F ":"  '{f_name[NR]=$1;l_name[NR]=$2;e_mail[NR]=$3;phone[NR]=$4}' contact.txt
}

#Getting options and starting script
while getopts ":iPs:f:l:e:n:k:c:" opt; do
	case $opt in
		i) if [ *command needed to verify -f was used* && *etc with -len* ]
		   then 
			insert_contact
		   fi;;
		l) lname= "$OPTARGT"
		\?)
		 	echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done
