build: link

assemble:
	@nasm -f elf64 xor.asm

link: assemble
	@ld xor.o
