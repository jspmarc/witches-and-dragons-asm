; Josep Marcello (jspmarcello@live.com)
; 11 Juni 2021

; ---- DATA SECTION ----
section .data
hello: db "Hello, world!", 0xA
helloLen equ $-hello

; ---- TEXT SECTION ----
section .text

global _start

_start:
	mov rax, 1			; write syscall
	mov rdi, 1			; fd
	mov rsi, hello		; buf
	mov rdx, helloLen	; count
	syscall

	call exit

; void exit();
; fungsi untuk keluar dari program dengan exit code 0
exit:
	mov rax, 60			; exit syscall
	xor rdi, rdi
	syscall
