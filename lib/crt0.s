        .export         _exit
        .export         __STARTUP__ : absolute = 1      ; Mark as startup
        .import         zerobss, _main
        .import         copydata
        .import         initlib, donelib
        .import         __STACKSTART__                  ; Linker generated

        .include "zeropage.inc"
        .include "io.inc"

        .segment "STARTUP"
	sei
        lda #<__STACKSTART__
        ldx #>__STACKSTART__
        sta sp
        stx sp+1
        jsr zerobss
        jsr copydata
        jsr initlib
        lda #%11100111
        sta via_porta
        lda #%11010111
        sta via_ddra
        jsr _main
_exit: pha
        jsr donelib
        pla
        rts
