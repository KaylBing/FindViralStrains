#!/bin/bash

# Check if the input file is provided
#if [ "$#" -ne 1 ]; then
# echo "Usage: $0 input_file"
# exit 1
#fi

# Define the input file from the command-line argument
input_file="$1"
input_file2="$2"

# Check if the input file exists
#if [ ! -f "$input_file" ]; then
# echo "Error: File '$input_file' not found!"
#exit 1
#fi

# Define the output DOT file and PNG file based on the input file name
output_dot_file="graph.dot"
# Does this so that the file is overwritten eventually when run again
output_pdf_file="${input_file%.*}.pdf"

# Start the DOT file
echo "digraph G {" > "$output_dot_file"

# Read the input file line by line
while read -r line; do
    # Skip lines that are comments or empty
    if [[ $line == \#* ]] || [[ -z $line ]]; then
        continue
    fi

    # Split the line into source, target, and weight
    read -r source target weight <<< "$line"
    if [[ -z $target ]]; then
        continue
    fi

    # Convert the labels to the desired format
    source_label="${source//+/_plus}"
    source_label="${source_label//-/_minus}"
    target_label="${target//+/_plus}"
    target_label="${target_label//-/_minus}"

    # Print the node relationship
    echo " \"$source_label\" -> \"$target_label\" [label=\"${weight}\"] ;" >> "$output_dot_file"
done < "$input_file"

# Read the paths from the second file
colors=("blue" "red" "green")
path_index=0

while read -r line; do
    # Check if the line contains a path
    if [[ $line =~ ^[0-9]+\.[0-9]+ ]]; then
        # Extract the path
        path=$(echo "$line" | cut -d' ' -f2-)
        tokens=($path)

        # Determine color based on the path index
        color="${colors[$((path_index % ${#colors[@]}))]}"
        path_index=$((path_index + 1))

        # Create edges for the path
        for num in $(seq 2 ${#tokens[@]}); do
            source="${tokens[$num-1]}"
            target="${tokens[$num]}"
            source_label="${source//+/_plus}"
            source_label="${source_label//-/_minus}"
            target_label="${target//+/_plus}"
            target_label="${target_label//-/_minus}"

            # Print the converted labels with color
            echo " \"$source_label\" -> \"$target_label\" [color=$color] ;" >> "$output_dot_file"
        done
    fi
done < "$input_file2"

# End the DOT file
echo "}" >> "$output_dot_file"

# Generate the graph image using Graphviz
dot -Tpdf "$output_dot_file" -o "$output_pdf_file"

echo "Graph has been generated as $output_pdf_file"

