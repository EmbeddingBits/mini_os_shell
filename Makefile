CROSS_COMPILE = arm-none-eabi-
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

QEMU_UART_ADDR = 0x101f1000

QEMU_LINK = link_qemu.ld

all: kernel7.img

kernel7.img: boot.o uart.o shell.o
	$(LD) -T $(QEMU_LINK) -o kernel.elf $^
	$(OBJCOPY) kernel.elf -O binary $@

%.o: %.S
	$(AS) -g -o $@ $<

qemu-test: all
	qemu-system-arm \
		-M versatilepb \
		-cpu arm1176 \
		-kernel kernel7.img \
		-nographic \
		-d cpu,int \
		-D qemu.log

clean:
	rm -f *.o *.elf kernel7.img
