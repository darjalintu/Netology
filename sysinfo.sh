#!/bin/bash
while true; do
  timestamp=$(date "+%b %e %H:%M:%S")
  loadavg=$(cat /proc/loadavg | awk '{print $1, " ", $2, " ", $3}')
  memfree=$(free | awk 'NR==2 {print "Свободный объем ОЗУ:", $4}')
  memtotal=$(free | awk 'NR==2 {print "Общий объем ОЗУ:", $2}')
  diskfree=$(df -h / | awk 'NR==2 {print "Свободно:", $4}')
  disktotal=$(df -h / | awk 'NR==2 {print "Общий объем:", $2}')
  echo $timestamp $loadavg $memfree $memtotal $diskfree $disktotal >> sysinfo.log
  sleep 5
done
