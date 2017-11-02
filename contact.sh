#!/bin/bash
set -e
set -u
set -x
set -o pipefail


#Inserting a contact
insert_contact () {
	printf "%s:%s:%s:%s\n" "$1" "$2" "$3" "$4" >> contact.txt
}

#Printing contacts
contact_print () {
printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
awk -F":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}' contact.txt
}

#Data validation
#Email validation
email_validation () {
test=`echo $1 | egrep "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | wc -l`
if [ $test == "0" ]
then 
	exit 1
fi
}

#Phone validation
phone_validation () {
test=`echo $1 | egrep '[0-9]{3}-[0-9]{3}-[0-9]{4}' | wc -l`
if [ $test == "0" ]
then
	exit 1
fi
}

sort_contacts () {
if [ "$flag_sort_contacts" == "f" ] ||
   [ "$flag_sort_contacts" == "l" ] ||
   [ "$flag_sort_contacts" == "e" ] ||
   [ "$flag_sort_contacts" == "n" ]
then
	if [ "$flag_sort_contacts" == "f" ]
	then 
		flag_sort_contacts="1"
	fi
	if [ "$flag_sort_contacts" == "l" ]
	then
		flag_sort_contacts="2"
	fi
	if [ "$flag_sort_contacts" == "e" ]
	then
		flag_sort_contacts="3"
	fi
	if [ "$flag_sort_contacts" == "n" ]
	then
		flag_sort_contacts="4"
	fi
else
	echo "Sort options are \"f\" \"l\" \"e\" or \"n\""
	exit 1
fi
}

#Setting Flags
flag_insert_contact="0"
flag_print_contacts="0"
flag_sort_contacts="0"
flag_search_contacts="0"
file_name="0"
fname="0"
lname="0"
email="0"
phone="0"

#Getting options and starting script
while getopts ":ips:f:l:e:n:k:c:" opt; do
	case $opt in
		i ) flag_insert_contact=1;;
		p ) flag_print_contacts=1;;
		s ) flag_search_contacts="$OPTARG";;
		k ) flag_sort_contacts="$OPTARG";;
		f ) fname="$OPTARG";;
		l ) lname="$OPTARG";;
		e ) email="$OPTARG";;
		n ) phone="$OPTARG";;
		c ) file_name="$OPTARG";;
		\?) echo "Invalid option: -$OPTARG" >&2
			exit 1;;
		: ) echo "Option -"$OPTARG" requires an argument." >&2
			exit 1;;
	esac
done

#Testing email and phone
if [ "$email" != "0" ] 
then
	email_validation "$email"
fi

if [ "$phone" != "0" ]
then
	phone_validation "$phone"
fi

#Testing
if [ "$flag_sort_contacts" != "0" ]
then
	sort_contacts "$flag_sort_contacts"
fi

#Testing to add contact else exit with error
if [ "$flag_insert_contact" == "1" ] && 
   [ "$fname" != "0" ] && 
   [ "$lname" != "0" ] && 
   [ "$email" != "0" ] && 
   [ "$phone" != "0" ]
then 
	insert_contact "$fname" "$lname" "$email" "$phone"
fi

#Printing contacts
if (( $flag_print_contacts == 1 ))
then
	if [ "$flag_search_contacts" != "0" ] && 
	   [ "$flag_sort_contacts" == "0" ] 
	then
		cat contact.txt | egrep '\"$flag_search_contacts\"' | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
	fi
	
	if [ "$flag_search_contacts" != "0" ] &&
	   [ "$flag_sort_contacts" != "0" ] 
	then
		cat contact.txt | egrep '\"$flag_search_contacts\"' | sort -t ":" -k "$flag_sort_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
	fi
	if [ "$flag_search_contacts" == "0" ] && 
	   [ "$flag_sort_contacts" != "0" ]
	then
		cat contact.txt | sort -t ":" -k "$flag_sort_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
	fi
 	if [ "$flag_search_contacts" == "0" ] &&
	   [ "$flag_sort_contacts" == "0" ]
	then
		contact_print
	fi
fi
