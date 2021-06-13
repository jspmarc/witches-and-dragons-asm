# Game RPG turn-based sederhana
> [Game Inspiration](https://www.youtube.com/watch?v=6izF5Wyr94o&t=44s)
## Aturan Permainan
### Pemain
Seoranng pemain memiliki seorang karakter
### Sebuah karakter dapat melakukan:
- Serangan "lemah" (1 stamina)\
  Memberikan 2 HP damage
- Berobat (2 stamina)\
  "Mengembalikan" 2 HP
- Serangan "kuat" (3 stamina)\
  Memberikan 5 HP damage
### Kondisi awal:
Setiap karakter memiliki 100 stamina dan 100 HP di awal
### Stamina:
- Ketika stamina habis, karakter ga bisa ngapa-ngapain lagi dan turn di-skip
- 2 Stamina akan di-restore setiap 3 turn
### Kondisi menang/kalah:
- Pemain dengan HP terendah kalah
- Permainan berakhir ketika kedua karakter sudah tidak ada stamina
- Permainan berakhir ketika salah seorang karakter kehabisan HP

## ASM notes
Program "hello world"
```as
section .data
hello: db "Hello, world!", 0xA
helloLen equ $-hello

section .text
mov rax, 1			; write syscall, eax
mov rdi, 1			; fd, stdout, ebx
mov rsi, hello		; buf, ecx
mov rdx, helloLen	; count, edx
syscall
```
### Notes on x86-64 syscall:
- `RAX`: syscall number
- `RDI`: first arg
- `RSI`: second arg
- `RDX`: third arg
- `R10`: fourth arg
- `R9`: fifth arg
- `R8`: sixth arg
- `RCX`: return address
