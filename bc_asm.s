@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global add_test @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type add_test, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int add_test(int x, int y)
@
@ Input: r0, r1 (i.e. r0 holds x, r1 holds y)
@ Returns: r0
@r
@
@ Here is the actual add_test function
add_test:
push {r4, r6, r7, lr} @preserve r4 and r6 and lr

add r0, r0, r1 @adding r0 and r1 and storing it in r0

mov r6, r0 @moving r0 to r4

mov r7, r3 @move the value of r3 into r7 to be restored after the led toggle messes up all my registers

mov r0, #1 @storing a constant into r0

bl BSP_LED_Toggle @toggling a light with index 1

bl busy_delay

mov r3, r7 @restoring r3 to be 10

bl blink_led

mov r0, r6 @moving the original value of the sum back to r0 to be returned

pop {r4, r6, r7, lr} @popping r4 and r6 and lr
@put stuff back to how you found it right before you leave

bx lr @ Return (Branch eXchange) to the address in the link register (lr)

.size add_test, .-add_test @@ - symbol size (not strictly required, but makes the debugger happy)
@ Assembly file ended by single .end directive on its own line

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0
@
@ Here is the actual function. DO NOT MODIFY THIS FUNCTION.
busy_delay:
push {r0, r5} @pushing register 5
mov r5, r2 @moving the value within r2 to r5
delay_1oop:
    subs r5, r5, #1
    bge delay_1oop
mov r0, #0 @ Return zero (success)
pop {r0, r5} @popping off r5
bx lr @ Return (Branch eXchange) to the address in the link register (lr

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0, r3 
@ Returns: r0, r3
@
blink_led:
push {r0, r3, r5, r7, lr}
mov r3, #0 @move the value 0 into r3
start_loop:
cmp r3, r7 @compare r3 to r7
bge end_loop 
    mov r0, #1 @r0 always gets messed up in BSP_LED_Toggle so i will keep making it 1 every loop
    mov r5, r3 @move r3 into r5 so it doesn't get messed up in BSP_LED_Toggle
    bl BSP_LED_Toggle @toggling a light with index 1
    mov r3, r5 @bring r3 original value back
    add r3, r3, #1
    b start_loop @branch back to the beginning of the loop
end_loop:
    pop {r0, r3, r5, r7, lr}
    bx lr


.end