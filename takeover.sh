#!/bin/bash
while getopts u:d:p:f: option
do
case "${option}"
in
	u) USER=${OPTARG};;
	d) DOMAIN=${OPTARG};;
esac
done

if [ -n "$DOMAIN" ];
then

	rm -rf "$DOMAIN"
	mkdir "$DOMAIN"
	echo "$DOMAIN"
	sudo python ./Sublist3r/sublist3r.py -d "$DOMAIN" --verbose --threads 50 -o "$DOMAIN"/hosts.txt

	input="$DOMAIN"/"hosts.txt"
	while IFS= read -r line
	do
		b=${line%,*}
		varcname=$(dig +nocmd "$b" cname a +noall +answer)
		if [ -n "$DOMAIN" ];
		then
			var="$(echo "$varcname"|tr -d '\n')"
	    	echo "$var" >> "$DOMAIN"/cnames.txt
		fi
		[[ "$varcname" == *".github"* ]] && http -b GET "$b" | grep -F -q "<strong>There isn't a GitHub Pages site here.</strong>" && echo "$varcname" >> "$DOMAIN"/takeover.txt; 
		[[ "$varcname" == *".amazonaws"* ]] && http -b GET "$b" | grep -E -q '<Code>NoSuchBucket</Code>|<li>Code: NoSuchBucket</li>' && echo "$varcname" >> "$DOMAIN"/takeover.txt; 
		[[ "$varcname" == *".herokudns"* ]] && http -b GET "$b" | grep -F -q "//www.herokucdn.com/error-pages/no-such-app.html" && echo "$varcname" >> "$DOMAIN"/takeover.txt; 
		[[ "$varcname" == *".readme"* ]] && http -b GET "$b" |grep -F -q "Project doesnt exist... yet!" && echo "$varcname" >> "$DOMAIN"/takeover.txt; 
	  
	done < "$input"
fi;
 
