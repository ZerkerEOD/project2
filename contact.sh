#!/bin/bash
set -e
set -u
#set -x  #Used only for testing purposes to see the flow of the program
set -o pipefail

#FUNCTIONS
##Inserting a contact
insert_contact () {
	printf "%s:%s:%s:%s\n" "$1" "$2" "$3" "$4" >> "$file_name"
}

##Printing contacts
contact_print_header () {
printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
}

##Searching Contacts
search_contacts () {
if [ "$flag_search_contacts" != "0" ]
then
	if (( $(cat "$file_name" | egrep "$flag_search_contacts" | wc -l) >= "1" ))
	then
		cat "$file_name" | egrep "$flag_search_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
	else
		printf "No contacts match search criteria"
		exit 8
	fi
fi
}

##Sort Contacts
sort_contacts () {
if [ "$flag_sort_contacts" != "0" ]
then
	sort -t ":" -k "$flag_sort_contacts" "$file_name" > tmpsortedcontacts.txt
else
	sort -t ":" -k "2" "$file_name" > tmpsortedcontacts.txt
fi
}

##Printing contacts
print_contacts () {
if [ "$flag_print_contacts" == "1" ]
then
	awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}' "tmpsortedcontacts.txt"
fi
}

##Cleaning up
cleanup () {
rm tmpcontacts.txt
rm tmpsortedcontacts.txt
}

#DATA VALIDATION
##Email validation
email_validation () {
test=`echo $1 | egrep "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | wc -l`
if [ $test == "0" ]
then 
	exit 9
fi
}

##Phone validation
phone_validation () {
test=`echo $1 | egrep '[0-9]{3}-[0-9]{3}-[0-9]{4}' | wc -l`
if [ $test == "0" ]
then
	exit 10
fi
}

##Contact sort validation
sort_contacts_validation () {
if [ "$flag_sort_contacts" == "1" ] ||
   [ "$flag_sort_contacts" == "2" ] ||
   [ "$flag_sort_contacts" == "3" ] ||
   [ "$flag_sort_contacts" == "4" ]
then
	:
else
	echo "Sort options are \"1\" \"2\" \"3\" or \"4\""
	exit 6
fi
}

#SETTING FLAGS
flag_insert_contact="0"
flag_print_contacts="0"
flag_sort_contacts="0"
flag_search_contacts="0"
file_name="0"
fname="0"
lname="0"
email="0"
phone="0"

#START OF SCRIPT
##Get options from user
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
			exit 7;;
#		: ) echo "Must supply an argument to $OPTARG."
#			getoptions_err;;
	esac
done

#Verifying if file exist and that one was provided
if [ "$file_name" != "0" ]
then
	if [ -e "$file_name" ]
	then
		:
	else
		touch "$file_name"
	fi
else
	exit 5
fi

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
	sort_contacts_validation "$flag_sort_contacts"
fi

#EXITING IF TO MANY COMMANDS
if [ "$flag_insert_contact" != "0" ] &&
   [ "$flag_print_contacts" != "0" ]
then
	printf "To many commands\n"
	exit 11
fi

if [ "$flag_insert_contact" != "0" ] &&
   [ "$flag_search_contacts" != "0" ]
then
	printf "To many commands\n"
	exit 11
fi

if [ "$flag_print_contacts" != "0" ] &&
   [ "$flag_search_contacts" != "0" ]
then
	printf "To many commands\n"
	exit 11
fi


#Testing to add contact else exit with error
if [ "$flag_insert_contact" == "1" ] 
then 
	if [ "$fname" == "0" ]
	then
		exit 1
	fi

 	if [ "$lname" == "0" ]
	then
		exit 2
	fi

	if [ "$email" == "0" ]
	then
		exit 3
	fi

	if [ "$phone" == "0" ]
	then
		exit 4
	fi

	insert_contact "$fname" "$lname" "$email" "$phone"
fi

if [ "$flag_print_contacts" == "1" ]
then
	sort_contacts
	contact_print_header
	print_contacts
	cleanup
fi

if [ "$flag_search_contacts" != "0" ]
then
	search_contacts
fi

exit 0
