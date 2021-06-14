; Josep Marcello (jspmarcello@live.com)
; 11 Juni 2021

; ---- DATA SECTION ----
section .data
batas: db "========================================"
batasLen: equ $-batas

gameTitle: db "[---------- Witches 'n Dragons ----------]"
gameTitleLen: equ $-gameTitle

gameOver: db "[---------- The End ----------]"
gameOverLen: equ $-gameOver

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

witchStatsMsg1: db "The Witch's stats:", 10, "HP: "
witchStatsMsg1Len: equ $-witchStatsMsg1
witchStatsMsg2: db "Stamina:"
witchStatsMsg2Len: equ $-witchStatsMsg2

dragonStatsMsg1: db "The Dragon's stats:", 10, "HP: "
dragonStatsMsg1Len: equ $-dragonStatsMsg1
dragonStatsMsg2: db "Stamina: "
dragonStatsMsg2Len: equ $-dragonStatsMsg2

witchWinMsg: db "The Witches are triumphant over the Dragons!", 10
witchWinMsgLen: equ $-witchWinMsg
dragonWinMsg: db "The Dragons are triumphant over the Witches!", 10
dragonWinMsgLen: equ $-dragonWinMsg

strongAtkMsg: db "You dealt 5 damage to your opponent.", 10
strongAtkMsgLen: equ $-strongAtkMsg
weakAtkMsg: db "You dealt 2 damage to your opponent.", 10
weakAtkMsgLen: equ $-weakAtkMsg
healMsg: db "You restored 2 HP.", 10
healMsgLen: equ $-healMsg

restoreStaminaMsg: db "Restored 2 stamina for each players.", 10
restoreStaminaMsgLen: equ $-restoreStaminaMsg

; ---- TEXT SECTION ----
section .text

global _start

; writePlayerName
; Menuliskan nama pemain 1 tanpa new line,
; lalu lompat ke suatu tempat (argumen pertama macro)
; argumen kedua adalah nilai "boolean", jika ganjil artinya nama player 2 dan
; dan genap maka player 1
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

	.done:
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

	.printTitle:
		mov rax, 1
		mov rdi, 1
		mov rsi, gameTitle
		mov rdx, gameTitleLen
		syscall
		call printNewLine

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

		xor rdx, rdx
		mov rax, rbx
		mov r8, 3
		div r8

		test rdx, rdx
		jz .restoreStamina

		.playerTurn1:
			mov r8b, bl
			and r8, 1
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

			cmp r9, 1
			jl .badInput
			cmp r9, 6
			jg .badInput

			mov r8b, bl
			and r8, 1

			; too lazy for switch-case statement
			cmp r9, 1
			je .weak
			cmp r9, 2
			je .strong
			cmp r9, 3
			je .heal
			cmp r9, 4
			je .stats
			cmp r9, 5
			je .help
			cmp r9, 6
			je .printGameOver

	.endTurn:
		jmp .startTurn

	.printGameOver:
		mov rax, 1
		mov rdi, 1
		mov rsi, gameOver
		mov rdx, gameOverLen
		syscall
		call printNewLine

		xor rdi, rdi
		call exit

	.help:
		call printBatas
		mov rax, 1
		mov rdi, 1
		mov rsi, helpMsg
		mov rdx, helpMsgLen
		syscall
		call printBatas
		jmp .playerInput

	.stats:
		call printBatas
		; Witch's hp
		mov rax, 1
		mov rdi, 1
		mov rsi, witchStatsMsg1
		mov rdx, witchStatsMsg1Len
		syscall
		mov rdi, r13
		call printNum
		call printNewLine

		; Witch's stamina
		mov rax, 1
		mov rdi, 1
		mov rsi, witchStatsMsg2
		mov rdx, witchStatsMsg2Len
		syscall
		mov rdi, r12
		call printNum
		call printNewLine

		; Dragon's hp
		mov rax, 1
		mov rdi, 1
		mov rsi, dragonStatsMsg1
		mov rdx, dragonStatsMsg1Len
		syscall
		mov rdi, r15
		call printNum
		call printNewLine

		; Dragon's stamina
		mov rax, 1
		mov rdi, 1
		mov rsi, dragonStatsMsg2
		mov rdx, dragonStatsMsg2Len
		syscall
		mov rdi, r14
		call printNum
		call printNewLine

		call printBatas

		jmp .playerInput

	.strong:
		call printBatas
		mov rax, 1
		mov rdi, 1
		mov rsi, strongAtkMsg
		mov rdx, strongAtkMsgLen
		syscall
		call printBatas

		test r8, r8
		jz .strongP2
		sub r12, 3 ; p1Stamina -= 3
		sub r15, 5 ; p2Hp -= 5
		jmp .endTurn

		.strongP2:
			sub r14, 3 ; p2Stamina -= 3
			sub r13, 5 ; p1Hp -= 5
			jmp .endTurn

	.heal:
		call printBatas
		mov rax, 1
		mov rdi, 1
		mov rsi, healMsg
		mov rdx, healMsgLen
		syscall
		call printBatas

		test r8, r8
		jz .healP2
		sub r12, 2
		add r13, 2
		jmp .endTurn

		.healP2:
			sub r14, 2
			add r15, 2
			jmp .endTurn

	.weak:
		call printBatas
		mov rax, 1
		mov rdi, 1
		mov rsi, weakAtkMsg
		mov rdx, weakAtkMsgLen
		syscall
		call printBatas

		test r8, r8
		jz .weakP2
		sub r12, 1
		sub r15, 2
		jmp .endTurn

		.weakP2:
			sub r14, 1
			sub r13, 2
			jmp .endTurn

	.badInput:
		mov rax, 1
		mov rdi, 1
		mov rsi, badInputMsg
		mov rdx, badInputMsgLen
		syscall
		jmp .playerInput

	.restoreStamina:
		add r12, 2
		add r14, 2

		call printBatas
		mov rax, 1
		mov rdi, 1
		mov rsi, restoreStaminaMsg
		mov rdx, restoreStaminaMsgLen
		syscall
		call printBatas

		jmp .playerTurn1

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


printBatas:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	mov rsi, batas
	mov rdx, batasLen
	syscall
	call printNewLine

	mov rsp, rbp
	pop rbp
	ret
