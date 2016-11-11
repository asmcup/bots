; This bot can kind of escape rooms

; Overclock the CPU to 20 extra cycles per frame (helps with beam sensor)
push8 #20
push8 #IO_OVERCLOCK
io

start:

; Read beam sensor
push8 #IO_SENSOR
io
pop8 type   ; (not used)
popf beam

; Slow down the closer we get to things 
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
type: db8 0.0
