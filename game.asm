; Josep Marcello (jspmarcello@live.com)
; 11 Juni 2021

; ---- DATA SECTION ----
section .data
gameTitle: db "[---- Witches 'n Dragons ----]"

p1Name: db "Witch"
p1NameLen: equ $-p1Name
p2Name: db "Dragon"
p2NameLen: equ $-p2Name

playerTurn1: db "It's the "
playerTurn1Len: equ $-playerTurn1
playerTurn2: db "'s turn.", 10
playerTurn2Len: equ $-playerTurn2
askPlayerAction: db "What do you want to do?", 10,\
				"[1]: weak attack (1 stamina)", 10,\
				"[2]: strong attack (3 stamina)", 10,\
				"[3]: heal (2 stamina)", 10,\
				"[4]: Stats", 10,\
				"[5]: Help", 10,\
				"[6]: Quit game", 10,\
				"(1/2/3/4/5/6)> "
askPlayerActionLen: equ $-askPlayerAction

badInputMsg: db "Your input is invalid, please input between 1 to 6 (inclusive.)", 10
badInputMsgLen: equ $-badInputMsg

dbgMsg1: db "Halo", 10
dbgMsg1Len: equ $-dbgMsg1
dbgMsg2: db "Aku di sini", 10
dbgMsg2Len: equ $-dbgMsg1
dbgMsg3: db "Tangkap aku, kawan!", 10
dbgMsg3Len: equ $-dbgMsg1

; ---- TEXT SECTION ----
section .text

global _start

_start:
	; Tabel variabel
	; Nama          | register
	; --------------|----------
	; p1Stammina    | r8
	; p1Hp          | r9
	; p2Stamina     | r10
	; p2Hp          | r11
	; roundCounter  | r12
	; isP1Winner    | r13
	; p1Input       | r14, int
	; p12nput       | r15, int

	.gameInit:
		mov r8, 100
		mov r9, 100
		mov r10, 100
		mov r11, 100
		xor r12, r12
		xor r13, r13

	.startTurn:
		inc r12
		mov rax, r12
		and rax, 0xFF

		.playerTurn1:
			mov rax, 1
			mov rdi, 1
			mov rsi, playerTurn1
			mov rdx, playerTurn1Len
			syscall

			test rax, rax
			jnz .writeP1Name ; genap
			jmp .writeP2Name ; ganjil

		.playerTurn2:
			mov rax, 1
			mov rdi, 1
			mov rsi, playerTurn2
			mov rdx, playerTurn2Len
			syscall

		.playerInput:
			mov rax, 1
			mov rdi, 1
			mov rsi, askPlayerAction
			mov rdx, askPlayerActionLen
			syscall
			call getNumInput
			cmp rax, 1
			jl .badInput
			cmp rax, 6
			jg .badInput

			xor rdi, rdi
			call exit

	.endTurn:
		mov rdi, 1
		call printNum
		call printNewLine

	.gameEnd:
		mov rdi, 1
		call printNum
		call printNewLine

	xor rdi, rdi
	call exit

	.writeP1Name:
		mov rax, 1
		mov rdi, 1
		mov rsi, p1Name
		mov rdx, p1NameLen
		syscall
		jmp .playerTurn2

	; void writeP2Name();
	; Menuliskan nama pemain 2 tanpa new line
	.writeP2Name:
		mov rax, 1
		mov rdi, 1
		mov rsi, p2Name
		mov rdx, p2NameLen
		syscall
		jmp .playerTurn2

	.badInput:
		mov rax, 1
		mov rdi, 1
		mov rsi, badInputMsg
		mov rdx, badInputMsgLen
		syscall
		jmp .playerInput


; *** Utility functions ***
; void exit(int code);
; fungsi untuk keluar dari program dengan exit code `code`
exit:
	mov rax, 60			; exit syscall
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

; void debug1()
; nulisin pesan debug
debug1:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, dbgMsg1
	mov rdx, dbgMsg1Len
	syscall

	mov rsp, rbp
	pop rbp
	ret

; void debug2()
; nulisin pesan debug
debug2:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, dbgMsg2
	mov rdx, dbgMsg2Len
	syscall

	mov rsp, rbp
	pop rbp
	ret

; void debug3()
; nulisin pesan debug
debug3:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, dbgMsg3
	mov rdx, dbgMsg3Len
	syscall

	mov rsp, rbp
	pop rbp
	ret
