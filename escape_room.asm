; This bot can kind of escape rooms

; Overclock the CPU to 20 cycles per second (helps with beam sensor)
push8 #20
push8 #IO_OVERCLOCK
io

start:


; Read beam sensor
push8 #IO_SENSOR
io
popf beam

; Closer we get to things slow down
pushf 256
pushf beam
divf
push8 #IO_MOTOR
io

; Turn when we get closer to things
pushf 256
pushf 256
pushf beam
subf
divf
push8 #IO_STEER
io

jmp start

beam: dbf 0.0
wander: dbf 0.0
