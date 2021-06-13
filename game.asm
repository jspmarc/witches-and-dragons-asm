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
	mov rdi, -123499999
	call printNum
	call printNewLine

	call exit

; void exit();
; fungsi untuk keluar dari program dengan exit code 0
exit:
	mov rax, 60			; exit syscall
	xor rdi, rdi
	syscall

; void printNum(long num);
; Fungsi untuk menuliskan long integer (8 byte) ke layar
printNum:
	push rbp
	mov rbp, rsp

	mov rax, rdi
	xor rcx, rcx ; initial condition, "first element", i = 0
	mov [rbp-8], rcx ; *(rbp - 8) = 0, null terminator for string
	inc rcx ; i++

	test rdi, rdi
	jge .loop ; kalo negatif, bikin jadi positif
	imul rax, -1

	.loop:
		xor rdx, rdx
		mov rbx, 10
		div rbx

		and rdx, 0xFF
		add dl, 48 ; ubah ke ASCII-nya, dl += '0'

		lea rbx, [rbp-8]
		sub rbx, rcx
		mov byte [rbx], dl

		inc rcx ; i++
		test rax, rax
		jnz .loop ; if (num != 0) goto loop

	test rdi, rdi
	jge .isPositive
	.isNegative:
		; tambah '-' ke awal string
		xor rdx, rdx
		mov dl, 45 ; ascii '-'
		lea rbx, [rbp-8]
		sub rbx, rcx
		mov byte [rbx], dl
		jmp .done

	.isPositive:
		dec rcx

	.done:
		lea rbx, [rbp-8]
		sub rbx, rcx

		mov rax, 1
		mov rdi, 1
		mov rsi, rbx
		mov rdx, rcx
		syscall

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
