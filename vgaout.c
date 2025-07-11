#include "drivers/vga.h"
#include "drivers/port.h"

unsigned my_get_offset(unsigned row, unsigned col) {
    return row * COLS + col;
}

void vga_set_cursor(unsigned offset) {
    port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);
    unsigned hi = offset >> 8;
    port_byte_out(VGA_DATA_REGISTER, hi);
    port_byte_out(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
    unsigned lo = offset & 0xff;
    port_byte_out(VGA_DATA_REGISTER, lo);
}

void vga_putc(char c) {
    unsigned offset = vga_get_cursor();
    if (c == '\n') {
        unsigned row = offset / COLS;
        offset = (row + 1) * COLS;
    } else {
        vga_set_char(offset++, c);
    }
    if (offset == ROWS * COLS) {
        offset -= COLS;
        for (unsigned i = 0; i < ROWS - 1; ++i) {
            for (unsigned j = 0; j < COLS; ++j) {
                char s = video_memory[2 * my_get_offset(i, j + COLS)];
                vga_set_char(my_get_offset(i, j), s);
            }
        }
        for (unsigned j = 0; j < COLS; ++j) {
            vga_set_char((ROWS - 1) * COLS + j, ' ');
        }
    }
    vga_set_cursor(offset);
}