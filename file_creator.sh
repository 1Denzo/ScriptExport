#!/bin/bash

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
arr=(1 2 4 6)
column_index_arr=()

# Начинаем с добавления первого базового массива
column_index_arr+=("${arr[@]}")

for ((i = 1; i <= (( $row_rack -1 )); i++)); do
    temp=() # Временный массив для хранения новых элементов
    for num in "${arr[@]}"; do
        temp+=($((num + 9 * i))) # Вычисляем новые элементы
    done
    column_index_arr+=("${temp[@]}") # Правильно добавляем элементы в общий массив
done

# Выводим итоговый массив
echo "${column_index_arr[@]}"
for r in  $(seq -w 1 $row_rack); do
rack="rack$r"
name_string="$name_string$rack$name_str,"
    for p in $(seq -w 1 $row_pods); do 
    echo ",,,,,,,," >> $file_new
    (( counter++ ))
    # if (( $p == 1 && $r <= 3)); then
    # host_array+=$(printf "%s-rc%sc%s " "$row_region" "$r" "$r")
    # os_ip_array+=`printf "10.100.200.%s " "$counter"`
    # else
    host_array+=$(printf "%s-rc0%sp%02d " "$row_region" "$r" "$((10#$p))")
    os_ip_array+=`printf "10.100.100.%s " "$counter"`
    # fi
    bmc_array+=`printf "192.168.100.%s " "$counter"`
    serial_array+=`printf "ABC01020X%s " "$counter"`
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

column_index_str="${column_index_arr[@]}"
awk -v ORS='\n' -v FS=';' -v csv_name="$name_string" -v region="$row_region,1" -v column_index_str="$column_index_str" '
BEGIN {
    print region;
    n = split(column_index_str, cols, " ");  # Преобразование строки в массив
    for(i=1; i<=n; i++) printf("%d%s", cols[i], (i<n ? " ":"\n"));  # Корректный вывод
    print csv_name
}
{
    print
}' output2.csv > temp_file && mv temp_file output2.csv

awk -F ',' -v OFS=',' -v region="$row_region" "
    NR==4 {
        \$1 = region \"-rc1c1\";
        \$10= region \"-rc2c2\";
        \$19= region \"-rc3c3\";
    }
    { print }
" output2.csv > temp.csv && mv temp.csv output3.csv
