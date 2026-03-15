#!/bin/bash
alert=0

if tail -n 24 sysinfo.log | awk '$4 >= 1 {alertfound = 1; exit} END {exit !alertfound}'; then
  echo "Зафиксировано в течении последних 2 минут, что loadavg1 > 1"
  alert=1
fi

if tail -n 36 sysinfo.log | awk '($5 / $6) >= 0.6 {alertfound = 1; exit} END {exit !alertfound}'; then
  echo "Зафиксировано в течении последних 3 минут, что использовано > 60% объема оперативной памяти"
  alert=1
fi

if tail -n 60 sysinfo.log | awk '($7 / $8) >= 0.6 {alertfound = 1; exit} END {exit !alertfound}'; then
  echo "Зафиксировано в течении последних 5 минут, что что использовано > 60% объема диска"
  alert=1
fi

if [[ $alert -eq 0 ]]; then
exit 0
else
exit 1
fi
