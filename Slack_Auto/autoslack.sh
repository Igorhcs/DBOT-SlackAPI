#!/bin/bash

###########
# @Description 
# @script:      autoslack.sh 
# @author:      Igor Henrique de Castro 
# @mail:        igorhcs@br.ibm.com
# @Version: 	1.2 
###########

tamp=$(date +%s)
echo "" > accounts
today=$(date +%m.%d.%y)
day=$(date +%d/%m/%y)
SDIR='/gdbr/Autocard/' #dir where script resides
FDIR='/nwsbr/hc/cgi-bin/data/tivoli' #leave this way
SPLIT1=$SDIR'clanI' #file containing accounts for clanI
SPLIT2=$SDIR'clanII' #file containing accounts for clanII
cat $SPLIT1>MEUARQUIVO1
cat $SPLIT2>MEUARQUIVO2
function mainfunction () {
	echo $2 >> accounts
	for customer in `cat $1`
	do
	file=$(ls -Art $FDIR/$customer/ |tail -n 1)
	cat $FDIR/$customer/$file |grep -E '@NO@' |awk -F@ '{print $1}' > /tmp/agents
	qty=$(cat /tmp/agents |wc -l)
	total=$(cat $FDIR/$customer/$file |wc -l)
	hc=$(echo "scale=30;(1 - ($qty/$total)) * 100" |bc |xargs printf "%.2f\n")
		if [ "$hc" != "100.00" ] 
then
		cus=`echo $customer | cut -d_ -f1`
		echo  "$cus $hc%" >> accounts
		fi
	done
}

mainfunction $SPLIT1 "Clan I"
mainfunction $SPLIT2 "Clan II"

message=`cat accounts` 
curl -X POST -H 'Content-type: application/json' --data '{"attachments": [{"fallback": "Contas HC.","color": "#00ccff","pretext":"'"Ola Pessoal,Contas a serem trabalhadas ${day}"'","title": "Contas HC","title_link": "https://autoportalgd.br.ibm.com/HCTemplate/index.php#","text": "'"${message}"'","fields": [{"title": "Priority","value": "Coming Soon!","short": false}],"ts": "'"${tamp}"'" },{"fallback": "Tools","title": "", "callback_id": "comic_1234_xyz","color": "#00ff99","attachment_type": "default","actions": [{"name": "SMAT","text": "SMAT","type": "button","value": "SMAT","url" : "https://autoportalgd.br.ibm.com/smat/home.php" },{"name": "HC","text": "HC - Template","type": "button","value": "HC","url" : "https://autoportalgd.br.ibm.com/HCTemplate/index.php"}]}]}' (HTTP Incoming Webhooks)

curl -F file=@/home/igorhcs/worksacp/autolist -F channels=<Channel>,#<Channel> -F token=<TOKEN> <SLACK API> https://slack.com/api/
