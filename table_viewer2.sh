#!/bin/bash

#Определяем файл .csv
file=$1
column_to_view=`awk 'NR==2' $file`
# Определяем разделитель (запятая) .csv файла
FS=','

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

# Массив с опциями меню

selected=0

artifact=`awk -v FS="," 'NR==1{gsub(/^ +| +$/, "");print $2}' $file`
if [[ "$artifact" == "1" ]]; then
options=("Пункт11" "Пункт12" "Print input file13" "Пункт14" "Power_on15" "Выход")
elif [[ "$artifact" == "2" ]]; then
options=("Пункт21" "Пункт22" "Print input file23" "Пункт24" "Power_on25" "Выход")
else echo "Хрен пойми что!$artifact"
fi
selected=0

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
        dynamic_array+=("off")  
        hor_centr 31 "$mgmt Power Off" 
        
        sleep 1
        ((count++))
    else
        #awk -F',' 'NR>3{ if($6 == "off") $6 = "on"; print }' OFS=',' $file >> output.csv
        dynamic_array+=("on")
        hor_centr 31 "$mgmt Power on"
        sleep 1
        ((count++))
    fi
done

echo "Массив обработанных данных ${dynamic_array[@]}"
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
        printf("| ")
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

# while :; do
#     display_menu
#     table_viewer $file $column_to_view

#     # Управление стрелками вверх и вниз
#     read -rsn3 input
#     case "$input" in
#         $'\e[B') # Стрелка вниз
#             ((selected++))
#             if [ "$selected" -ge "${#options[@]}" ]; then
#                 selected=0
#             fi
#             continue
#             ;;
#         $'\e[A') # Стрелка вверх
#             ((selected--))
#             if [ "$selected" -lt 0 ]; then
#                 selected=$((${#options[@]} - 1))
#             fi
#             continue
#             ;;
#         $'\n') # F1 (для примера)
#         clear
#         hor_centr 32 "Переключаю меню..."
#         sleep 1
#         awk -i inplace -v FS="," -v OFS="," 'NR==1{$2="2"} {print}' host_data2.csv
#             break
#             ;;
#         #  $'\e[1~') # Home (для примера)
#         # awk -i inplace -v FS="," -v OFS="," 'NR==1{gsub(/^ +| +$/, "");{$2="2"} {print}' $file
#         #      break
#         #      ;;
#         $'\e[9') # Tab
#             clear
#             color_echo 32 "Вы нажали Tab. Выполняется действие..."
#             sleep 2
#             clear
#     esac

# Основной цикл
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
                        selected=$((${#options[@]} - 1))
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



# Вывод выбранного пункта
#echo "Выбран: ${options[selected]}"