#!/bin/bash

#Определяем файл .csv
file=$1

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
options=("Пункт1" "Пункт2" "Print input file" "Пункт4" "Power_on" "Выход")
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
}

function power_on() {
    count=0
for mgmt in $(cut -c 9-17 "$file")
do
    if [ $count -gt 1 ]; then
        if [ $count -lt 10 ]; then
        echo $mgmt
        sleep 1
        ((count++))
        else 
        ((count++))
        fi
    else 
        ((count++))
    fi
done
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
function table_viewer () {
    local columns_to_display=("$@") # Массив с номерами столбцов
    local nfields=${#columns_to_display[@]} # Получаем количество переданных столбцов

    awk -v FS=',' -v nfields="$nfields" -v columns_to_display="$(printf "%s " "${columns_to_display[@]}")" '
    function draw_line(char_left, char_fill, char_sep, i, line) {
        line = char_left
        for(i=1; i<=nfields; i++) {
            line = line sprintf("%s", gensub(/./, char_fill, "g", sprintf("%" max[i] "s", "")))
            line = line char_sep
        }
        print line
    }
    
    {
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
        
        printf("|")
        for (i=1; i<=nfields; i++) {
            printf("%-*s|", max[i], data[1,i])
        }
        print ""
        
        draw_line("+", "-", "+")
        
        for(r=2; r<=nrows; r++) {
            printf("|")
            for(i=1; i<=nfields; i++) {
                printf("%-*s|", max[i], data[r,i])
            }
            print ""
        }
        
        draw_line("+", "-", "+")
    }
    ' "$file"
}

while :; do
    display_menu
    table_viewer 1 2 3 4 10 11 12 13

    # Управление стрелками вверх и вниз
    read -rsn3 input
    case "$input" in
        $'\e[B') # Стрелка вниз
            ((selected++))
            if [ "$selected" -ge "${#options[@]}" ]; then
                selected=0
            fi
            continue
            ;;
        $'\e[A') # Стрелка вверх
            ((selected--))
            if [ "$selected" -lt 0 ]; then
                selected=$((${#options[@]} - 1))
            fi
            continue
            ;;
        $'\n') # F1 (для примера)
            break
            ;;
        # $'\e[1~') # Home (для примера)
        #     break
        #     ;;
        # $'\e[3~') # Delete (для примера)
        #     break
        #     ;;
       
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