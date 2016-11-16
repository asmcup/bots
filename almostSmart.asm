; This bot is already pretty smart, it will pick up items and avoid everything else.

; The code here is indented to show stack height: Each element (float or byte)
; on the stack *before* an instruction is represented by one column of indendation.

; Overclock the CPU to 20 cycles per second (helps with beam sensor)
push8 #20
 push8 #IO_OVERCLOCK
  io


start:

; Read beam sensor
push8 #IO_SENSOR
 io
  pop8 type         ; Save type of object hit by sensor
 popf distance     ; Save distance from sensed object

; Are we looking at an item?
push8 type
 push8 b00001100   ; This is a label (see below)! Binary number 00001100 = gold or battery flag.
  and               ; The top of the stack is now nonzero if an item was seen.
 jnz dontEvade     ; If we saw an item, do not evade.
jmp updateMove    ; Otherwise, evade things

; Set beam distance to 256.0, which means we'll drive straight ahead.
dontEvade:
pushf 256.0
 popf distance     
;jmp updateMove   ; (This jump is unnecessary)

updateMove:

; Turn when we get closer to things.
; Sets the steering to (256.0 - distance) / 256.0
pushf 256.0
 pushf 256.0
  pushf distance
   subf
  divf
 push8 #IO_STEER
  io
  
; Slow down the closer we get to things.
; Sets the motor to distance / 256.0
pushf 256.0
 pushf distance
  divf
 push8 #IO_MOTOR
  io

jmp start

distance: dbf 0.0
type: db8 #0

b00001100: db8 #12    ; The binary number 00001100 has the decimal value 12
