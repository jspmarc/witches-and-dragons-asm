AS = nasm
LD = ld86
# ARCH = x86_64

src_file = ./game.asm
out_obj = game.o
out_bin = game.out

.PHONY: default, bin, game

default: bin

$(out_obj): $(out_obj)
	$(AS) -f -$(ARCH) -o $@ $<

$(out_bin): $(src_file)
	$(LD) -o $@ $<

game: bin
bin: $(out_bin)