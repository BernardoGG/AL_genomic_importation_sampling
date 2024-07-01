#!/bin/bash

# Function to generate a unique output file name with an underscore before the number
generate_output_filename() {
    local base_name="$1"
    local extension="$2"
    local counter=1
    local output_file="${base_name}_${counter}${extension}"

    while [ -e "$output_file" ]; do
        ((counter++))
        output_file="${base_name}_${counter}${extension}"
    done

    echo "$output_file"
}

# Define the input and base name for the output files
INPUT_FILE="sequence_alignment.fasta"    # Input file for createMapleFile.py
INTERMEDIATE_FILE="inputMapleFile.txt"   # Output file from createMapleFile.py and input for MAPLEv0.2.2.1.py
OUTPUT_BASE_NAME="output"         # Base name for the final output file from MAPLEv0.2.2.1.py
#OUTPUT_EXTENSION=".tree"                # Extension for the final output file
STATES_FILE="states_file.csv"            # Input states file for mugration.py

# Ensure pypy3 is installed and accessible
if ! command -v pypy3 &> /dev/null; then
    echo "MAPLE requires PyPy3, please install it before running the pipeline."
    exit 1
fi

# Ensure TreeTime is installed and accessible
# if ! command -v treetime &> /dev/null; then
#     echo "This pipeline requires TimeTree to perform a mugration analysis, please install it before running."
#     exit 1
# fi

# Ensure Augur is installed and accessible
if ! command -v augur &> /dev/null; then
    echo "This pipeline requires Augur (Nextstrain) to perform a mugration analysis, please install it before running."
    exit 1
fi

# Generate a unique output file name
OUTPUT_FILE=$(generate_output_filename "$OUTPUT_BASE_NAME")

# Run MAPLE input file creating script
echo "Creating a MAPLE input file..."
pypy3 MAPLE/createMapleFile.py --path ../AL_loop_files/ --fasta "$INPUT_FILE" --output "$INTERMEDIATE_FILE"

# Check if a MAPLE file was successfully produced
if [ $? -ne 0 ]; then
    echo "Error: failed to produce MAPLE input file."
    exit 1
fi

# Run MAPLE to produce fast phylogenetic tree
echo "Running MAPLE..."
pypy3 MAPLE/MAPLEv0.3.6.py --input ../AL_loop_files/"$INTERMEDIATE_FILE" --output ../AL_loop_files/"$OUTPUT_FILE"

# Check if MAPLE ran successfully
if [ $? -ne 0 ]; then
    echo "Error: failed to run MAPLE."
    exit 1
fi

echo "MAPLE phylogenetic inference completed successfully. Performing phylogeographic analysis..."
exit 0

# Construct the output filename for mugration.py
MUGRATION_OUTPUT="annotated_${OUTPUT_FILE}"

# Run the mugration analysis using TreeTime
#treetime mugration --tree ../AL_loop_files/"$OUTPUT_FILE" --states ../AL_loop_files/"$STATES_FILE" --attribute location --outdir ../AL_loop_files/"$MUGRATION_OUTPUT"

# Run the mugration analysis using Augur (Nextstrain)
augur traits --tree ../AL_loop_files/"$OUTPUT_FILE" --metadata ../AL_loop_files/"$STATES_FILE" --columns location --output-node-data ../AL_loop_files/"$MUGRATION_OUTPUT"

# Check if TreeTime ran successfully
if [ $? -ne 0 ]; then
    echo "Error: failed to perfrom phylogeographic reconstruction."
    exit 1
fi

echo "Pipeline completed successfully. Identifying NIDPINs..."
exit 0

# Construct the output filename for mugration.py
NIDPINS_OUTPUT="${OUTPUT_FILE}_nidpins"

# Find nidpins using R script
treetime mugration --tree ../AL_loop_files/"$OUTPUT_FILE" --states ../AL_loop_files/"$STATES_FILE" --attribute location --outdir ../AL_loop_files/"$MUGRATION_OUTPUT"
R  --tree ../AL_loop_files/"$MUGRATION_OUTPUT"


# Check if TreeTime ran successfully
if [ $? -ne 0 ]; then
    echo "Error: failed to perfrom phylogeographic reconstruction."
    exit 1
fi
