#!/bin/bash

#Определяем разделитель (запятая) .csv файла


function color_echo() {
    echo -e "\e[$1m$2\e[0m"
}

function hor_centr() {
    text_color=$1
    text=$(color_echo $text_color "$2")
    width=$(tput cols)
    text_length=${#text}
    empty_space=$(( (width - text_length) / 2 ))
    printf "%${empty_space}s%s\n" "" "$text"
}

# Функция для отображения меню
function display_menu() {
    clear
    color_echo 33 'Сборщик региона v.1.2 от 04.05.2025'
    for i in "${!options[@]}"; do
        if [ "$i" == "$selected" ]; then
            # Подсвечиваем выбранный пункт
            hor_centr 31 "  >>>   \033[43m${options[i]}\033[0m"  # Желтый фон
        else
            hor_centr 33 "${options[i]}"
        fi
    done
    color_echo 33 'Для переключения режима меню нажмите Home'
}

function power_on() {
    count=0
    dynamic_array=()  
   
   for mgmt in $(awk -v FS="," 'NR>3 {print $1}' $file)
do
    if [[ $RANDOM -gt 16386 ]]
    then
        #awk -F',' 'NR>3{ if($6 == "on") $6 = "off"; print }' OFS=',' $file >> output.csv
        dynamic_array+=("Off")  
        hor_centr 31 "$mgmt Power Off" 
        
        sleep 1
        ((count++))
    else
        #awk -F',' 'NR>3{ if($6 == "off") $6 = "on"; print }' OFS=',' $file >> output.csv
        dynamic_array+=("On")
        hor_centr 31 "$mgmt Power On"
        sleep 1
        ((count++))
    fi
done

echo "Массив обработанных данных ${dynamic_array[@]}"
awk -i inplace -va="$(echo "${dynamic_array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")} NR<4{print $0} NR>3{ $6 = b[NR-3]; print }' $file
}

function handle_selection() {
    case "$selected" in
        0)
            clear
            color_echo 33 "Проверка работы меню"
            sleep 2
            ;;
        1)
            clear
            color_echo 35 "Еще одна проверка"
            sleep 2
            ;;
        2)
            hor_centr 32 "$file"
            power_on "$file"
            hor_centr 32 "Нажмите любую клавишу для продолжения"
            read -n 1 -s
            ;;
        3)
            hor_centr 32 "Пункт работает"
            # Логика обработки пункта 3 здесь
            ;;
        4)
            # clear
            # hor_centr 32 "$file"
            power_on "$file"
             hor_centr 32 "Нажмите любую клавишу для продолжения"
            read -n 1 -s
            ;;
        5)
            clear
            hor_centr 31 "Пока!"
            sleep 1
            ;;
    esac
}

