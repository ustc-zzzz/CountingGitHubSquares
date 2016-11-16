#!/bin/bash

if [ -d "build" ]
then
    rm -rf build/
fi

mkdir build/
git init build/ >/dev/null

OPT_USERNAME=$(git config --global user.name)
OPT_EMAIL=$(git config --global user.email)
OPT_DATE=$(date +%s)
OPT_IMAGE="build.txt"

while getopts "u:e:d:" OPT
do
	case $OPT in
		u) OPT_USERNAME=$OPTARG;;
		e) OPT_EMAIL=$OPTARG;;
        d) OPT_DATE=$(date -d $OPTARG +%s);;
	esac
done
shift $(($OPTIND-1))

# Because the first day of a week in GitHub is Sunday while 1970-1-1 is Friday
GITHUB_DATE=$(($OPT_DATE+86400*4))

# Half a day is added for different time zone, and a week has 604800 seconds
GITHUB_DATE=$((43200+$GITHUB_DATE/604800*604800))

# A Sunday one year ago
GITHUB_DATE=$(($GITHUB_DATE-86400*(4+52*7)))

# Seven lines for seven days in a week
IMAGE_SUN=$(cat $OPT_IMAGE | head -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_MON=$(cat $OPT_IMAGE | head -n2 | tail -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_TUE=$(cat $OPT_IMAGE | head -n3 | tail -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_WED=$(cat $OPT_IMAGE | head -n4 | tail -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_THU=$(cat $OPT_IMAGE | head -n5 | tail -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_FRI=$(cat $OPT_IMAGE | head -n6 | tail -n1 | tr '[\ \.\-\+\*]' [01234])
IMAGE_SAT=$(cat $OPT_IMAGE | head -n7 | tail -n1 | tr '[\ \.\-\+\*]' [01234])

# Do git commit
do_commit()
{
    REAL_COMMIT_DATE=$1
    COMMIT_DATE_STRING=$(date -d @$REAL_COMMIT_DATE)
    if [ $OPT_DATE -ge $1 ];
    then
        echo "commit at $COMMIT_DATE_STRING($1)" >>build/build.log
        cd build/
        git add build.log
        GIT_AUTHOR_DATE=$1 GIT_COMMITTER_DATE=$1 \
            git commit -m "commit at $1" >/dev/null
        cd ../
    fi
}

# Format: commit char date
commit()
{
    case ${1:1:1} in
        "0")
            ;;
        "1")
            do_commit $(($2-1))
            do_commit $(($2+1))
            ;;
        "2")
            do_commit $(($2-5))
            do_commit $(($2-3))
            do_commit $(($2-1))
            do_commit $(($2+1))
            do_commit $(($2+3))
            do_commit $(($2+5))
            ;;
        "3")
            do_commit $(($2-9))
            do_commit $(($2-7))
            do_commit $(($2-5))
            do_commit $(($2-3))
            do_commit $(($2-1))
            do_commit $(($2+1))
            do_commit $(($2+3))
            do_commit $(($2+5))
            do_commit $(($2+7))
            do_commit $(($2+9))
            ;;
        "4")
            do_commit $(($2-13))
            do_commit $(($2-11))
            do_commit $(($2-9))
            do_commit $(($2-7))
            do_commit $(($2-5))
            do_commit $(($2-3))
            do_commit $(($2-1))
            do_commit $(($2+1))
            do_commit $(($2+3))
            do_commit $(($2+5))
            do_commit $(($2+7))
            do_commit $(($2+9))
            do_commit $(($2+11))
            do_commit $(($2+13))
            ;;
    esac
}

echo "username: $OPT_USERNAME"
echo "email: $OPT_EMAIL"
echo "date: $(date -d @$OPT_DATE)($OPT_DATE)"
echo ""

echo "username: $OPT_USERNAME" >>build/build.log
echo "email: $OPT_EMAIL" >>build/build.log
echo "date: $(date -d @$OPT_DATE)($OPT_DATE)" >>build/build.log
echo "" >>build/build.log

echo "starting commit for 53 weeks: "
echo "-------------------------------------------------------"
echo -n "|"

for I in {0..52}
do
    COMMIT_DATE=$(($GITHUB_DATE+604800*$I))
    commit \'${IMAGE_SUN:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_MON:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_TUE:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_WED:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_THU:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_FRI:$I:1}\' $COMMIT_DATE
    COMMIT_DATE=$(($COMMIT_DATE+86400))
    commit \'${IMAGE_SAT:$I:1}\' $COMMIT_DATE
    echo -n "="
done

echo "|"
echo "-------------------------------------------------------"
echo "commit completed"
echo ""
echo "you can find your git repo on build/ folder"

