%include 'functions.asm'

SECTION .data

urandom	db '/dev/urandom', 0h	; /dev/urandom for pseudo random
clear	db 'hello', 0h		; clear text to cipher

SECTION .bss

mask	resb 255	; store the mask
cipher	resb 255	; the ciphered text

SECTION .text
global _start

_start:
	xor	rdi, rdi	; init rdi
	xor	rsi, rsi	; init rsi
	xor	rdx, rdx	; init rdx
	xor	r8, r8		; init r8
	xor	r9, r9		; init r9
	xor	r10, r10	; init r10

	; generate mask

	mov	rdi, urandom	; file to open
	mov	rsi, 0x00	; O_RDONLY
	mov	rdx, 0x01	; FREAD
	mov	rax, 0x02	; sys_open
	syscall

	mov	rdi, rax	; use the file descriptor
	mov	rsi, mask	; store the content of the file in mask
	mov	rdx, 5		; number of bytes (character) to read
	mov	rax, 0		; sys_read
	syscall

	mov	rax, 3	; sys_close
	syscall	

	mov	rax, mask	; prepare the mask to be displayed
	call 	println		; print the mask

	; cipher the clear text
	mov	r8, clear	; rsi targets the first element of `clear`
	mov	r9, mask	; rdi targets the first element of `mask`
	mov	r10, cipher	; rax targets the first element of `cipher`
	xor	rcx, rcx	; set counter to 0

.nextchar:

	mov	al, byte [r8 + rcx]	; get the byte at the position rsi + rcx
	xor	al, byte [r9 + rcx]	; xor the character with the key
	mov	byte [r10 + rcx], al	; store the ciphered character
	inc	rcx

	cmp	rcx, 0x05	; compare counter to 5 (string length)
	jnz	.nextchar	; loop if not equal

	mov	rax, cipher
	call	print

	call exit
