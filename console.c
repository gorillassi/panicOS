#include "console.h"
#include "drivers/vga.h"
#include "drivers/uart.h"

void printk(const char* msg) {
    vga_print_string_noscroll(msg);
    for (; *msg; ++msg) {
        uartputc(*msg);
    }
}

void panic(const char* msg) {
    printk("\n>> SYSTEM HALTED <<\n");
    printk(">>> panicOS trapped a fatal fault <<<\n");
    printk(">>> reason: ");
    printk(msg);
    printk("\n");

    asm("cli");
    while (1) {
        asm("hlt");
    }
}

void console_clear() {
    vga_clear_screen();
}

void console_write(const char* str) {
    vga_print_string_noscroll(str);
}
