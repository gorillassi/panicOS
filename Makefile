GDB=gdb
OBJCOPY=objcopy

ifeq ($(shell uname -s),Darwin)
AS=x86_64-elf-as
LD=x86_64-elf-ld
CC=x86_64-elf-gcc
GDB=x86_64-elf-gdb
OBJCOPY=x86_64-elf-objcopy
endif

CFLAGS = -fno-pic -ffreestanding -static -fno-builtin -fno-strict-aliasing \
         -Wall -ggdb -m32 -Werror -fno-omit-frame-pointer
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

run: panicOS.img
	@echo Running panicOS...
	qemu-system-i386 -drive format=raw,file=$< -serial mon:stdio

run-nox: panicOS.img
	@echo Running panicOS in headless mode...
	qemu-system-i386 -nographic -drive format=raw,file=$< -serial mon:stdio

output.txt: panicOS.img
	qemu-system-i386 -nographic -drive format=raw,file=$< -serial mon:stdio | sed -n '/Booting from Hard Disk.../,$$p' > output.txt

test: output.txt
	diff output.txt ref-output.txt

ejudge.sh: panicOS.img
	echo >$@ "#!/bin/sh"
	echo >>$@ "base64 -d <<===EOF | gunzip >panicOS.img"
	gzip <$^ | base64 >>$@
	echo >>$@ "===EOF"
	echo >>$@ "exec qemu-system-i386 -nographic -drive format=raw,file=panicOS.img -serial mon:stdio"
	chmod +x $@

debug-boot-nox: panicOS.img mbr.elf
	qemu-system-i386 -nographic -drive format=raw,file=$< -s -S &
	$(GDB) mbr.elf \
		-ex "set architecture i8086" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7c00" \
		-ex "continue"

debug-boot: panicOS.img mbr.elf
	qemu-system-i386 -drive format=raw,file=$< -s -S &
	$(GDB) mbr.elf \
		-ex "set architecture i8086" \
		-ex "target remote localhost:1234" \
		-ex "break *0x7c00" \
		-ex "continue"

debug: panicOS.img
	qemu-system-i386 -drive format=raw,file=$< -s -S &
	$(GDB) kernel.bin \
		-ex "target remote localhost:1234" \
		-ex "break _start" \
		-ex "continue"

debug-nox: panicOS.img
	qemu-system-i386 -nographic -drive format=raw,file=$< -s -S &
	$(GDB) kernel.bin \
		-ex "target remote localhost:1234" \
		-ex "break _start" \
		-ex "continue"

fs.img: kernel.bin tools/mkfs
	tools/mkfs $@ $<

LDFLAGS=-m elf_i386

user/%: user/%.o user/crt.o
	$(LD) $(LDFLAGS) -o $@ -Ttext 0x1000 $^

panicOS.img: mbr.bin fs.img
	cat $^ >$@

kernel.bin: kernel.o console.o drivers/vga.o drivers/uart.o solution.o
	$(LD) $(LDFLAGS) -o $@ -Ttext 0x9000 $^

bootmain.o: bootmain.c
	$(CC) $(CFLAGS) -Os -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) -m32 -ffreestanding -c -g $^ -o $@

mbr.bin: mbr.elf tools/mbrpad
	$(OBJCOPY) -S -O binary -j .text $< $@
	tools/mbrpad $@

mbr.raw: mbr.o bootmain.o
	$(LD) -N -m elf_i386 -Ttext=0x7c00 --oformat=binary $^ -o $@

mbr.elf: mbr.o bootmain.o
	$(LD) -N -m elf_i386 -Ttext=0x7c00 $^ -o $@

clean:
	rm -f *.elf *.img *.bin *.raw *.o */*.o tools/mkfs ejudge.sh output.txt

tools/%: tools/%.c
	gcc -Wall -Werror -g $^ -o $@
