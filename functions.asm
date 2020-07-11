
; len returns the length of a string
; int len(char[] message);
len:
	push	rbx		; save the value of rbx
	mov	rbx, rax	; rbx and rax targets the same memory address

nextchar:
	cmp	byte [rax], 0	; check if we are at the end of the string segment: zero flag is set if true
	jz	finished	; if end of string we jump to finished section
	inc	rax		; else we increment eax to the next value
	jmp	nextchar	; and we restart

finished:
	sub	rax, rbx	; the delta between the two registry is the lenght of the string
	pop	rbx		; release the saved value
	ret			; return where the function was called

; print displays a string to the screen
; void print(char[] message);
print:
	push 	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rax

	call len		; get the size of the string

	mov	rdx, rax	; the size of the string
	pop	rax		; fetch the original value of raw (the string)
	mov	rsi, rax	; the string we want to print
	mov	rdi, 1		; write on the std out
	mov	rax, 1		; sys_write syscall
	syscall

	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx

	ret

; exit will gracefully exits the program
; int exit(int code)
exit:
	mov	rbx, rax	; the exit code
	mov	rax, 60		; sys_exit
	syscall
	ret
	
; println displays a string to the screen
; with an extra line feed
; void println(char[] message);
println:
	push	rcx		; syscall writes in rcx, we save it
	call	print		; we first print the string

	push	rax		; save eax value
	mov	rax, 0Ah	; move the linefeed char in eax
	push	rax		; push the linefeed on the stack to get its address
	mov	rax, rsp	; store in rax the address of the linefeed on the stack
	call	print		; print the linefeed

	pop	rax
	pop	rax
	pop	rcx

	ret

; rand generate a pseudo-random number based
; on the `square` CBRNG
; https://arxiv.org/pdf/2004.06278v2.pdf
; int64 rand()
rand:
	; save registry
	push	r8
	push	r9
	push 	r10
	push	rdi

	mov	r10, rcx	; copy of rcx
	push	rcx		; save rcx destroyed by syscall

	; generate seed from time
	mov	rax, 201	; sys_time
	xor	rdi, rdi	; set rdi to 0 to return value in rax
	syscall

	mov	r8, rax 	; set the seed based on the time
	mov	rax, r10	; set the counter
	inc	rax	; add 1 to avoid 0
	mul	r8			; counter * seed
	mov	r9, rax		; y = counter * seed
	add	r8, r9		; z = y + key
	; 1st round
	mul	rax		; x = x * x
	add	rax, r9		; x = x + y
	mov	r10, rax	; copy rax
	shr	rax, 32		; x >> 32
	shl	r10, 32		; x << 32
	or	rax, r10	; (x >> 32) | (x << 32)
	; 2nd round
	mul	rax		; x = x * x
	add 	rax, r8		; x = x + z
	mov	r10, rax	; copy rax
	shr	rax, 32		; x >> 32
	shl	r10, 32		; x << 32
	or	rax, r10	; (x >> 32) | (x << 32)
	; 3rd round
	mul	rax		; x = x * x
	add 	rax, r9		; x = x + y
	shr	rax, 32		; x >> 32

	; restore saved value
	pop	rcx
	pop	rdi
	pop 	r10
	pop	r9
	pop	r8

	ret
