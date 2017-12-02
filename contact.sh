#!/bin/bash
set -e
set -u
#set -x  #Used only for testing purposes to see the flow of the program
set -o pipefail

#FUNCTIONS
##Inserting a contact
insert_contact () {
	printf "%s:%s:%s:%s:%s\n" "$1" "$2" "$3" "$4" "$5" >> "$file_name"
}

##Adding contact numbers
contact_number () {
cat "$file_name" | awk -F ":" '{printf "%s:%s:%s:%s:%s:%s:%s\n", $1,$2,$3,$4,$5,NR}' >> tmpcontact.txt
rm "$file_name"
cp tmpcontact.txt "$file_name"
rm tmpcontact.txt
}

##Printing contacts
contact_print_header () {
if [ "$show_contact_number" == "false" ]
then
	printf "%10s %10s %25s %15s %10\n" "Last" "First" "E-mail" "Phone" "Category"
elif [ "$show_contact_number" == "true" ]
then
	printf "%3s %10s %10s %25s %15s %10s\n" "#" "Last" "First" "E-mail" "Phone" "Category"
fi
printf "%10s %10s %25s %15s %10\n" "Last" "First" "E-mail" "Phone" "Category"
}

##Searching Contacts
search_contacts () {
if [ "$flag_search_contacts" != "0" ]
then
    if [ $flag_search_feild == "true" ]
    then
        if (( $(cat "$file_name" | awk -F ":" '/"$flag_search_contacts"/ {if ($search_field") print $0;}' || wc -l) >= "1" ))
        then
            cat "$file_name" | awk -F ":" '/"$flag_search_contacts"/ {if ($search_field") print $0;}'
        fi
	elif (( $(cat "$file_name" | egrep "$flag_search_contacts" | wc -l) >= "1" ))
	then
		contact_print_header
		cat "$file_name" | egrep "$flag_search_contacts" | awk -F ":" '{printf "%10s %10s %25s %15s %10s\n", $2,$1,$3,$4,$5}'
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
	if [ "$show_contact_number" == "false" ]
	then
		awk -F ":" '{printf "%10s %10s %25s %15s %10s\n", $2,$1,$3,$4,$5}' "tmpsortedcontacts.txt"
	elif [ "$show_contact_number" == "true" ]
	then
		awk -F ":" '{printf "%3s %10s %10s %25s %15s %10s\n, $6,$2,$1,$3,$4,$5}' "tmpsortedcontacts.txt"
	fi
fi
}

##Cleaning up
cleanup () {
rm tmpcontacts.txt
rm tmpsortedcontacts.txt
}

