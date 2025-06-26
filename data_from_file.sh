#!/bin/bash

# echo "создание файла имен хостов, заполните файл (sfift+insert), для выхода нажмите (esc shift+zz)"
# sleep 2
# vim host_name
# echo "создание файла ip адресов управляющих интерфейсов, заполните файл (sfift+insert), для выхода нажмите (esc shift+zz)"
# sleep 2
# vim host_BMC
# echo "создание файла c серийными номерами серверов, заполните файл (sfift+insert), для выхода нажмите (esc shift+zz)"
# sleep 2
# vim host_serial
# echo "создание файла c местоположением серверов, заполните файл (sfift+insert), для выхода нажмите (esc shift+zz)"
# sleep 2
# vim host_place
paste -d ',' host_name host_BMC host_serial host_place > result.csv
# file=$1
awk '
{
    lines[NR]=$0
}
END {
    print lines[1]
    for(i=4;i<=22;i++) {print lines[i]}
    print lines[2]                    
    for(i=23;i<=41;i++) {print lines[i]}
    print lines[3]                   
    for(i=42;i<=NR;i++) {print lines[i]}
}' result.csv > file_manip.csv