#!/bin/bash

SOLVER="./minisat_core"
FOLDER="sgen"
INSTANCE_DIR="../../../Shatter_Linux_v03/$FOLDER"
TIMEOUT=3600  # 1 hour

# Create results folder in same directory as this script
OUTPUT_FOLDER="results/regresults-${FOLDER##*/}"
SUMMARY_FILE="$OUTPUT_FOLDER/summary.csv"
mkdir -p "$OUTPUT_FOLDER"

# Header for CSV
echo "File,Result,CPU_Time(s),Timeout" > "$SUMMARY_FILE"

for FILE in "$INSTANCE_DIR"/*.cnf; do
    # Skip generated files
    if [[ "$FILE" == *.Sym.cnf || "$FILE" == *.SymOnly.cnf ]]; then
        echo "Skipping generated file: $(basename "$FILE")"
        continue
    fi

    BASENAME=$(basename "$FILE" .cnf)
    LOGFILE="$OUTPUT_FOLDER/$BASENAME.log"
    OUTFILE="$OUTPUT_FOLDER/$BASENAME.out"

    echo "Running $BASENAME..."

    /usr/bin/timeout "$TIMEOUT" "$SOLVER" -recalc "$FILE" > "$OUTFILE" 2> "$LOGFILE"
    EXIT_CODE=$?

    # Default values
    RESULT="UNKNOWN"
    TIME="N/A"
    TIMEOUT_FLAG="No"

    if [ $EXIT_CODE -eq 124 ]; then
        echo "Timeout after ${TIMEOUT}s" >> "$LOGFILE"
        TIMEOUT_FLAG="Yes"
    else
        # Try to extract SAT/UNSAT
        RESULT_LINE=$(grep -E "SATISFIABLE|UNSATISFIABLE" "$OUTFILE")
        if [ ! -z "$RESULT_LINE" ]; then
            RESULT="$RESULT_LINE"
        fi

        # Extract CPU time
        CPU_LINE=$(grep "CPU time" "$OUTFILE" | grep -oP '[0-9.]+(?= s)')

        if [ ! -z "$CPU_LINE" ]; then
            TIME="$CPU_LINE"
        fi
    fi

    # Write to summary
    echo "$BASENAME,$RESULT,$TIME,$TIMEOUT_FLAG" >> "$SUMMARY_FILE"
done
