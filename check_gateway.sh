#!/bin/bash
# Expects 2 arguments
if [ $# -ne 2 ]
then
echo "Incorrect number of arguments.Expects 2 arguments."
echo "First argument should be files path and Second argument should be periodic duraton in minutes."
echo "Eg: /opt/nagios-plugins/check_sap_gateway.sh /usr/sap/<SID>/DVELog/work 30"
exit
fi
duration=$2
Data=`grep -B 1 -e "ERROR.*gateway down" $1 | grep -v "gateway down" | awk '{$1=""; print $0}' | sed 's/^\ //g'`
# validate date
echo "$Data" |
while IFS= read -r DT
do
chkdt=`echo $DT | wc -c`
if [ $chkdt -ge 24 ]
then
        issue_time_secs=`date -d "$DT" +%s`
        issue_time_mins=`echo "$issue_time_secs / 60" | bc`

        CurDT=`date +%s`
        if [ -s /tmp/gateway_checked_time.txt ]
        then
                file_time_secs=`cat /tmp/gateway_checked_time.txt`
                cur_time_mins=`echo "$file_time_secs / 60" | bc`
        else
                cur_time_mins=`echo "$CurDT / 60" | bc`
        fi

        diffe=`echo "$cur_time_mins - $issue_time_mins" | bc`
        if [ $diffe -le $duration ]
        then
                echo $CurDT > /tmp/gateway_checked_time.txt
                echo "DOWN - Remote or Local Gateway on $DT."
                exit 2;
        fi
fi
done

