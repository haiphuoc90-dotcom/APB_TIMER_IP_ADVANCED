#!/bin/bash
mkdir -p log

while IFS= read -r pat || [ -n "$pat" ]; do
    pat=$(echo "$pat" | tr -d '\r')
    [[ -z "$pat" || "$pat" =~ ^// ]] && continue

    echo "====================================================="
    echo "=== Running testcase: $pat ==="
    echo "====================================================="

    if [ -f "../testcases/${pat}.v" ]; then
        cp -f "../testcases/${pat}.v" ./run_test.v
    elif [ -f "../test_case/${pat}.v" ]; then
        cp -f "../test_case/${pat}.v" ./run_test.v
    else
        echo "[ERROR]: Cannot find testcase file for $pat"
        continue
    fi

    echo "--- COMPILING TESTCASE: $pat ---"
    iverilog -g2012 -I ../rtl -I ../tb -I . -o sim.vvp -f compile.f | tee compile.log

    if [ $? -eq 0 ]; then
        echo "--- RUNNING SIMULATION: $pat ---"
        vvp sim.vvp | tee "log/${pat}.log"
    else
        echo "[ERROR]: Compilation failed for $pat"
    fi
done < pat.list
