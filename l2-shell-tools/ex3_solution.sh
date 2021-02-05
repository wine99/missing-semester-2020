#!/usr/bin/env bash

./ex3_problem.sh > ex3_result.txt 2> ex3_result.txt
state=$?
count=0

while [[ state -eq 0 ]]; do
    ./ex3_problem.sh >> ex3_result.txt 2>> ex3_result.txt
    state=$?
    count=$((count + 1))
done

cat ex3_result.txt
echo "ex3_problem ran $count times before failure"
