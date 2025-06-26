awk -F',' -v OFS=',' '
NR==4 {$1="qazp04-rc1c1"; $10="qazp04-rc2c2"; $19="qazp04-rc3c3"}          # Проверка номера строки и изменение 4-го столбца
{print}                        # Вывод каждой строки
' output2.csv > temp.csv && mv temp.csv output3.csv