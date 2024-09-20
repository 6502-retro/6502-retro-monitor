; vim: ft=asm_ca65
.export _go
.code
_go:
	sta cmd+0
	stx cmd+1
	jmp (cmd)
.bss
cmd: .word 0

