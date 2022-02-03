#!/bin/bash
# Expects 2 arguments
# 1 file path
# 2 Duration
echo $1
echo $2
if [ $# -ne 2 ]
then
echo "Incorrect number of arguments."
echo "Arguments should be file path and periodic duraton in minutes."
echo "Eg: /opt/nagios-plugins/check_sap_gateway.sh /usr/sap/<SID>/DVELog/work <Number of minutes>"
exit
fi
duration=$2
#Data=`grep -B 1 "gateway down" ./work/dev_w3.old | grep -v "gateway down" | awk '{$1=""; print $0}' | sed 's/^\ //g'`
#Data=`grep -B 1 "gateway down" ./work/dev_w* | grep -v "gateway down" | awk '{$1=""; print $0}' | sed 's/^\ //g'`
Data=`grep -B 1 "gateway down" $1 | grep -v "gateway down" | awk '{$1=""; print $0}' | sed 's/^\ //g'`
echo Error occured on $Data
# validate date
#date -d "$Data"  2>: 1>:; echo $?
echo "$Data" |
while IFS= read -r DT
do
date -d "$DT"  2>: 1>:; isdate=$?

if [ $isdate -eq 0 ]
then
#       echo "Processing $DT"
        issue_time_secs=`date -d "$DT" +%s`
#       echo "Issue time secornds: "$issue_time_secs
        issue_time_mins=`echo "$issue_time_secs / 60" | bc`
#       echo "Issue time minutes: " $issue_time_mins

#       CurDTa=`date`
#       echo "$CurDTa"
        CurDT=`date +%s`
#       echo $CurDT
#       > /tmp/gateway_checked_time.txt
        if [ -s /tmp/gateway_checked_time.txt ]
        then
                file_time_secs=`cat /tmp/gateway_checked_time.txt`
                cur_time_mins=`echo "$file_time_secs / 60" | bc`
#               echo "File exits"
        else
                cur_time_mins=`echo "$CurDT / 60" | bc`
#               echo "File does not exits"
        fi

        diffe=`echo "$cur_time_mins - $issue_time_mins" | bc`
        echo Diff $diffe

        if [ $diffe -le $duration ]
        then
                echo $CurDT > /tmp/gateway_checked_time.txt
#               echo $DT
                echo "DOWN - Remote or Local Gateway in last $duration minutes."
                exit 2;
        fi
fi
done
