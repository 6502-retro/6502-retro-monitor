; vim: set ft=asm_ca65 sw=4 ts=4 et:
.autoimport
.code
nmi:
    rti
irq:
    rti

.segment "VECTORS"
    .addr nmi
    .addr _main
    .addr irq

