#!/bin/bash
alertloadavg1=$(tail -n 24 sysinfo.log | awk 'if ($4 > 1) print $4 exit}')
alertmem=$(tail -n 36 sysinfo.log | awk '{mem=($5/$6)*100} END {print mem}')
alertdisk=$(tail -n 60 sysinfo.log | awk '{disk=($7/$8)*100} END {print disk}')

if [[ $alertloadavg1 < 1 ]]; then
exit 0
else
echo "Зафиксировано в течении последних 2 минут, что loadavg1 > 1"
exit 1
fi

if [[ $alertmem >= 60 ]]; then
exit 0
else
echo "Зафиксировано в течении последних 3 минут, что свободный объем оперативной памяти < 60%"
exit 1
fi

if [[ $alertdisk >= 60 ]]; then
exit 0
else
echo "Зафиксировано в течении последних 5 минут, что свободный объем на диске < 60%"
exit 1
fi
