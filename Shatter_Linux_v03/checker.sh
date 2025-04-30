#!/bin/bash

FOLDER="sgen"  # <- change this to your folder path

cd "$FOLDER" || exit 1

for file in *.cnf; do
    # Skip generated files
    if [[ "$file" == *.Sym.cnf || "$file" == *.SymOnly.cnf ]]; then
        echo "Skipping generated file: $file"
        continue
    fi

    echo "Processing $file..."

    # Run the command with timeout
    timeout 30s perl ../shatter.pl "$file"

    if [ $? -eq 124 ]; then
        echo "Timeout on $file! Deleting related files..."

        # Base filename (without .cnf)
        base="${file%.cnf}"

        # Remove original and related files
        rm -f "$file" \
              "$file.txt" \
              "$file.g" \
              "$file.Sym.cnf" \
              "$file.SymOnly.cnf"
    else
        echo "Completed: $file"
    fi
done

