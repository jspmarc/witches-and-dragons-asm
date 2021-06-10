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