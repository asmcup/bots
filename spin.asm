
; This bot is stupid and will just spin in circles

start:
pushf 1.0
push8 #IO_STEER
io
jmp start