#Функция отображения таблицы с хостами
function table_viewer() {
    local file="$1"  # Имя CSV файла
    shift # Убираем имя файла из аргументов
    local columns_to_display=("$@") # Массив с номерами столбцов
    local nfields=${#columns_to_display[@]} # Получаем количество переданных столбцов

    # Создаем строку для передачи номеров колонок
    local columns_str=$(printf "%s " "${columns_to_display[@]}")

    awk -v FS=',' -v nfields="$nfields" -v columns_to_display="$columns_str" '
    function draw_line(char_left, char_fill, char_sep) {
        line = char_left
        for (i=1; i<=nfields; i++) {
            line = line sprintf("%s", gensub(/./, char_fill, "g", sprintf("%" max[i] "s", "")))
            line = line char_sep
        }
        print line
    }
    
    # Считаем строки и запоминаем заголовок
    NR == 3 {
        title = $0  # Сохраняем заголовок из третьей строки
        split(title, header, FS);
        split(columns_to_display, cols_arr, " ")
        for (i=1; i<=nfields; i++) {
            col = cols_arr[i]
            if (col > 0 && col <= NF) {
                # Печатаем заголовок
                max[i] = length(header[col])
            }
        }
    }

    NR > 3 { 
        split(columns_to_display, cols_arr, " ")
        for (i=1; i<=nfields; i++) {
            col = cols_arr[i]
            selected_cols[i] = $col
            
            # Запоминаем длину самого длинного значения в выбранных столбцах
            if (length(selected_cols[i]) > max[i]) max[i] = length(selected_cols[i])
            # Сохраняем строки в массив для вывода позже
            data[NR,i] = selected_cols[i]
        }
        nrows = NR
    }
    
    END {
        draw_line("+", "-", "+")
        
        # Печатаем заголовок
        printf("|")
        for (i=1; i<=nfields; i++) {
            col = cols_arr[i]
            printf("%-*s|", max[i], header[col])
        }
        print ""
        
        draw_line("+", "-", "+")
        
        # Печатаем содержимое
        for (r=4; r<=nrows; r++) {
            printf("|")
            for (i=1; i<=nfields; i++) {
                printf("%-*s|", max[i], data[r,i])
            }
            print ""
        }
        
        draw_line("+", "-", "+")
    }
    ' "$file"
}

FS=','
selected=0
file=host_data.csv
while [ ! -f "$file" ]; do
echo "Файл не найден. Давайте созданим его в ручном режиме (y/n)?";
read anser
if [[ "$anser" == "y" ]]; then
color_echo 32 "Напишите название региона для сборки:"; read row_region
color_echo 32 "Напишите количество серверных стоек для сборки региона:"; read row_rack
color_echo 32 "Напишите количество серверов в стойке:"; read row_pods
echo "$row_region,1" > $file
echo "1 2 4 6 10 11 13 15" >> $file
echo "rack1,mgmt,serial,ip,pos,PwSt,Time,RDNA,Crs,rack2,mgmt,serial,ip,pos,PwSt,Time,RDNA,Crs" >> $file

host_array=()  
for r in  $(seq -w 1 $row_rack); do
#color_echo 33 "Rack $r"
    for p in $(seq -w 1 $row_pods); do 
    host_array+=`printf "%s-sb%sp%s\n" "$row_region" "$r" "$p"`
    done
    echo "Массив созданных имен хостов ${host_array[@]}"
    sleep 2
done

else color_echo 33 "Без файла входных данных .csv програма не сможет работать!!!"
break
fi
done
# Основной цикл
while [ -f "$file" ]; do
    artifact=`awk -v FS="," 'NR==1{gsub(/^ +| +$/, "");print $2}' $file`
    if [[ "$artifact" == "1" ]]; then
    options=("Пункт11" "Пункт12" "Print input file13" "Пункт14" "Power_on15" "Выход")
    elif [[ "$artifact" == "2" ]]; then
    options=("Пункт21" "Пункт22" "Print input file23" "Пункт24" "Power_on25" "Выход")
    else echo "Параметр отображения меню выставлен некорректно: $artifact. Аварийное завершение програмы" ; sleep 2; break
    fi
    column_to_view=`awk 'NR==2' $file`

    
    while :; do
        display_menu
        table_viewer $file $column_to_view

    # Считываем ввод
    read -rsn1 input

        # Обработка одиночных нажатий
        case "$input" in
            $'\e') # Если нажата клавиша Escape
                read -rsn2 input
                case "$input" in
                    '[B') # Стрелка вниз
                        ((selected++))
                        if [ "$selected" -ge "${#options[@]}" ]; then
                        selected=0
                        fi
                        continue
                        ;;
                    '[A') # Стрелка вверх
                        ((selected--))
                        if [ "$selected" -lt 0 ]; then
                            selected=${#options[@]}
                        fi
                        continue
                        ;;
                    *) # Обработка других клавиш после Escape
                        continue
                        ;;
                esac
                ;;
            $'\t') # Tab
                clear
                color_echo 32 "Вы нажали Tab. Выполняется действие..."
                sleep 2
                clear
                continue
                ;;
            # Другие клавиши
            \n) 
                # Выход по неназначенной клавише
                break
                ;;
        esac

    # Обработка выбора после навигации
    handle_selection
    if [[ $selected == 5 ]]; then
    clear
    return
    fi
done
    
done