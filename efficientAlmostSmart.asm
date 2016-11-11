; This bot is already pretty smart, it will pick up items and avoid everything else.

; The code here is indented to show stack height: Each element (float or byte)
; on the stack *before* an instruction is represented by one column of indendation.

; This example shows the usage of relative instructions and constant extraction to
; save program space.
; Compared to almostSmart.asm, which behaves exactly the same way as this program,
; we only use 48 bytes of code instead of 60. That's a 20% reduction!

; #################################################################################

; Overclock the CPU to 20 cycles per second (helps with beam sensor)
push8 #20
 push8 #IO_OVERCLOCK
  io


start:

; Read beam sensor
push8 #IO_SENSOR
 io
  pop8r type        ; Save type of object hit by sensor
 popf distance      ; Save distance from sensed object

; Are we looking at an item?
push8r type
 push8r b00001100   ; This is a label (see below)! 00001100 = gold or battery flag.
  and               ; The top of the stack is now nonzero if an item was seen.
 jnzr dontEvade     ; If we saw an item, do not evade.
jmp updateMove      ; Otherwise, evade things

; VARIABLES AND CONSTANTS
; The program never reaches this part of the memory, so we can put our variables
; here, close to where they're used and benefit from relative instructions!
distance: dbf 0.0
type: db8 #0

; This takes exactly as much space in the program as if you were to write
; push8 #12
; in the instructions above. But you can reuse the number this way, and you can
; even give it more names by adding labels (e.g. C12: or TWELVE:) before it.
b00001100:
db8 #12    ; The binary number 00001100 has the decimal value 12

; Even though pushf can't be relative, replacing 4 occurences of
; pushf 256.0 (5 bytes each)
; with a constant
CF256: dbf 256.0  ; (4 bytes)
; and references to this constant (2 bytes each) saves a massive amount of space!

; BACK TO CODE
; Set beam distance to 256.0, which means we'll drive straight ahead.
dontEvade:
pushf CF256
 popf distance     
;jmp updateMove   ; (This jump is unnecessary)

updateMove:

; Turn when we get closer to things.
; Sets the steering to (256.0 - distance) / 256.0
pushf CF256
 pushf CF256
  pushf distance
   subf
  divf
 push8 #IO_STEER
  io
  
; Slow down the closer we get to things.
; Sets the motor to distance / 256.0
pushf CF256
 pushf distance
  divf
 push8 #IO_MOTOR
  io

jmp start
