# Binary File Manipulation Scripts

This repository contains two Python scripts for manipulating binary files:
`apply_changes.py`: Applies changes specified in a text file to a binary file.

```
Usage: python apply_changes.py [options] <dest.bin> <input.bin> <changes.txt>

This script applies changes specified in a text file to a binary file.

Options:
-h, --help  Show this help message and exit

Arguments:
<dest.bin>    The path to the output binary file where the changes will be applied
<input.bin>   The path to the input binary file that will be modified
<changes.txt> The path to the text file containing the changes to be applied

The changes.txt file should have the following format:
- Each change is represented by one or more lines.
- The first line of each change starts with '0x' followed by the hexadecimal address where the change should be applied.
- The subsequent lines for each change contain the hexadecimal values to be written at the specified address.
- Changes are separated by one or more blank lines.

Example changes.txt file:
0x1000
0x1234
0x5678

0x2000
0xabcd
0xef01

The script will parse the changes.txt file, apply the changes to the input binary file, and save the modified binary file as the output file specified by <dest.bin>.

Note: The script overwrites the output file if it already exists.
```

`create_zeros_file.py`: Creates a binary file filled with zeros of a specified size.

```
Usage: python create_zeros_file.py [options] <output_file>

This script creates a binary file filled with zeros of a specified size.

Options:
-h, --help  Show this help message and exit

Arguments:
<output_file>  The path to the output binary file to be created

The script will create a binary file at the specified <output_file> path, filled with zeros.

Example usage:
python create_zeros_file.py zeros.bin 12

This will create a binary file named 'zeros.bin' in the current directory, containing 4 KiB of zeros.

Note: The script overwrites the output file if it already exists.
```