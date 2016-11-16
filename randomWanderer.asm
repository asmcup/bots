; This bot can generate (almost) random numbers and uses them to wander around aimlessly.

; Overclock the CPU to 2 (3 cycles per frame).
push8 #2
push8 #IO_OVERCLOCK
io

; Drive at constant speed
pushf 1.0
push8 #IO_MOTOR
io

loop:

; Turn in a random direction
jmp getRandomByte
gotRandomByte:
b2f
sin               ; We now have a pretty random float in the -1 to 1 range.
push8 #IO_STEER
io

jmp loop


; Generate a (somewhat) random number.
getRandomByte:
  push8 #IO_BATTERY
  io
  xor
  xor
  xor
jmp gotRandomByte
