; vim: ft=asm_ca65 ts=4 sw=4 :
; Library functions for basic control of the SN76489 attached to the VIA

.include "io.inc"
.export _sn_start, _sn_stop, _sn_silence, _sn_beep, _sn_play_note, _sn_send

FIRST   = %10000000
SECOND  = %00000000
CHAN_1  = %00000000
CHAN_2  = %00100000
CHAN_3  = %01000000
CHAN_N  = %01100000
TONE    = %00000000
VOL     = %00010000
VOL_OFF = %00001111
VOL_MAX = %00000000

SD_SCK  = %00000001
SD_CS   = %00000010
SN_WE   = %00000100
SN_READY= %00001000
SD_MOSI = %10000000

.zeropage

.code

_sn_start:
    lda #(SD_SCK | SD_CS | SD_MOSI | SN_WE)
    sta via_ddra
    lda #$ff
    sta via_ddrb

    ; enable T1 Interupts
    lda #%01000000
    sta via_acr
    lda #$4e ; every 50000 (25ms) on a 2mhz clock
    sta via_t1cl
    lda #$c3
    sta via_t1ch
    jsr _sn_silence
    rts

_sn_stop:
    jsr _sn_silence
    rts

_sn_silence:
    lda #(FIRST|CHAN_1|VOL|VOL_OFF)
    jsr _sn_send
    lda #(FIRST|CHAN_2|VOL|VOL_OFF)
    jsr _sn_send
    lda #(FIRST|CHAN_3|VOL|VOL_OFF)
    jsr _sn_send
    lda #(FIRST|CHAN_N|VOL|VOL_OFF)
    jsr _sn_send
    rts

_sn_beep:
    lda #$07
    ldy #$04
    jsr _sn_play_note 
    ldy #$40
@d1:
    ldx #$00
@d2:
    dex
    bne @d2
    dey
    bne @d1

    jsr _sn_silence
    rts

_sn_play_note:
    ora #(FIRST|CHAN_1|TONE)
    jsr _sn_send
    tya
    ora #(SECOND|CHAN_1|TONE)
    jsr _sn_send
    lda #(FIRST|CHAN_1|VOL|$04)
    jsr _sn_send
    rts

; Byte to send in A
_sn_send:
    sta via_portb
    ldx #(SD_SCK|SD_CS|SD_MOSI|SN_WE)
    stx via_porta
    ldx #(SD_SCK|SD_CS|SD_MOSI)
    stx via_porta
    jsr _sn_wait
    ldx #(SD_SCK|SD_CS|SD_MOSI|SN_WE)
    stx via_porta
    rts

_sn_wait:
    lda via_porta
    and #SN_READY
    bne _sn_wait
    rts

