#include "cpu/gdt.h"

    .code16
    .global _start
_start:
    mov %dl, boot_drive
    mov $banner, %si
    call print_string

    call switch_to_32bit

    hlt
    jmp . // loop forever


switch_to_32bit:
    mov $2, %al
    out %al, $0x92          // enable A20

    cli                     // 1. disable interrupts
    lgdt gdt_descriptor     // 2. load GDT descriptor
    mov %cr0, %eax
    or $1, %eax             // 3. enable protected mode
    mov %eax, %cr0
    ljmp $SEG_KCODE << 3, $init_32bit // 4. far jump


.code32
init_32bit:
    mov $SEG_KDATA << 3, %ax      // 5. update segment registers
    mov %ax, %ds
    mov %ax, %ss
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs

    mov $KERN_STACK_BASE, %ebp      // 6. setup stack
    mov %ebp, %esp

    call bootmain           // 7. load and run kernel
    jmp .                   // 8. loop forever


.code16
print_string:
    mov $0x0e, %ah  // "teletype output"
repeat:
    lodsb           // equivalent to mov (%si), %al; inc %si

    test %al, %al
    je done

    int $0x10       // bios interrupt
    jmp repeat
done:
    ret

boot_drive:
    .byte 0

banner:
    .asciz ">> panicOS bootloader initializing...\n\r"

read_error:
    .asciz "Read error\n\r"

    .balign 2
entry:
    .word 0
disk_heads:
    .byte 0
sectors_per_track:
    .byte 0

    .balign 4
gdt_start:
    .quad 0x0 // null descriptor
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)   # code seg
    SEG_ASM(STA_W, 0x0, 0xffffffff)         # data seg
gdt_end:

// GDT descriptor
gdt_descriptor:
    .word gdt_end - gdt_start - 1 // size (16 bit)
    .int  gdt_start               // address (32 bit)
