#!/bin/bash
rep_file="rep.log"
rm -f "$rep_file"
touch "$rep_file"

echo "=====================================================" >> "$rep_file"
printf "| %-35s | %-10s |\n" "PAT_NAME" "STATUS" >> "$rep_file"
echo "=====================================================" >> "$rep_file"

while IFS= read -r pat || [ -n "$pat" ]; do
    pat=$(echo "$pat" | tr -d '\r')
    [[ -z "$pat" || "$pat" =~ ^// ]] && continue

    sim_log="log/${pat}.log"
    res="NO_LOG"

    if [ -f "$sim_log" ]; then
        is_pass=$(grep -c "TEST RESULT: PASSED" "$sim_log")
        is_fail=$(grep -c "TEST RESULT: FAILED" "$sim_log")

        if [ "$is_pass" -gt 0 ]; then
            res="PASSED"
        elif [ "$is_fail" -gt 0 ]; then
            res="FAILED"
        else
            res="INCOMPLETE"
        fi
    fi

    printf "| %-35s | %-10s |\n" "$pat" "$res" >> "$rep_file"
done < pat.list

echo "=====================================================" >> "$rep_file"
cat "$rep_file"
