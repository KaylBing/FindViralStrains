import os
import numpy as np
import matplotlib.pyplot as plt

fasta_files = "/home/mikhail/Output_Backup/output/NoRefTest/output_genomes"

# Initialize array of length 35,000 with all 0s #
gaps_array = np.zeros(35000, dtype=int)

# Function to mark gaps in the array based on 'Weight' lines #
def mark_gaps_from_weight_line(line, gaps_array, current_position):
    parts = line.split()
    sequence = parts[2]  # The actual comparison data from this line #

    for i, base in enumerate(sequence):
        if base == "-":  # Gaps are marked as '-' #
            genome_position = current_position + i  # Use the cumulative position #
            if genome_position < len(gaps_array):  # Ensure we don't go out of bounds #
                gaps_array[genome_position] += 1

# Loop through subdirectories #
for root, dirs, files in os.walk(fasta_files):
    for file in files:
        if file.endswith("_vs_ref.txt"):
            file_path = os.path.join(root, file)
            print(f"Parsing file: {file_path}")

            # Open the .vs_ref.txt file and parse the lines #
            current_position = 0  # Initialize the position counter for each file
            with open(file_path, 'r') as f:
                for line in f:
                    if line.startswith("Weight"):  # Only process lines that start with 'Weight' #
                        mark_gaps_from_weight_line(line, gaps_array, current_position)
                    # Update the cumulative position based on sequence length
                    if line.startswith("Weight"):
                        sequence = line.split()[2]
                        current_position += len(sequence)

# Plotting the aggregated gaps_array, not running plt.show in case this is run on a server #
plt.figure(figsize=(12, 6))
plt.bar(np.arange(len(gaps_array)), gaps_array, width=1.0, color='blue', alpha=0.7)
plt.xlabel('Genome Position')
plt.ylabel('Number of Occurrences')
plt.title('Distribution of Gaps in Genome Across All Files')
plt.xlim(0, len(gaps_array))  # Ensure the x-axis covers the full length of gaps_array #
plt.ylim(0, np.max(gaps_array) + 1)  # Adjust y-axis to accommodate the maximum value #

# Save the plot as a file #
plot_filename = "/home/mikhail/gaps_distribution.png"
plt.savefig(plot_filename)
plt.close()  # Close the plot once saved #
print(f"Saved plot as: {plot_filename}")

# Save the gaps_array to a .txt file #
output_filename = "/home/mikhail/gaps_array_output.txt"
np.savetxt(output_filename, gaps_array, fmt='%d')
print(f"Saved gaps array to: {output_filename}")
