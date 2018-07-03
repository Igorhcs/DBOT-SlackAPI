 #!/bin/bash

DATE=`/bin/date +%Y%m%d`
today=$(date +%m.%d.%y)
SDIR='/gdbr/Autocard/' #dir where script resides
FDIR='/nwsbr/hc/cgi-bin/data/tivoli' #leave this way
LOGDIR=$SDIR'logs' #dir for output files
SPLIT1=$SDIR'clanI' #file containing accounts for clanI
SPLIT2=$SDIR'clanII' #file containing accounts for clanII
echo "" > /home/igorhcs/worksacp/autolist
function mainfunction () {
for customer in `cat $1`
do
file=$(ls -Art $FDIR/$customer/ |tail -n 1)
cat $FDIR/$customer/$file |grep -E '@NO@' |awk -F@ '{print $1}' > /tmp/agents
qty=$(cat /tmp/agents |wc -l)
                total=$(cat $FDIR/$customer/$file |wc -l)
                echo ===$customer=== >> $LOGDIR/output.$userin$DATE
                hc=$(echo "scale=30;(1 - ($qty/$total)) * 100" |bc |xargs printf "%.2f\n") >> $LOGDIR/output.$userin$DATE
                echo "$customer -> $hc%" >> $LOGDIR/output.$userin$DATE
                        if [ "$file" == "hc.$today.txt" ]
                        then
                        echo "Autocard $3 UPDATED -> SMAT file is from today" > /tmp/autocardMsg
                        else
                        echo "Autocard $3 OUTDATED -> Do not create Card based on this output." > /tmp/autocardMsg
                        fi
 		AGENTS=`cat /tmp/agents`
		if [ -n "$AGENTS" ];then
			echo >> /home/igorhcs/worksacp/autolist
               		echo "$customer" >> /home/igorhcs/worksacp/autolist
               		echo "======" >> /home/igorhcs/worksacp/autolist
               		cat /tmp/agents >> /home/igorhcs/worksacp/autolist
		fi 
        done
}

mainfunction $SPLIT1 $listmail1 "ClanI"
mainfunction $SPLIT2 $listmail2 "ClanII"