#Set up editing of contacts
##Key = 1 flag_edit_contact - 2 search_field - 3 flag_econtactnum
##4 fname - 5 lname - 6 email - 7 phone - 8 category
edit_contact () {
###Edit contact with just -E
if [ "$1" != "0" ]
then
    if [ $(egrep '$1' "$file_name" | wc -l) == "1" ]
    then
        tmpfname=$(egrep '$1' "$file_name" | awk -F ":" '{print $1}')
        tmplname=$(egrep '$1' "$file_name" | awk -F ":" '{print $2}')
        tmpemail=$(egrep '$1' "$file_name" | awk -F ":" '{print $3}')
        tmpphone=$(egrep '$1' "$file_name" | awk -F ":" '{print $4}')
        tmpcategory=$(egrep '$1' "$file_name" | awk -F ":" '{print $5}')

        if [ "$fname" == "0" ]
        then
            fname=$tmpfname
        fi
        if [ "$lname" == "0" ]
        then
            lname=$tmplname
        fi
        if [ "$email" == "0" ]
        then
            email=$tmpemail
        fi
        if [ "$phone" == "0" ]
        then
            phone=$tmpphone
        fi
        if [ "$category" == "0" ]
        then
            category=$tmpcategory
        fi

        sed -i "s/$tmpfname/$fname/" "$file_name"
        sed -i "s/$tmplname/$lname/" "$file_name"
        sed -i "s/$tmpemail/$email/" "$file_name"
        sed -i "s/$tmpphone/$phone/" "$file_name"
        sed -i "s/$tmpcategory/$category/" "$file_name"
    else
        printf "To many contacts:\n"
        egrep '$1' "$file_name"
        exit 15
    fi
#Search within field for specific
elif [ "$2" != "0" ]
then
    if [ $(awk -F ":" '{print $2}' "$file_name" | egrep '$1' | wc -l) == "1" ]
    then
        tmpfname=$(egrep '$1' "$file_name" | awk -F ":" '{print $1}')
        tmplname=$(egrep '$1' "$file_name" | awk -F ":" '{print $2}')
        tmpemail=$(egrep '$1' "$file_name" | awk -F ":" '{print $3}')
        tmpphone=$(egrep '$1' "$file_name" | awk -F ":" '{print $4}')
        tmpcategory=$(egrep '$1' "$file_name" | awk -F ":" '{print $5}')

        if [ "$fname" == "0" ]
        then
            fname=$tmpfname
        fi
        if [ "$lname" == "0" ]
        then
            lname=$tmplname
        fi
        if [ "$email" == "0" ]
        then
            email=$tmpemail
        fi
        if [ "$phone" == "0" ]
        then
            phone=$tmpphone
        fi
        if [ "$category" == "0" ]
        then
            category=$tmpcategory
        fi

        sed -i "s/$tmpfname/$fname/" "$file_name"
        sed -i "s/$tmplname/$lname/" "$file_name"
        sed -i "s/$tmpemail/$email/" "$file_name"
        sed -i "s/$tmpphone/$phone/" "$file_name"
        sed -i "s/$tmpcategory/$category/" "$file_name"
    else
        printf "To many contacts:\n"
        egrep '$1' "$file_name"
        exit 15
    fi

###Using contact number to edit
elif [ "$3" != "0" ]
then
        tmpfname=$(sed -n "$flag_econtactnum p" "$file_name" | awk -F ":" '{print $1}')
        tmplname=$(sed -n "$flag_econtactnum p" "$file_name" | awk -F ":" '{print $2}')
        tmpemail=$(sed -n "$flag_econtactnum p" "$file_name" | awk -F ":" '{print $3}')
        tmpphone=$(sed -n "$flag_econtactnum p" "$file_name" | awk -F ":" '{print $4}')
        tmpcategory=$(sed -n "$flag_econtactnum p" "$file_name" | awk -F ":" '{print $5}')

        if [ "$fname" == "0" ]
        then
            fname=$tmpfname
        fi
        if [ "$lname" == "0" ]
        then
            lname=$tmplname
        fi
        if [ "$email" == "0" ]
        then
            email=$tmpemail
        fi
        if [ "$phone" == "0" ]
        then
            phone=$tmpphone
        fi
        if [ "$category" == "0" ]
        then
            category=$tmpcategory
        fi

        sed -i "s/$tmpfname/$fname/" "$file_name"
        sed -i "s/$tmplname/$lname/" "$file_name"
        sed -i "s/$tmpemail/$email/" "$file_name"
        sed -i "s/$tmpphone/$phone/" "$file_name"
        sed -i "s/$tmpcategory/$category/" "$file_name"
    fi
fi
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
category="0"
show_contact_number="false"
flag_edit_contact="false"
flag_search_field="false"
search_field="0"
flag_econtactnum="false"

#START OF SCRIPT
##Get options from user
while getopts ":ips:f:l:e:n:k:c:t:LE:S:N:" opt; do
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
		t ) category="$OPTARG";;
		L ) show_contact_number="true";;
		E ) flag_edit_contact="$OPTARG";;
		S ) search_field="$OPTARG"
		    flag_search_field="true";;
		N ) flag_econtactnum="$OPTARG";;
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

#Verify Search flag
if [ $flag_search_field != "false" ]
then
    if [ "$search_field" == "0" ] ||
       [ "$search_field" == "1" ] ||
       [ "$search_field" == "2" ] ||
       [ "$search_field" == "3" ] ||
       [ "$search_field" == "4" ] ||
       [ "$search_field" == "5" ]
    then
	    :
    else
	    printf "Search field invalid"
	    exit 15
	fi
fi

#Verify search field only gets used with either search or edit
if ( [ "$search_field" != "0" ] &&
   [ "$flag_search_contacts" != "0" ] ) ||
   ( [ "$search_field" != "0" ] &&
   [ "$flag_edit_contact" != "false" ] )
then
	printf "Search within field needs a search criteria or edit"
	exit 14
fi

#Validate edit
if ( [ "$flag_edit_contact" != "false" ] &&
     [ "$search_field" != "0" ] ) ||
   ( [ "$flag_edit_contact" != "false" ] &&
     [ "$flag_econtactnum" != "false" ] )
then
    printf "Can only use either search or contact number"
    exit 15
fi

if [ "$flag_edit_contact" != "0" ]
then
    if [ "$flag_search_field" != "0" ] ||
       [ "$flag_econtactnum" != "0" ]
    then
        if [ "$fname" != "0" ] ||
           [ "$lname" != "0" ] ||
           [ "$email" != "0" ] ||
           [ "$phone" != "0" ] ||
           [ "$category" != "0" ]
        then
            edit_contact "$flag_edit_contact" "$search_field" "$flag_econtactnum" "$fname" "$lname" "$email" "$phone" "$category"
        fi
    else
        printf "Can only use either search or contact number"
        exit 15
    fi
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
	exit 15
fi

if [ "$flag_insert_contact" != "0" ] &&
   [ "$flag_search_contacts" != "0" ]
then
	printf "To many commands\n"
	exit 15
fi

if [ "$flag_print_contacts" != "0" ] &&
   [ "$flag_search_contacts" != "0" ]
then
	printf "To many commands\n"
	exit 15
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
	
	if [ "$category" == "0" ]
	then
		exit 11
	fi

	insert_contact "$fname" "$lname" "$email" "$phone" "$category"
	contact_number
fi

#PRINTING CONTACTS
if [ "$flag_print_contacts" == "1" ]
then
	sort_contacts
	contact_print_header
	print_contacts
	cleanup
fi

#SEARCHING CONTACTS
if [ "$flag_search_contacts" != "0" ]
then
	search_contacts
fi

exit 0
