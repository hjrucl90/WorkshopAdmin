#!/bin/bash

## syntax: bash.sh [slug] [organisation] [username] [password]
## [slug] in the format of YYYY-MM-DD-Org
## [organisation] is the GitHub organisation in which the repository is

if [[ -z "${1}" || -z "${2}" || -z "${3}" || -z "${4}" ]]
then
  echo "Syntax: bash.sh [slug] [organisation]"
  echo "[slug] in the format of YYYY-MM-DD-Org"
  echo "[organisation] is the GitHub organisation in which the repository is"
	echo "[username] is the username of the database"
	echo "[password] is the password for the database"

else

export GH_TOKEN=`cat gh_token`
# ORGANISATION=NclRSE-Training
ORGANISATION=$2
DB_CLIENT='mysql'
DB_USER=${3}
DB_PASSWD=${4}

# sql:
	SCRIPT1="select slug, w.title, humandate, humantime, startdate, enddate, r.description, r.longitude, r.latitude, language, country, online, pilot, inc_lesson_site, pre_survey, post_survey, carpentry_code, curriculum_code, flavour_id, eventbrite, inc_lesson_site, pre_survey, post_survey, r.what_three_words, schedule \
	from workshops as w \
		join room as r on w.room_id=r.room_id \
	where w.slug=\"${1}\";"
	
	SCRIPT2="select p.title, p.firstname, p.lastname from instructors as i 
  	join people as p on i.person_id=p.person_id \
		where slug=\"${1}\""

	SCRIPT3="select p.title, p.firstname, p.lastname from helpers as h 
  	join people as p on h.person_id=p.person_id \
	where slug=\"${1}\""

	SCRIPT4="select p.email from emails as e
  	join people as p on e.person_id=p.person_id \
	where slug=\"${1}\""

	echo $SCRIPT1 > script1.sql
	echo $SCRIPT2 > script2.sql
	echo $SCRIPT3 > script3.sql
	echo $SCRIPT4 > script4.sql

	RESULT1="$(${DB_CLIENT} --host=localhost --skip-column-names --user=${DB_USER} --password=${DB_PASSWD} workshopadmin < script1.sql)"
	RESULT2="$(${DB_CLIENT} --host=localhost --skip-column-names --user=${DB_USER} --password=${DB_PASSWD} workshopadmin < script2.sql)"
	RESULT3="$(${DB_CLIENT} --host=localhost --skip-column-names --user=${DB_USER} --password=${DB_PASSWD} workshopadmin < script3.sql)"
	RESULT4="$(${DB_CLIENT} --host=localhost --skip-column-names --user=${DB_USER} --password=${DB_PASSWD} workshopadmin < script4.sql)"

SLUG=`echo "$RESULT1"|cut -f1`
TITLE=`echo "$RESULT1"|cut -f2`
ADDRESS=`echo "$RESULT1"|cut -f7`
COUNTRY=`echo "$RESULT1"|cut -f11`
LANGUAGE=`echo "$RESULT1"|cut -f10`
LATITUDE=`echo "$RESULT1"|cut -f9`
LONGITUDE=`echo "$RESULT1"|cut -f8`
HUMANDATE=`echo "$RESULT1"|cut -f3`
HUMANTIME=`echo "$RESULT1"|cut -f4`
STARTDATE=`echo "$RESULT1"|cut -f5`
ENDDATE=`echo "$RESULT1"|cut -f6`
INSTRUCTORS=`echo "$RESULT2"`
EVENTBRITE=`echo "$RESULT1"|cut -f20`

PILOT=`echo "$RESULT1"|cut -f13`
CARPENTRY=`echo "$RESULT1"|cut -f17`
CURRICULUM=`echo "$RESULT1"|cut -f18`
FLAVOUR=`echo "$RESULT1"|cut -f19`
TITLE=`echo "$RESULT1"|cut -f2`
INC_LESSON_SITE=`echo "$RESULT1"|cut -f21`
PRE_SURVEY=`echo "$RESULT1"|cut -f22`
POST_SURVEY=`echo "$RESULT1"|cut -f23`
WHATTHREEWORDS=`echo "$RESULT1"|cut -f24`
SCHEDULE=`echo "$RESULT1"|cut -f25`

cat <<EOM >index.inc
venue: "Newcastle University"
address: "${ADDRESS}"
country: "${COUNTRY}"
language: "${LANGUAGE}"
latitude: "${LATITUDE}"
longitude: "${LONGITUDE}"
humandate: "${HUMANDATE}"
humantime: "${HUMANTIME}"
startdate: ${STARTDATE}
enddate: ${ENDDATE}
instructor: [`echo -e "$RESULT2"|sed "s/\t/ /g"|sed -e "s/^[ \t]*//g"|sed -e "s/^/\"/g"|sed -e "s/$/\"/g"|sed -e "N;s/\n/, /g"|sed -e "s/^[ ]*//g"`]
helper: [`echo -e "$RESULT3"|sed "s/\t/ /g"|sed -e "s/^[ \t]*//g"|sed -e "s/^/\"/g"|sed -e "s/$/\"/g"|sed -e "N;s/\n/, /g"|sed -e "s/^[ ]*//g"`]
email: [`echo -e "$RESULT4"|sed "s/\t/ /g"|sed -e "s/^[ \t]*//g"|sed -e "s/^/\"/g"|sed -e "s/$/\"/g"|sed -e "N;s/\n/, /g"|sed -e "s/^[ ]*//g"`]
collaborative_notes: https://hackmd.io/@rseteam-ncl/${SLUG}
eventbrite: ${EVENTBRITE}
what3words: ${WHATTHREEWORDS}
EOM

if [ $PILOT == 1 ]
then 
	P="true"
else
  P="false"
fi

cat <<EOM >config.inc
carpentry: "${CARPENTRY}"
curriculum: "${CURRICULUM}"
flavor: "${FLAVOUR}"
pilot: ${P}
title: "${TITLE}"
EOM

if [ $PILOT == 1 ]
then
cat <<EOM >>config.inc
incubator_lesson_site: "${INC_LESSON_SITE}"
incubator_pre_survey: "${PRE_SURVEY}"
incubator_post_survey: "${POST_SURVEY}"
EOM

fi


echo Log into GitHub
gh auth login
echo Create website from template
gh repo create ${ORGANISATION}/${SLUG} --template carpentries/workshop-template --public --description "${TITLE}" 
echo Edit the URL for GitHub Pages
gh repo edit ${ORGANISATION}/${SLUG} --homepage "${ORGANISATION}.github.io/${SLUG}"
echo Clone the repo
gh repo clone git@github.com:${ORGANISATION}/${SLUG}.git ../${SLUG}
echo Delete lines 38 to 58
sed -i '38,58d' ../${SLUG}/index.md
echo Delete lines 6 to 21
sed -i '6,21d' ../${SLUG}/index.md
echo Insert index.inc after line 6 of index.md
sed -i '5r index.inc' ../${SLUG}/index.md
echo Delete lines 8 to 72 in _config.yml
sed -i '8,72d' ../${SLUG}/_config.yml
echo Insert config.inc after line 8 of _config.yml
sed -i '8r config.inc' ../${SLUG}/_config.yml
echo Copy schedule
if [ ${SCHEDULE} != "na" ]
then
  cp schedules/${SCHEDULE}.html ../${SLUG}/_includes/${CARPENTRY}/schedule.html
fi

echo Delete temporary files
rm script?.sql

echo Commit changes to repository
cd ../${SLUG}
git add .
git commit -m "Update"
git push

fi
