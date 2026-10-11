
#!/bin/bash

header="Ex   total   JP=0.0  JP=1.0  JP=2.0  JP=3.0  JP=4.0  JP=5.0  JP=6.0  JP=7.0  JP=8.0"

# Create output directory if it does not already exist
mkdir -p ld_values

for ptable in 0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45
do
    echo "======================================"
    echo "Running TALYS with ptable = $ptable"
    echo "======================================"

    # Create temporary input
    sed "s/^ptable 40 100 .*/ptable 40 100 $ptable/" input.txt > temp_input.txt

    # Run TALYS and overwrite output.dat
    talys < temp_input.txt > output.dat


    # ============================================================
    # Positive parity
    # ============================================================

    echo "$header" > "ld_values/output_${ptable}_p.txt"

    awk '
    /Level density parameters for Z= 40 N= 60 \(100Zr\)/ {
        zr=1
    }

    zr && /Positive parity/ {
        positive=1
        next
    }

    positive && /^[[:space:]]*[0-9]+\.[0-9]+/ {
        print
    }

    positive && /Negative parity/ {
        exit
    }
    ' output.dat >> "ld_values/output_${ptable}_p.txt"


    # ============================================================
    # Negative parity
    # ============================================================

    echo "$header" > "ld_values/output_${ptable}_n.txt"

    awk '
    /Level density parameters for Z= 40 N= 60 \(100Zr\)/ {
        zr=1
    }

    zr && /Negative parity/ {
        negative=1
        next
    }

    negative && /Normalization:/ {
        exit
    }

    negative && /^[[:space:]]*[0-9]+\.[0-9]+/ {
        print
    }
    ' output.dat >> "ld_values/output_${ptable}_n.txt"


    echo "Created ld_values/output_${ptable}_p.txt"
    echo "Created ld_values/output_${ptable}_n.txt"

done

rm temp_input.txt
rm output.dat

echo "======================================"
echo "All TALYS runs completed."
echo "======================================"

