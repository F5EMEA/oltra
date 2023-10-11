useragent=/home/ubuntu/useragent.txt
ip=/home/ubuntu/bots.txt
fqdn=/home/ubuntu/fqdn.txt
url=/home/ubuntu/urls.txt
parameters=/home/ubuntu/parameters.txt
attacks=/home/ubuntu/attacks.txt
count=$1
sleeptime=$2


for i in `seq $count` ; do
	sleep $sleeptime
	fqdn_temp=`shuf -n 1 $fqdn` 
	url_temp=`shuf -n 1 $url` 
	#status_code=$(curl --write-out %{http_code} --silent --output /dev/null -H "X-Forwarded-For: `shuf -n 1 $ip`" -H "UserAgent=`shuf -n 1 $useragent`" "http://`shuf -n 1 $fqdn``shuf -n 1 $urls`?`shuf -n 1 $parameters`=`shuf -n 1 $attacks`")
	status_code=$(curl --write-out %{http_code} --silent --output /dev/null -H "X-Forwarded-For: `shuf -n 1 $ip`" -H "User-Agent:`shuf -n 1 $useragent`" "http://$fqdn_temp$url_temp?`shuf -n 1 $parameters`=`shuf -n 1 $attacks`")
	echo "Launching transaction -> $(tput setaf 6)[$i]$(tput sgr0) -> Response from $fqdn_temp$url_temp is $(tput setaf 3)$status_code" $(tput sgr0)

done



