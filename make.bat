..\SjAsmPlus torpes_demo.asm
FlagCheck header.bin 0
FlagCheck torpes.bin

..\desprot\GenTape     torpes.wav          ^
          turbo 2168   667   735                      ^
            600 1600  1500     0  header.bin.fck      ^
          turbo 2168   667   735                      ^
            600 1600  1500     0  torpes.bin.fck      ^
  plug-torpes-4   ff   500  1000  patron.scr          ^
  plug-torpes-4   ff   500  1000  hoh.scr             ^
  plug-torpes-4   ff   500  1000  batman.scr
