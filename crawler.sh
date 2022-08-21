#!/bin/bash

######################
# Options processing #
######################

page=$1
trg_lang="${2:-fr}"
depth="${3:-2}"
src_lang="${4:-en}"


#########################
# ANSI escape sequences #
#########################

ERASE="\033[K"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
LRED="\e[91m"
LGREEN="\e[92m"
LYELLOW="\e[93m"
LBLUE="\e[94m"
ENDCOLOR="\e[0m"


#########################
# Constants declaration #
#########################

translations_list="interlanguage-link"
page_start="mw-body"
page_end="mw-footer"

hlink="<a"
img="<img"
title2="<h2"
title3="<h3"

missing_reference="need_ref_tag"
warning_bandeau="bandeau-article"
quality_article="Wikipédia:Articles de qualité"


#########################
# Functions declaration #
#########################

get_translate_url () {
	translated_url=`wget -qO- $1 | grep $translations_list | tr '"' '\n' | grep "$2.wikipedia.org"`
	translated_url=$(python3 -c "import urllib.parse; print (urllib.parse.unquote('$translated_url'))")
}

setup_lang_folder () {
	[ ! -d $1 ] && mkdir $1
	[ $(ls $1/ | wc -l) != 0 ] && rm $1/*
}

recursive_dowload () {
	wget $1 --execute='robots=off' \
	--reject 'Main_Page','*.svg','*.png','*.jpg','*.jpeg','*.php','*.ico','*:*','*=*' \
	--recursive \
	--level 1 \
	--quiet \
	--no-clobber \
	--no-directories
}

cut_page_content () {
	echo -n "$(grep -A `cat $1 | wc -l` $page_start $1)" > $1
	echo -n "$(grep -B `cat $1 | wc -l` $page_end $1)" > $1
}

get_page_data () {
	data_result=$(printf "%s %s %s %s %s" `cat $1 | wc -w` `grep -c $hlink $1` \
	`grep -c $img $1` `grep -c $title2 $1` `grep -c $title3 $1`)
}


##########################################
# Variables declaration and errors check #
##########################################

[ -z $page ] && echo "Usage: ./crawler PAGE [TARGET_LANGUAGE=fr] [DEPTH=2] [SOURCE_LANGUAGE=en]" && exit 1
wget --spider -q "www.google.com"
[ $? -ne 0 ] && echo "Error: Cannot reach network: Check internet connection and proxy settings" && exit 1

src_URL="https://$src_lang.wikipedia.org/wiki/$page"
get_translate_url $src_URL $trg_lang
trg_URL=$translated_url

wget --spider -q $src_URL
[ $? -ne 0 ] && echo "Error: $page page does not exist on ${src_lang^^} Wikipedia, $src_URL not found" && exit 1
[ -z $trg_URL ] && echo "Error: $page page on ${src_lang^^} Wikipedia does not have a ${trg_lang^^} translation" && exit 1


###############
# Source code #
###############

# Setup and move into working directory

[ -f $page ] && rm $page
[ ! -d $page ] && mkdir $page
cd $page
[ -f $page.csv ] && rm $page.csv


# Source and target languages pages download

echo -n "Step 1: Downloading pages (might take several minutes...)"

setup_lang_folder $src_lang
cd $src_lang
recursive_dowload $src_URL
cd ..

setup_lang_folder $trg_lang
cd $trg_lang
recursive_dowload $trg_URL
cd ..

echo -e "\rStep 1: Downloading pages"


# Get content from pages

echo -n "Step 2: Processing pages"

progress="0"
total=$(echo "`ls $src_lang | wc -w` + `ls $trg_lang | wc -w`" | bc)

cd $trg_lang
for p in `ls`
	do cut_page_content $p
	progress=$(echo "$progress+1" | bc)
	echo -en "\rStep 2: Processing pages ($progress/$total)"
done
cd ..

cd $src_lang
for p in `ls`
	do cut_page_content $p
	progress=$(echo "$progress+1" | bc)
	echo -en "\rStep 2: Processing pages ($progress/$total)"
done
cd ..

echo -e "\r${ERASE}Step 2: Processing pages"


# Get pages data

echo -n "Step 3: Gathering data"

progress="0"
total="$(ls $src_lang | wc -w)"

for p in `ls $src_lang`
	# get data
	do get_page_data $src_lang/$p
	src_data=$data_result

	get_translate_url "https://$src_lang.wikipedia.org/wiki/$p" $trg_lang
	tr_p=$(echo $translated_url | cut -f 5 -d "/")

	# if there is no translation for this page, then write zeros
	if [ -z $translated_url ]
		then printf "%.2f, %s\n" "0" $p >> $page.csv
	else
		# if the translation is not downloaded, then download it
		if [ ! -f $trg_lang/$tr_p ]
			then cd $trg_lang ; wget -q $translated_url ; cut_page_content $tr_p ; cd ..
		fi
		get_page_data $trg_lang/$tr_p
		tr_data=$data_result

		# calculate score
		score="0"
		for i in {1..5}
			do num=$(echo $tr_data | cut -f $i -d " ")
			denom=$(echo $src_data | cut -f $i -d " ")
			score=$(echo "scale=5; $score+$num/($denom+1)" | bc -l)
		done

		add_info=""
		if [[ ! -z $(grep "$quality_article" $trg_lang/$tr_p) ]]; then add_info="$add_info, quality_article"; fi
		if [[ ! -z $(grep "$missing_reference" $trg_lang/$tr_p) ]]; then add_info="$add_info, missing_reference"; fi
		if [[ ! -z $(grep "$warning_bandeau" $trg_lang/$tr_p) ]]; then add_info="$add_info, warning_bandeau"; fi
		printf '%.2f, "%s", %s, %s\n' $score $p $translated_url "$add_info" >> $page.csv
	fi

	progress=$(echo "$progress+1" | bc)
	echo -en "\rStep 3: Gathering data ($progress/$total)"
done

echo -e "\r${ERASE}Step 3: Gathering data"


# Sort, columnize and print results with colors

echo "$(sort -rn $page.csv | column -t -s ", ")" > $page.csv

while read line
	do if [[ ! -z $(echo $line | grep "0.00") ]]; then score="0"
		else
			if [[ ! -z $(echo $line | grep -F 0.) ]]; then score="2"
			elif [[ ! -z $(echo $line | grep -F 1.) ]]; then score="4"
			else score="6"
			fi

			if [[ ! -z $(echo $line | grep "quality_article") ]]; then score=$(echo "$score+1" | bc); fi
			if [[ ! -z $(echo $line | grep "missing_reference") ]]; then score=$(echo "$score-1" | bc); fi
			if [[ ! -z $(echo $line | grep "warning_bandeau") ]]; then score=$(echo "$score-1" | bc); fi
	fi

	if [[ $score -eq 0 ]]; then echo -e "${RED}$line${ENDCOLOR}";
	elif [[ $score -eq 1 ]]; then echo -e "${LRED}$line${ENDCOLOR}"
	elif [[ $score -eq 2 ]]; then echo -e "${YELLOW}$line${ENDCOLOR}"
	elif [[ $score -eq 3 ]]; then echo -e "${LYELLOW}$line${ENDCOLOR}"
	elif [[ $score -eq 4 ]]; then echo -e "${LGREEN}$line${ENDCOLOR}"
	elif [[ $score -eq 5 ]]; then echo -e "${GREEN}$line${ENDCOLOR}"
	elif [[ $score -eq 6 ]]; then echo -e "${LBLUE}$line${ENDCOLOR}"
	elif [[ $score -eq 7 ]]; then echo -e "${BLUE}$line${ENDCOLOR}"
	fi
done < $page.csv


# Clean downloaded pages

[ -d $src_lang ] && rm -r $src_lang
[ -d $trg_lang ] && rm -r $trg_lang
