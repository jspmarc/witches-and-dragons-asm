; Josep Marcello (jspmarcello@live.com)
; 11 Juni 2021

; ---- DATA SECTION ----
section .data
hello: db "Hello, world!", 0xA
helloLen equ $-hello

firstCharName: db "V"
firstCharNameLen equ $-firstCharName
secondCharName: db "Panam"
secondCharNameLen equ $-secondCharName

minusSign: db "-"
minusSignLen: equ $-minusSign

; ---- TEXT SECTION ----
section .text

global _start

_start:
	mov edi, -9
	call printNum
	call printNewLine
	mov edi, 1
	call printNum
	call printNewLine

	call exit

; void exit();
; fungsi untuk keluar dari program dengan exit code 0
exit:
	mov rax, 60			; exit syscall
	xor rdi, rdi
	syscall

; void printInt(long i);
; Fungsi untuk menuliskan long integer (8 byte) ke layar
printNum:
	push rbp
	mov rbp, rsp

	; negative integer
	test edi, edi ; integer is 4 bytes
	jge .main ; if (edi >= 0) goto main
	mov rbx, rdi ; save the integer
	xor rax, rax
	mov byte [rbp-2], al ; char s[2]; s[1] = 0
	mov al, 45
	mov byte [rbp-1], al; s[0] = 45

	; print '-'
	mov rax, 1
	mov rdi, 1
	lea rsi, [rbp-2]
	mov rdx, 2
	syscall

	; kaliin argumen dengan -1
	imul rbx, -1
	mov rdi, rbx

	.main:
		xor ecx, ecx
		and rdi, 0x00000000000000FF
		call printDigit

	mov rsp, rbp
	pop rbp
	ret

; void printDigit(unsigned char dig);
; Fungsi untuk menuliskan sebuah digit (unsigned) ke layar
printDigit:
	push rbp
	mov rbp, rsp

	; check digit < 0 atau digit > 9
	; kalo iya, fungsi berhenti
	add dil, 48
	cmp dil, 48 ; < '0'
	jb .fail
	cmp dil, 57 ; > '9'
	ja .fail
	jmp .succ

	.fail:
		mov rax, -1
		jmp .done

	.succ:
		xor rax, rax
		mov byte [rbp-2], al
		mov byte [rbp-1], dil

		mov rax, 1
		mov rdi, 1
		lea rsi, [rbp-2]
		mov rdx, 2
		syscall

		mov byte al, dil

	.done:
		mov rsp, rbp
		pop rbp
		ret

printNewLine:
	push rbp
	mov rbp, rsp

	xor rax, rax
	mov byte [rbp-2], al
	add rax, 10
	mov byte [rbp-1], al

	mov rax, 1
	mov rdi, 1
	lea rsi, [rbp-2]
	mov rdx, 2
	syscall

	mov rsp, rbp
	pop rbp
	ret
