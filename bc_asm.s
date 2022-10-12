@
@FILE : bc_asm.s
@PROJECT : A2 Calling Functions
@PROGRAMMER : Brayden Chapple
@FIRST VERSION : 2022-10-12
@DESCRIPTION : This program was created to turn on and off all the lights on the board as many times as the user wants at the speed the user wants
@


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
.global bc_led_demo_a2 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type bc_led_demo_a2, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int bc_led_demo_a2(int x, int y)


@
@Function: bc_led_demo_a2
@Description: This function is mostly used to push the registers that I will be using in led_delay
@then it calls led_delay
@Parameters: none
@Returns: nothing
@
bc_led_demo_a2:
@r0 is count and r1 is delay
push {r0-r7, lr} @pushing all available registers because I don't know what I'll end up using

bl led_delay

@
@Function: led_delay
@Description: This function is essentially my main(), where my program is going to run from once it is called from the minicom window.
@it turns on and off all the lights on the board one after another as many times as the user wants and as fast as the user wants
@Parameters: none
@Returns: nothing
@
led_delay:
    mov r2, #0 @r2 is used to see if an led is on or off, if it's an even number the led should be off and if it's odd it should be on
    mov r3, r1 @moving the delay value to r4
    mov r4, r1 @moving the delay value to r4 for use later when resetting the loop
    mov r5, r0 @moving count into r5
    mov r6, #0 @r6 is going to keep track of how many times we have gone through a complete cycle
    mov r7, #0 @r7 is going to hold which led is supposed to be toggled
    bl first_light @turning the light on to start
    led_1oop: @repeat r5 times
        subs r3, r3, #1
        bge led_1oop
        @loop over
    @if r6 is greater than r5
    add r2, r2, #1
    cmp r7, #8
        beq else1
    mov r0, r7 @update the led to be toggled
    bl BSP_LED_Toggle @calling BSP_LED_Toggle
    mov r3, r4 @moving the delay back into r3 for another loop
    @need to put an if statement inside an if statement here
    cmp r2, #2
        bge else2
    mov r0, r7 @make r0 the original number again 
    bl led_1oop @if the led is toggled on and hasnt been turned off its going to loop again

@used for switching which led is toggled

@
@Function: else2
@Description: This function is used for switching which led is going to be toggled next
@Parameters: none
@Returns: nothing
@
else2:
    add r7, r7, #1 @change which led is being toggled
    mov r2, #0 @move the status of the LED back to being off
    cmp r7, #8 @comparing again to try and avoid unnessecary loops
        beq else1
    bl led_1oop @going back to loop again

@used for adding to the total times that the program has looped

@
@Function: else1
@Description: This function is used to add the total times that the program has ran through one cycle
@then it loops from the beginning again
@Parameters: none
@Returns: nothing
@
else1:
    add r6, r6, #1 @the program has officially looped and r6 needs to be updated to reflect that
    mov r7, #0 @resetting the number incase there is more than one cycle
    @need to put an if statement to check if the count is the same as the one that the user entered
    bl else3 @going back to the loop

@
@Function: else3
@Description: This function is the third else statement to pair with my if statements that I have used in the program
@it compared r6 to r5 and if they are equal it will exit and if not it will go back and loop from the beginning again
@Parameters: none
@Returns: nothing
@
else3:
    cmp r6, r5 @compare r6 to r5
        beq exit @if theyre equal go to exit
    mov r2, #0 @if theyre not then make r2 0
    bl led_1oop @go back to the loop

@
@Function: exit
@Description: This function is used when the program has finished looping and running through itself.
@it pops all the registers to how they were before entering the main looping function
@Parameters: none
@Returns: nothing
@
exit:
    pop {r0-r7, lr} @popping off everything
    bx lr @ Return (Branch eXchange) to the address in the link register (lr


@
@Function: first_light
@Description: This function is used only for the first turning on of light 0 on the board
@Parameters: none
@Returns: nothing
@
first_light:
    mov r0, r7 @making r0 the same as r7
    bl BSP_LED_Toggle @toggling the light
    add r2, r2, #1 @adding 1 to r2 to tell the program that the light is on
    bl led_1oop @going back to the loop


.size bc_led_demo_a2, .-bc_led_demo_a2 @@ - symbol size (not strictly required, but makes the debugger happy)
.end