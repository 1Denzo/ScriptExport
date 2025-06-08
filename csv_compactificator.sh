BEGIN { FS="," }
{
    key = substr($1, length($1)-1)
    arr[key] = arr[key] ? arr[key] "," $0 : $0
}
END {
    for(i in arr) print arr[i]
}