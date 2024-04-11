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
else
  linker_script=""
fi

# Compile the assembly file
as --target=aarch64-none-elf "$input_file" $linker_option -o "$output_file.o"

# Link with LLD
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  /opt/homebrew/opt/llvm/bin/ld.lld "$output_file.o" $linker_script -o "$output_file"
else
  # Other operating systems
  ld.lld "$output_file.o" $linker_script -o "$output_file"
fi

# remove intermediate file
rm "$output_file.o"

echo "Assembly file compiled successfully."