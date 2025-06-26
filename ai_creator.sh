#!/bin/bash

color_echo() {
    echo -e "\e[$1m$2\e[0m"
}

file_new=$1

# Получаем регион, количество стоек и серверов
color_echo 32 "Введите название региона для сборки:"
read row_region
color_echo 32 "Введите количество серверных стоек для сборки региона:"
read row_rack
color_echo 32 "Введите количество серверов в каждой стойке:"
read row_pods

# Формируем шапку
header_row=",mgmt,serial,ip,pos,PwSt,Time,RDNA,Crs"
columns_per_rack=9
total_columns=$(( columns_per_rack * row_rack ))

# Создаем пустые строки для каждого сервера
for rack_num in $(seq -w 1 $row_rack); do
    rack_header="rack${rack_num}${header_row},"
    for pod_num in $(seq -w 1 $row_pods); do
        #hostname="${row_region}-rc0${rack_num}p${}"
        hostname=$(printf "%s-rc0%sp%02d" "$row_region" "$pod_num" "$((10#$pod_num))")
        mgmt_ip="192.168.100.$(( ($rack_num - 1) * row_pods + pod_num ))"
        serial_number="ABC01020X$(( ($rack_num - 1) * row_pods + pod_num ))"
        os_ip="10.100.100.$(( ($rack_num - 1) * row_pods + pod_num ))"
        
        # Заполняем строку согласно структуре
        line="${hostname},${mgmt_ip},${serial_number},${os_ip},,,,,"
        echo "$line" >> "$file_new"
    done
done

# Добавляем первую строку с названиями стоек и полей
sed -i "1i${rack_header}" "$file_new"

# Подготовка списка индексов для последующего редактирования
indices=($(seq 1 $(( total_columns / columns_per_rack)) | xargs -I {} seq -w 1 $columns_per_rack))

# Обновление первой строки согласно правилам
awk -F ',' -v OFS=',' -v region="$row_region" '
    BEGIN {
        split("'"${indices[*]}"'", col_indices);
    }
    NR==1 {
        # Изменяем имена первых трёх ячеек
        $col_indices[1]="'$row_region'-rc1c1";
        $col_indices[2]="'$row_region'-rc2c2";
        $col_indices[3]="'$row_region'-rc3c3";
    }
    { print }
' "$file_new" > temp.csv && mv temp.csv "$file_new"

# Очищаем временные файлы
rm -f temp.*

color_echo 32 "Файл успешно обработан."
