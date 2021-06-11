AS = nasm
LD = ld
# ARCH = x86_64

game_src = game.asm
out_dir = bin
game_obj = $(out_dir)/game.o
game_bin = $(out_dir)/game

.PHONY: default, bin, clean

default: bin

$(game_obj): $(game_src)
	mkdir -p $(out_dir)
	$(AS) -f elf64 -o $@ $<

$(game_bin): $(game_obj)
	$(LD) -o $@ $<

bin: $(game_bin)
run: $(game_bin)
	./$(game_bin)

clean:
	rm -rf $(out_dir)/*
