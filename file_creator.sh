#!/bin/bash

# while [ ! -f "$file_new" ]; do
# echo "Файл не найден. Давайте созданим его в ручном режиме (y/n)?";
# read anser
# if [[ "$anser" == "y" ]]; then
# color_echo 32 "Напишите название региона для сборки:"; read row_region
# color_echo 32 "Напишите количество серверных стоек для сборки региона:"; read row_rack
# color_echo 32 "Напишите количество серверов в стойке:"; read row_pods
# # echo "$row_region,1" > $file_new
# # echo "1 2 4 6" >> $file_new
# echo "rack1,mgmt,serial,ip,pos,PwSt,Time,RDNA,Crs" >> $file_new

# host_array=()  
# for r in  $(seq -w 1 $row_rack); do
# color_echo 33 "Rack $r"
#     for p in $(seq -w 1 $row_pods); do 
#     echo ",,,,,,,,," >> $file_new
#     host_array+=`printf "%s-rc%02dp%02d " "$row_region" "$r" "$p"`
#     done    
# done
# echo "Массив созданных имен хостов ${host_array[@]}"
#     hor_centr 32 "Нажмите любую клавишу для продолжения"
#     read -n 1 -s
# awk -i inplace -va="$(echo "${host_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} NR>1{ $1 = b[NR-1]; print }' $file_new

# else color_echo 33 "Без файла входных данных .csv програма не сможет работать!!!"
# break
# fi
# done

color_echo() {
    echo -e "\e[$1m$2\e[0m"
}

file_new=$1

color_echo 32 "Напишите название региона для сборки:"; read row_region
color_echo 32 "Напишите количество серверных стоек для сборки региона:"; read row_rack
color_echo 32 "Напишите количество серверов в стойке:"; read row_pods
host_array=()
bmc_array=()
serial_array=()
os_ip_array=()
counter=0
name_str=",mgmt,serial,ip,pos,PwSt,Time,RDNA,Crs"
name_string=""
for r in  $(seq -w 1 $row_rack); do
rack="rack$r"
color_echo 33 "$rack"
name_string=",$name_string$rack$name_str"
    for p in $(seq -w 1 $row_pods); do 
    echo ",,,,,,,,," >> $file_new
    (( counter++ ))
    
    host_array+=`printf "%s-rc%02dp%02d " "$row_region" "$r" "$p"`
    bmc_array+=`printf "192.168.100.%s " "$counter"`
    serial_array+=`printf "ABC01020X%s " "$counter"`
    os_ip_array+=`printf "10.100.100.%s " "$counter"`
    done    
done
echo $name_string
echo "Массив созданных имен хостов ${host_array[@]}"
echo "Массив созданных адресов управляющих интерфейсов ${bmc_array[@]}"
echo "Массив созданных серийных номеров хостов ${serial_array[@]}"
echo "Массив созданных адресов операционных систем ${os_ip_array[@]}"

    color_echo 32 "Нажмите любую клавишу для продолжения"
    read -n 1 -s
awk -i inplace -va="$(echo "${host_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} { $1 = b[NR]; print }' $file_new
awk -i inplace -va="$(echo "${bmc_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} { $2 = b[NR]; print }' $file_new
awk -i inplace -va="$(echo "${serial_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} { $3 = b[NR]; print }' $file_new
awk -i inplace -va="$(echo "${os_ip_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} { $4 = b[NR]; print }' $file_new
awk -v FS="," '{
    key = substr($1, length($1)-1)
    arr[key] = arr[key] ? arr[key] "," $0 : $0
}
END {
    for(i in arr) print arr[i]
}' $file_new > output.csv
sort -k1 output.csv > output2.csv
rm -rf output.csv
awk -i inplace -v csv_name="$name_string" 'BEGIN {print csv_name } {print}' output2.csv
