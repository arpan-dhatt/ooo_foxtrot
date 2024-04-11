#!/bin/sh

# Check if the required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <input.s> <output.elf> [linker_script.ld]"
  exit 1
fi

# Get the input and output file names from the arguments
input_file="$1"
output_file="$2"

# Check if the linker script is provided
if [ $# -eq 3 ]; then
  linker_script="$3"
  linker_option="-T $linker_script"
else
  linker_option=""
fi

# Compile the assembly file
as --target=aarch64-none-elf "$input_file" $linker_option -o "$output_file"

echo "Assembly file compiled successfully."