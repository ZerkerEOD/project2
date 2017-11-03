#!/bin/bash
set -e
set -u
#set -x  #Used only for testing purposes to see the flow of the program
set -o pipefail


#Inserting a contact
insert_contact () {
	printf "%s:%s:%s:%s\n" "$1" "$2" "$3" "$4" >> "$file_name"
}

#Printing contacts
contact_print () {
printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
awk -F":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}' "$file_name"
}

#Data validation
#Email validation
email_validation () {
test=`echo $1 | egrep "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" | wc -l`
if [ $test == "0" ]
then 
	exit 9
fi
}

#Phone validation
phone_validation () {
test=`echo $1 | egrep '[0-9]{3}-[0-9]{3}-[0-9]{4}' | wc -l`
if [ $test == "0" ]
then
	exit 10
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
	exit 6
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
			exit 7;;
#		: ) echo "Must supply an argument to $OPTARG."
#			getoptions_err;;
	esac
done

#Verify file was given
if [ "$file_name" == "0" ]
then
	exit 5
fi


#Verifying if file exist and the one was provided
if [ "$file_name" != "0" ]
then
	if [ -e "$file_name" ]
	then
		:
	else
		touch "$file_name"
	fi
else
	exit 1
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
	sort_contacts "$flag_sort_contacts"
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

#Printing contacts
if [ "$flag_print_contacts" == "1" ]
then
	#Search no Sort
	if [ "$flag_search_contacts" != "0" ] && 
	   [ "$flag_sort_contacts" == "0" ] 
	then
		if [ cat "$file_name" | egrep $flag_search_contacts | wc -l >= "1" ]
		then
			printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
			cat "$file_name" | egrep "$flag_search_contacts" | sort -t ":" -k "2" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
		else
			exit 8
		fi
	fi
	
	#Search and Sort
	if [ "$flag_search_contacts" != "0" ] &&
	   [ "$flag_sort_contacts" != "0" ] 
	then
		if [ cat "$file_name" | egrep "$flag_search_contacts" | wc -l >= "1" ]
		then
			printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone" 	
			cat "$file_name" | egrep "$flag_search_contacts" | sort -t ":" -k "$flag_sort_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
		else
			exit 8
		fi
	fi

	#No Search Only Sort
	if [ "$flag_search_contacts" == "0" ] && 
	   [ "$flag_sort_contacts" != "0" ]
	then
		printf "%10s %10s %25s %15s\n" "Last" "First" "E-mail" "Phone"
		cat "$file_name" | sort -t ":" -k "$flag_sort_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s\n", $2,$1,$3,$4}'
	fi

	#No sort and no search
 	if [ "$flag_search_contacts" == "0" ] &&
	   [ "$flag_sort_contacts" == "0" ]
	then
		contact_print
	fi
fi

exit 0
