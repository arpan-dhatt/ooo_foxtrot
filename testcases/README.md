# Testcases

Testcases are directories including the following:

1. `prof.elf`: a compatible chARM-v3 ELF file where all segment ranges are within 4 KiB
2. `mem.bin`: a 4 KiB binary file containing the initial memory contents for the CPU
3. `mem_cmp.txt`: a text file describing memory addresses and their contents to check after testcase completes
4. `mmio.txt`: a text file to compare the MMIO output from the CPU with

Only one of `prog.elf` or `mem.bin` are required to run. `prog.elf` is prioritized over `mem.bin`.

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