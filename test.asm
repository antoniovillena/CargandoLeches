        output  test.bin
        org     $5ccb
        ld      de, $1b00
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96 ; OVER USR 7 ($5ccb)

ruti:   ld      ix, $4000
        ld      a, $12
        scf
        call    $0556
binf:   jr      binf
