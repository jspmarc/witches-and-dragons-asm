AS = nasm
ifeq ($(DEBUG), 1)
AS_FLAG = -gstabs\
			-O0
else
AS_FLAG = -Ox
endif
LD = ld

game_src = game.asm
out_dir = bin
game_obj = $(out_dir)/game.o
game_bin = $(out_dir)/game

.PHONY: default, bin, clean, run

default: bin

$(game_obj): $(game_src)
	mkdir -p $(out_dir)
	$(AS) -felf64 $(AS_FLAG) -o $@ $<

$(game_bin): $(game_obj)
	$(LD) -o $@ $<

bin: $(game_bin)
run: $(game_bin)
	./$<

clean:
	rm -rf $(out_dir)/*
