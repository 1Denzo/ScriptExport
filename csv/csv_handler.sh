count=0
for i in $(cat simple.csv)
do
    if [ $count -gt 0 ]; then
    sed -i "$count s/on/off/1" simple.csv
    ((count++))
    else 
    ((count++))
    fi
done