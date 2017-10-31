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

#Data validation
#Email validation
email_validation () {
if echo $1 | egrep "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" 
then 
	return $1
else
	exit 1
fi
}

#Phone validation
phone_validation () {
if echo $1 | egrep "^(\d{10}|((([0-9]{3})\s){2})[0-9]{4}|((([0-9]{3})\-){2})[0-9]{4}|([(][0-9]{3}[)])[0-9]{3}[-][0-9]{4})$"
then
	return $1
else
	exit 1
fi
}

#Complete contact print
comp_print () {
	print_header
	for i in "${f_name[@]}"
	do
		local tmp_f_name=f_name[@]
		local tmp_l_name=l_name[@]
		local tmp_e_mail=e_mail[@]
		local tmp_phone=phone[@]
		print_contact "$tmp_l_name" "$tmp_f_name" "$tmp_e_mail" "$tmp_phone"
	done
}

#Reads the file with field deliminator of colon and stores values to 4 arrays
rs_contact () {
	awk -F ":"  '{f_name[NR]=$1;l_name[NR]=$2;e_mail[NR]=$3;phone[NR]=$4}' contact.txt
}

#Sorting contacts
contact_sort () {
	if (( $flag_sort_contacts == f || $flag_sort_contacts == l || $flag_sort_contacts == e || $flag_sort_contacts == p ))
	then
		if (( $flag_sort_contacts == f ))
		then 
			return 1
		fi
		if (( $flag_sort_contacts == l ))
		then
			return 2
		fi
		if (( $flag_sort_contacts == e ))
		then
			return 3
		fi
		if (( $flag_sort_contacts == p ))
		then
			return 4
		fi
	else
		echo "Sort options are \"f\" \"l\" \"e\" or \"p\""
	fi
}

#Setting Flags
flag_insert_contact=0
flag_print_contacts=0
flag_sort_contacts=0
flag_search_contacts=0
fname=0
lname=0
email=0
phone=0

#Getting options and starting script
while getopts ":iPs:f:l:e:n:k:c:" opt; do
	case $opt in
		i ) flag_insert_contact=1;;
		P ) flag_print_contacts=1;;
		s ) flag_search_contacts="$OPTARG";;
		k ) flag_sort_contacts="$OPTARG";;
		f ) fname="$OPTARG";;
		l ) lname="$OPTARG";;
		e ) email="$OPTARG";;
		n ) phone="$OPTARG";;
		\?) echo "Invalid option: -$OPTARG" >&2
			exit 1;;
		: ) echo "Option -"$OPTARG" requires an argument." >&2
			exit 1;;
	esac
done

$email=email_validation "$email"
$phone=phone_validation "$phone"

#Testing to add contact else exit with error
if (( $flag_insert_contact == 1 && $fname != 0 && $lname != 0 && $email != 0 && $phone != 0 ))
then 
	insert_contact "$fname" "$lname" "$email" "$phone"
else
	exit 1
fi

#Printing contacts
if (( $flag_print_contacts == 1 ))
then
	if (( flag_search_contacts != 0 && flag_sort_contacts == 0 )) 
	then
		cat contact.txt | egrep '\"$flag_search_contacts\"' | awk -F ":" '{f_name[NR]=$1;l_name[NR]=$2;e_mail[NR]=$3;phone[NR]=$4}'
		comp_print
	fi
	
	if (( flag_search_contacts != 0 && flag_sort_contacts != 0 ))
	then
		cat contact.txt | egrep '\"$flag_search_contacts\"' | sort -t ":" -k contact_sort | awk -F ":" '{f_name[NR]=$1;l_name[NR]=$2;e_mail[NR]=$3;phone[NR]=$4}'
		comp_print
	fi
	if (( flag_search_contacts == 0 && flag_sort_contacts != 0 ))
	then
		cat contact.txt | sort -t ":" -k contact_sort | awk -F ":" '{f_name[NR]=$1;l_name[NR]=$2;e_mail[NR]=$3;phone[NR]=$4}'
		comp_print
	fi
else
	rs_contact
	comp_print
fi
