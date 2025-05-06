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
options=("Пункт1" "Пункт2" "Пункт3" "Пункт4" "Пункт5")
selected=0


# Функция для отображения меню
function display_menu() {
    clear
    color_echo 33 'Сборщик региона v.1.0 от 04.05.2025'
    for i in "${!options[@]}"; do
        if [ "$i" == "$selected" ]; then
            # Подсвечиваем выбранный пункт
            hor_centr 31 "  >>>   \033[43m${options[i]}\033[0m"  # Желтый фон
        else
            hor_centr 33 "${options[i]}"
        fi
    done
}

#Функция отображения таблицы с хостами
function table_viewer () {

awk -v FS=',' '
function draw_line(char_left, char_fill, char_sep,   i, line){
    line = char_left
    for(i=1; i<=nfields; i++) {
        line = line sprintf("%s", gensub(/./, char_fill, "g", sprintf("%" max[i] "s", "")))
        line = line char_sep
    }
    print line
}
{
    for (i=1; i<=NF; i++) {
        # Запоминаем длину самого длинного значения в столбце
        if (length($i) > max[i]) max[i] = length($i)
        # Сохраняем строки в массив для вывода позже
        data[NR,i] = $i
    }
    if (NF > nfields) nfields = NF
    nrows = NR
}
END {
    # Верхняя граница
    draw_line("+", "-", "+")
    
    # Вывод заголовка (строка 1)
    printf("| ")
    for (i=1; i<=nfields; i++) {
        # Подгоняем ячейку по ширине
        printf("%-*s|", max[i], data[1,i])
    }
    print ""
    
    # Разделитель после заголовка
    draw_line("+", "-", "+")
    
    # Остальные строки
    for(r=2; r<=nrows; r++) {
        printf("|")
        for(i=1; i<=nfields; i++) {
            printf("%-*s|", max[i], data[r,i])
        }
        print ""
    }
    
    # Нижняя граница
    draw_line("+", "-", "+")
}
' "$file"
}

# Основной цикл
while true; do
    display_menu
    table_viewer
    # Управление стрелками вверх и вниз
    read -rsn3 input
    case "$input" in
        $'\e[B') # Стрелка вниз
            ((selected++))
            if [ "$selected" -ge "${#options[@]}" ]; then
                selected=0
            fi
            ;;
        $'\e[A') # Стрелка вверх
            ((selected--))
            if [ "$selected" -lt 0 ]; then
                selected=$((${#options[@]} - 1))
            fi
            ;;
        $'\e[0~') # F1 (для примера)
            break
            ;;
        $'\e[1~') # Home (для примера)
            break
            ;;
        $'\e[3~') # Delete (для примера)
            break
            ;;
        *)
            break
            ;;
    esac

done
# Обработка выбора
    case "$selected" in
                0)
                ;;
                1)
                clear
                color_echo 33 "Проверка работы меню"
                sleep 5
                ;;
                2)
                clear
                color_echo 35 "Еще одна проверка"
                sleep 5
                ;;
                3)
                ;;
                5)
                ;;
    esac

# Вывод выбранного пункта
#echo "Выбран: ${options[selected]}"