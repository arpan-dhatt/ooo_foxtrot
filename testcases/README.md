# Testcases

Testcases are directories including the following:

1. `mem.bin`: a 64 KiB binary file containing the initial memory contents for the CPU
2. `mem_cmp.txt`: a text file describing memory addresses and their contents to check after testcase completes
3. `mmio.txt`: a text file to compare the MMIO output from the CPU with

`mem_cmp.txt` should be in the following format:

```
<8-byte aligned memory address in hex>
<8-byte hex data value>
<8-byte hex data value>
...

<8-byte aligned memory address in hex>
<8-byte hex data value>
```

This specifies the memory contents that should be at each given address for any number of bytes. This format is also
used with the `change_bin.py` script in the `scripts` directory to change values in a binary file.