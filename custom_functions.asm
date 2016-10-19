; Examples of how to create custom functions.
;
; A key feature of a function is that you can call it from wherever you want,
; your code will resume after the function call. To achieve this, the address
; of the call site (return address) must be stored somewhere.
;
; On a very basic level, that may be achieved like this:

ret: db8 #0     ; Somewhere to store the return address

push8 #3        ; second argument
push8 #4        ; first argument
push8 #callSite1
jmp myFunction
callSite1: ; [more code]

myFunction:
pop8 ret        ; store the return address
sub8            ; do whatever you want to do with the arguments
jmp [ret]       ; back to the call site

; In this example, you'd have to place a label after every "function call" and
; push that label onto the stack just before jumping to the function.
; The return value(s) of the function will be on the stack, which could be useful.
; Be aware though that your function "body" cannot call any other functions that
; operate like this - you'd overwrite the return address in ret!

; There is an instruction that greatly simplifies this process: jsr
; Let's adapt the above example for illustration:

ret: db8 #0     ; Somewhere to store the return address

push8 #3        ; second argument
push8 #4        ; first argument
push8 #myFunction
jsr
; [more code]

myFunction:
pop8 ret        ; store the return address
sub8            ; do whatever you want to do with the arguments
jmp [ret]       ; back to the call site

; What jsr actually does is 1. pop the target function address from the stack,
; 2. push the address of the instruction following it on the stack and finally
; 3. jumping to the address from step 1.
; The actual function works just like in the previous example. Note that it still
; has the same drawback as the first example: Your return address may/will break
; if you call other (custom) functions.
;
; The only way to safely nest custom function calls involves keeping the return
; address on the stack. Unfortunately, you will want to peel your function
; arguments from the stack (to use them) before popping the return address for
; the jump back to the call site, which means that the return address needs to
; be "below" the arguments on the stack.

; One way to do that is to simply push the return address before all function
; arguments, so you can pop it just before going back. Note that you can't use
; the stack to hold return values in this case:

eax: db8 #0    ; general purpose "register"
retval: db8 #0 ; return "register"

push8 #callSite2
push8 #3        ; second argument
push8 #4        ; first argument
jmp mySafeFunction
callSite2: ; [more code]

; Function definition
mySafeFunction:
sub8        ; do whatever you want here, including calling other functions
pop8 ret    ; set return "register"
pop8 eax    ; fetch return address (can't directly use stack value as jump target atm)
jmp [eax]   ; jump to call site

; Note also that jsr can't be used here, because that would place the return address
; above the function arguments on the stack.
; Aside from reorganizing the stack after a jsr (i.e. getting the function arguments
; "above" the return address or just fitting them all in registers (but that can run
; into similar problems)), this is the only way to currently implement e.g. recursive
; functions.

; So, to summarize: If your function is simple enough that it doesn't need to call
; other functions (or that it can manipulate the stack to the point where the return
; address is placed at the lowest touched point), use the jsr instruction to save
; space, labels and headaches.
; For complex/recursive functions, make sure to keep the return address as low as
; possible on the stack and only pop it right before jumping back. Or know your
; stuff well enough to be sure whatever you come up with works.
