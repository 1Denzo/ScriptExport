#!/bin/bash

array=("key1" "key2" "key3" "key4" "key5" "key6" "key7" "key8" "key9" "key10" "key11" "key12" "key13" "key14" "key15" "key16" "key17" "key18" "key19" "key20")
awk  -va="$(echo "${array[@]}")" 'BEGIN{OFS=FS=","; split(a,b," ")}NR<4{print $0} NR>3{print $0,b[NR-3]}' simple.csv > output2.csv