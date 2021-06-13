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
	mov [rbp-8], rcx ; *(rbp - 8) = 0, null terminator for string, batas string
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

; void printNewLine();
; Fungsi untuk menuliskan sebuah new line ("\n")
printNewLine:
	push rbp
	mov rbp, rsp

	xor rax, rax
	mov byte [rbp-8], al
	add rax, 10
	mov byte [rbp-9], al

	mov rax, 1
	mov rdi, 1
	lea rsi, [rbp-9]
	mov rdx, 2
	syscall

	mov rsp, rbp
	pop rbp
	ret

; long getNumInput();
; Fungsi untuk membaca sebuah angka (maksimal 8 byte) dari user
getNumInput:
	push rbp
	mov rbp, rsp

	; max num has 19 digits, it's already a lot so no need for "offset"
	; + \n
	; + \0
	; so at most, we read 21 bytes

	mov rax, 0 ; syscall number, 0 is read
	mov rdi, 0 ; read from stdin
	lea rsi, [rbp-29] ; buf, dari [rbp-29] sampai [rbp-8]
	mov rdx, 21 ; size
	syscall

	; hapus "\n" dari input
	dec rax ; itung digitnya aja, "\n" ga dianggap
	mov rcx, rax ; banyak digit di register rcx
	mov qword [rsi+rcx], 0

	xor rax, rax ; sum = 0
	xor rdx, rdx ; i = 0, banyak digit yang sudah "dibaca"
	.loop:
		imul rax, 10 ; sum *= 10
		mov byte bl, [rsi + rdx]
		sub rbx, 48
		add rax, rbx ; sum += (*(rsi + i) - '0')

		inc rdx

		cmp rdx, rcx ; kondisi, banyak yang "dibaca" == banyak digit
		jne .loop ; if (i != rcx) goto loop;

	mov rsp, rbp
	pop rbp
	ret
