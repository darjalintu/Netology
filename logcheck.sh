#!/bin/bash
alertloadavg1=$(tail -n 24 sysinfo.log | awk '{if ($4 > 1) {print 1; exit}} END {print 0}')
alertmem=$(tail -n 36 sysinfo.log | awk '{mem = ($5 / $6) * 100; if (mem < 60) {print 1; exit}} END {print 0}')
alertdisk=$(tail -n 60 sysinfo.log | awk '{disk = ($7 / $8) * 100; if (disk < 60) {print 1; exit}} END {print 0}')
alert=0

if [[ $alertloadavg1 -eq 1 ]]; then
  alert=1
  echo "Зафиксировано в течении последних 2 минут, что loadavg1 > 1"
fi

if [[ $alertmem -eq 1 ]]; then
  alert=1
  echo "Зафиксировано в течении последних 3 минут, что свободный объем оперативной памяти < 60%"
fi

if [[ $alertdisk -eq 1 ]]; then
  alert=1
  echo "Зафиксировано в течении последних 5 минут, что свободный объем на диске < 60%"
fi

if [[ $alert -eq 0 ]]; then
exit 0
else
exit 1
fi
