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
				"[1]: Weak attack (1 stamina)", 10,\
				"[2]: Strong attack (3 stamina)", 10,\
				"[3]: Heal (2 stamina)", 10,\
				"[4]: Stats", 10,\
				"[5]: Help", 10,\
				"[6]: Quit game", 10,\
				"(1/2/3/4/5/6)> "
askPlayerActionLen: equ $-askPlayerAction

helpMsg: db "Instruction:", 10,\
			"Weak attack: deals 2 damage and uses 1 stamina", 10,\
			"Strong attack: deals 5 damage and uses 3 stamina", 10,\
			"Heal: restores 2 HP and uses 2 stamina", 10
helpMsgLen: equ $-helpMsg

badInputMsg: db "Your input is invalid, please input between 1 to 6 (inclusive.)", 10
badInputMsgLen: equ $-badInputMsg

newRoundMsg: db "Round: "
newRoundMsgLen: equ $-newRoundMsg

dbgMsg1: db "Halo", 10
dbgMsg1Len: equ $-dbgMsg1
dbgMsg2: db "Aku di sini", 10
dbgMsg2Len: equ $-dbgMsg1
dbgMsg3: db "Tangkap aku, kawan!", 10
dbgMsg3Len: equ $-dbgMsg1

; ---- TEXT SECTION ----
section .text

global _start

; writeP1Name
; Menuliskan nama pemain 1 tanpa new line,
; lalu lompat ke suatu tempat (argumen pertama macro)
%macro writePlayerName 2
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1

	test %2, %2
	jz .p2 ; genap

	mov rsi, p1Name
	mov rdx, p1NameLen
	syscall

	jmp .done

	.p2:
		mov rsi, p2Name
		mov rdx, p2NameLen
		syscall

	.done
		mov rsp, rbp
		pop rbp

		jmp %1
%endmacro

; writeP2Name
; Menuliskan nama pemain 2 tanpa new line,
; lalu lompat ke suatu tempat (argumen pertama macro)
%macro writeP2Name 1
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, p2Name
	mov rdx, p2NameLen
	syscall
	call printNewLine

	mov rsp, rbp
	pop rbp

	jmp %1
%endmacro

_start:
	jmp game

game:
	; Tabel variabel
	; Nama          | register
	; --------------|----------
	; p1Stammina    | r12
	; p1Hp          | r13
	; p2Stamina     | r14
	; p2Hp          | r15
	; roundCounter  | rbx
	; isP1Turn      | r8
	; pInput        | r9

	.gameInit:
		mov r12, 100 ; p1Stamina
		mov r13, 100 ; p1Hp
		mov r14, 100 ; p2Stamina
		mov r15, 100 ; p2Hp
		xor rbx, rbx ; roundCounter
		xor r8, r8   ; isP1Turn
		xor r9, r9   ; pInput

	.startTurn:
		inc rbx

		mov rax, 1
		mov rdi, 1
		mov rsi, newRoundMsg
		mov rdx, newRoundMsgLen
		syscall

		mov rdi, rbx
		call printNum
		call printNewLine

		mov r8b, bl
		and r8, 0x1

		.playerTurn1:
			mov rax, 1
			mov rdi, 1
			mov rsi, playerTurn1
			mov rdx, playerTurn1Len
			syscall

			lea r10, [.playerTurn2]
			writePlayerName r10, r8

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
			mov r9, rax
			mov rdi, rax
			call printNum
			call printNewLine

			cmp r9, 1
			jl .badInput
			cmp r9, 6
			jg .badInput

			; too lazy for switch-case statement
			cmp r9, 1
			je .weak
			cmp r9, 2
			je .heal
			cmp r9, 3
			je .strong
			cmp r9, 4
			je .stats
			cmp r9, 5
			je .help
			cmp r9, 6
			je .exit

	.endTurn:
		jmp .startTurn
		; mov rdi, 1
		; call printNum
		; call printNewLine

	.gameEnd:
		mov rdi, 1
		call printNum
		call printNewLine

	.exit:
		xor rdi, rdi
		call exit

	.help:
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		jmp .playerInput

	.stats:
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		jmp .playerInput

	.strong:
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		jmp .endTurn

	.heal:
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		jmp .endTurn

	.weak:
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		jmp .endTurn

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
		mov r8, 10
		div r8

		and rdx, 0xFF
		add dl, 48 ; ubah ke ASCII-nya, dl += '0'

		lea r8, [rbp-8]
		sub r8, rcx
		mov byte [r8], dl

		inc rcx ; i++
		test rax, rax
		jnz .loop ; if (num != 0) goto loop

	test rdi, rdi
	jge .isPositive
	.isNegative:
		; tambah '-' ke awal string
		xor rdx, rdx
		mov dl, 45 ; ascii '-'
		lea r8, [rbp-8]
		sub r8, rcx
		mov byte [r8], dl
		jmp .done

	.isPositive:
		dec rcx

	.done:
		lea r8, [rbp-8]
		sub r8, rcx

		mov rax, 1
		mov rdi, 1
		mov rsi, r8
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

	xor rax, rax ; syscall number, 0 is read
	xor rdi, rdi ; read from stdin
	lea rsi, [rbp-29] ; buf, dari [rbp-29] sampai [rbp-8]
	mov rdx, 21 ; size
	syscall

	; hapus "\n" dari input
	dec rax ; itung digitnya aja, "\n" ga dianggap
	mov rcx, rax ; banyak digit di register rcx
	mov qword [rsi+rcx], 0

	xor rax, rax ; sum = 0
	xor rdx, rdx ; i = 0, banyak digit yang sudah "dibaca"
	xor r10, r10 ; tmp = 0
	.loop:
		imul rax, 10 ; sum *= 10
		mov byte r10b, [rsi + rdx] ; tmp = *(rsi + i)
		sub r10, 48 ; tmp -= '0'
		add rax, r10 ; sum += tmp

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
