SECTIONS
{
  . = 0x0008;
  .text : { *(.text) }
  . = 0x0C00;
  .data : { *(.data) }
  .bss : { *(.bss) }
}