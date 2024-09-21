; vim: ft=asm_ca65
.include "io.inc"
.autoimport
.globalzp ptr1
.export _acia_init, _acia_getc, _acia_getc_nw, _acia_putc, _acia_puts, _acia_prbyte

; vim: set ft=asm_ca65 sw=4 ts=4 et:
ACIA_PARITY_DISABLE          = %00000000
ACIA_ECHO_DISABLE            = %00000000
ACIA_TX_INT_DISABLE_RTS_LOW  = %00001000
ACIA_RX_INT_ENABLE           = %00000000
ACIA_RX_INT_DISABLE          = %00000010
ACIA_DTR_LOW                 = %00000001


.zeropage

.code
_acia_init:
    lda #$00
    sta acia_status
    lda #(ACIA_PARITY_DISABLE | ACIA_ECHO_DISABLE | ACIA_TX_INT_DISABLE_RTS_LOW | ACIA_RX_INT_DISABLE | ACIA_DTR_LOW)
    sta acia_command
    lda #$10
    sta acia_control
    rts

_acia_getc:
@wait_rxd_full:
    lda acia_status
    and #$08
    beq @wait_rxd_full
    lda acia_data
    rts

_acia_getc_nw:
    lda acia_status
    and #$08
    beq @done
    lda acia_data
    sec
    rts
@done:
    clc
    rts

_acia_putc:
    pha                         ; save char
@wait_txd_empty:
    lda acia_status
    and #$10
    beq @wait_txd_empty
    pla                     ; restore char
    sta acia_data
    rts

_acia_puts:
    phy
    sta ptr1+0
    stx ptr1+1
    ldy #0
:   lda (ptr1),y
    beq :+
    jsr _acia_putc
    iny
    bne :-
:   ply
    rts

_acia_prbyte:
    pha             ;Save A for LSD.
    lsr
    lsr
    lsr             ;MSD to LSD position.
    lsr
    jsr prhex       ;Output hex digit.
    pla             ;Restore A.
prhex:
    and #$0F        ;Mask LSD for hex print.
    ora #$B0        ;Add "0".
    cmp #$BA        ;Digit?
    bcc echo        ;Yes, output it.
    adc #$06        ;Add offset for letter.
echo:
    pha             ;*Save A
    and #$7F        ;*Change to "standard ASCII"
    jsr _acia_putc
    pla             ;*Restore A
    rts
.bss

.rodata
