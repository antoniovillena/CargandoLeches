        define  consta  $69
        define  tr $ffff &

; Bloque cabecera
        output  header.bin
        db      0               ; tipo: 0=cabecera, 1=array numérico
                                ; 2=array alfanumérico, 3=código máquina
        db      'TorpesDemo'    ; Nombre del archivo (hasta 10 letras)
        block   11-$, 32        ; Relleno el resto con espacios
        dw      fin-ini         ; Longitud del bloque basic
        dw      10              ; Autoejecución en línea 10
        dw      fin-ini         ; Longitud del bloque basic

; Bloque datos (Basic con código máquina incrustado)
        output  torpes.bin
        org     $8001-tabla+ini
ini     ld      sp, $8200-4
        di
        db      $de, $c0, $37, $0e, $8f, $39, $96
        ld      hl, $5ccb+tabla-ini
        ld      de, $8001
        ld      bc, fin-tabla
        ldir

        ld      hl, $4000
        ld      de, $1b00
        call    tr ultra

        ld      hl, $4000
        ld      de, $1b00
        call    tr ultra

        ld      hl, $4000
        ld      de, $1b00
        call    tr ultra
        halt

tabla   defb    $ec, 0, 0, 0  ; 01
        defb    $ec, 0, 0, 0  ; 05*
        defb    $ec, 0, 0, 0  ; 09*
        defb    $ec, 0, 0, 0  ; 0d
        defb    $ed, 0, 0, 0  ; 11
        defb    $ed, 0, 0, 0  ; 15*
        defb    $ed, 0, 0, 0  ; 19*
        defb    $ee, 0, 0, 0  ; 1d
        defb    $ee, 0, 0, 0  ; 21*
        defb    $ee, 0, 0, 0  ; 25*
        defb    $ef, 0, 0, 0  ; 29
        defb    $ef, 0, 0, 0  ; 2d*
        defb    $ef, 0, 0, 0  ; 31*
        defb    $ef, 0, 0, 0  ; 35 

ultra   ld      ix, ramab1
        exx                     ; salvo de, en caso de volver al cargador estandar y para hacer luego el checksum
        ld      e, 0
        ld      c, e
ultra1  defb    $26
ultra2  jp      nz, $053f       ; return if at any time space is pressed.
ultra3  ld      b, e
        call    $05ed           ; leo la duracion de un pulso (positivo o negativo)
        jr      nc, ultra2      ; si el pulso es muy largo retorno a bucle
        ld      a, b
        add     a, -16          ; si el contador esta entre 10 y 16 es el tono guia
        rr      h               ; de las ultracargas, si los ultimos 8 pulsos
        jr      z, ultra1
        add     a, 6            ; son de tono guia h debe valer ff
        jr      c, ultra3
        ld      l, h
        dec     h
        jr      nz, ultra1      ; si detecto sincronismo sin 8 pulsos de tono guia retorno a bucle
        ld      a, $d8          ; a' tiene que valer esto para entrar en raudo
        ex      af, af'
        call    $05ed           ; leo pulso negativo de sincronismo
ultra4  ld      b, e            ; 16 bytes
        call    $05ed           ; esta rutina lee 2 pulsos e inicializa el contador de pulsos
        call    $05ed
        ld      a, b
        cp      12
        adc     hl, hl
        jr      nc, ultra4
        ld      a, l
        xor     h
        exx
        ld      c, a            ; guardo checksum en c'
        push    hl              ; pongo direccion de comienzo en pila
        exx
        pop     de              ; recupero en de la direccion de comienzo del bloque
        dec     de
        ld      h, tabla>>8
        call    $05ed
        inc     c               ; pongo en flag z el signo del pulso
        ld      bc, $effe       ; este valor es el que necesita b para entrar en raudo
        call    nz, lee2
        jr      nz, ramab2
        ld      ixl, ramaa1 & 255
        call    lee1
        jr      ramaa2          ; salto a raudo segun el signo del pulso en flag z

ramaa   nop                     ;4
        out     (c), b          ;12
        inc     hl              ;6
        xor     b               ;4
        add     a, a            ;4
        add     a, a            ;4
        call    lee1            ;17
ramaa1  ex      af, af'         ;7+4      64
        ld      a, r            ;9
        ld      l, a            ;4
        ld      b, (hl)         ;7
ramaa2  ld      a, consta       ;7
        ld      r, a            ;9
        call    lee2            ;17
        ex      af, af'         ;7+4      72/72
        jp      nc, ramaa       ;10
        xor     b               ;4
        xor     $9c             ;7
        inc     de              ;6
        ld      (de), a         ;7
        ld      a, $dc          ;7
        push    ix              ;15
        ret     c               ;5
lee1    defb    $ed, $70, $e0
        .10     defb    $6e, $ed, $70, $e0
        jr      ultra9

ramab   nop                     ;4
        out     (c), b          ;12
        inc     hl              ;6
        xor     b               ;4
        add     a, a            ;4
        add     a, a            ;4
        call    lee2            ;17
ramab1  ex      af, af'         ;7+4      64
        ld      a, r            ;9
        ld      l, a            ;4
        ld      b, (hl)         ;7
ramab2  ld      a, consta       ;7
        ld      r, a            ;9
        call    lee1            ;17
        ex      af, af'         ;7+4      72/72
        jp      nc, ramab       ;10
        xor     b               ;4
        xor     $9c             ;7
        inc     de              ;6
        ld      (de), a         ;7
        ld      a, $dc          ;7
        push    ix              ;15
        ret     c               ;5
lee2    defb    $ed, $70, $e8
        .10     defb    $6e, $ed, $70, $e8

ultra9  pop     hl
        exx                     ; ya se ha acabado la ultracarga (raudo)
        ld      b, e
        dec     de
        inc     d
ultraa  xor     (hl)
        inc     hl
        djnz    ultraa
        dec     d
        jr      nz, ultraa      ; con JP ahorro algunos ciclos
        xor     c
        ret     z               ; si no coincide el checksum salgo con carry desactivado

        ei
        rst     $08             ; error-1
        defb    $1a             ; error report: tape loading error
fin
