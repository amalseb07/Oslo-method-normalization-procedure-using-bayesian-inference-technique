#!/bin/bash
set -e

# ============================================================
# Robust TALYS automation script
# Extracts:
#   1. Cross sections from rp040100.tot
#   2. Reaction rates from astrorate.g
# ============================================================

file1="file1.txt"          # 2-column file (ctable, ptable)
file2="file2.txt"          # 3-column file (ftable, upbendc, upbende)
input="input.txt"          # TALYS input template
output="output.dat"        # TALYS log output

cross_section="cross-section.txt"
reaction_rate="reaction_rate.txt"

rp040100="rp040100.tot"
astrorate="astrorate.g"


# ============================================================
# Prepare output files
# ============================================================

> "$cross_section"
> "$reaction_rate"


# ============================================================
# Scaling or offsets
# ============================================================

ftable=1
upbende=0
upbendc="10^-6"
ctable=0.0
ptable=0.0


# ============================================================
# Check matching number of lines
# ============================================================

n1=$(wc -l < "$file1")
n2=$(wc -l < "$file2")

echo "Lines in file1: $n1"
echo "Lines in file2: $n2"

if [ "$n1" -ne "$n2" ]; then
    echo "Error: file1 and file2 must have the same number of rows."
    exit 1
fi

echo
echo "Running $n1 TALYS iterations..."
echo


# ============================================================
# Loop over all rows
# ============================================================

for ((i=1; i<=n1; i++)); do

    echo "============================================================"
    echo "Iteration $i / $n1"
    echo "============================================================"


    # --------------------------------------------------------
    # Read line safely (handles extra spaces)
    # --------------------------------------------------------

    read ctable_val ptable_val < <(sed -n "${i}p" "$file1")
    read ftable_val upbendc_val upbende_val < <(sed -n "${i}p" "$file2")


    # --------------------------------------------------------
    # Apply math
    # --------------------------------------------------------

    ctable_val=$(echo "$ctable_val + $ctable" | bc -l)
    ptable_val=$(echo "$ptable_val + $ptable" | bc -l)

    ftable_val=$(echo "$ftable_val * $ftable" | bc -l)

    upbendc_val=$(echo "$upbendc_val * $upbendc" | bc -l)
    upbende_val=$(echo "$upbende_val + $upbende" | bc -l)


    # --------------------------------------------------------
    # Combine into array (TALYS order)
    # --------------------------------------------------------

    all_vals=(
        "$upbende_val"
        "$upbendc_val"
        "$ftable_val"
        "$ctable_val"
        "$ptable_val"
    )

    echo "upbende, upbendc, ftable, ctable, ptable"
    echo "all_vals: ${all_vals[@]}"


    # --------------------------------------------------------
    # Prepare input file
    # --------------------------------------------------------

    cp "$input" input_temp.txt

    sed -i "s/^upbende 40 100.*/upbende 40 100 ${all_vals[0]} M1/" input_temp.txt
    sed -i "s/^upbendc 40 100.*/upbendc 40 100 ${all_vals[1]} M1/" input_temp.txt
    sed -i "s/^ftable 40 100.*/ftable 40 100 ${all_vals[2]} E1/" input_temp.txt
    sed -i "s/^ctable 40 100.*/ctable 40 100 ${all_vals[3]}/" input_temp.txt
    sed -i "s/^ptable 40 100.*/ptable 40 100 ${all_vals[4]}/" input_temp.txt


    # --------------------------------------------------------
    # Debug: show generated input
    # --------------------------------------------------------

    echo "Input for iteration $i:"
    # cat input_temp.txt
    echo "----------------------"


    # --------------------------------------------------------
    # Run TALYS
    # --------------------------------------------------------

    talys < input_temp.txt > "$output"



    # ========================================================
    # Extract REACTION RATE from astrorate.g
    # ========================================================

    if [ -f "$astrorate" ]; then

        awk '
        !/^#/ && NF == 4 {
            print $2
        }
        ' "$astrorate" | tr '\n' ' ' >> "$reaction_rate"

        echo "" >> "$reaction_rate"

    else

        echo "Warning: astrorate.g not found for iteration $i" >> "$reaction_rate"

    fi





    echo "Finished iteration $i"

done


# ============================================================
# Final message
# ============================================================

echo "============================================================"
echo "Completed $n1 TALYS runs."
echo
echo "reaction_rate saved to:"
echo "    $reaction_rate"
