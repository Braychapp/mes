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
    mov r3, r4
    bl led_1oop @going back to the loop


.size bc_led_demo_a2, .-bc_led_demo_a2 @@ - symbol size (not strictly required, but makes the debugger happy)




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
.global get_string @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type get_string, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int bc_led_demo_a2(int x, int y)
get_string:
    push {lr}
    mov r1, #0 @setting up index
    @string lives in r0

    
    @ldrb only loads the byte being pointed to not the entire string

    @load a byte into a target register, the byte is going to be at a base address plus an offset
    @use the ASCII table
    @you know you're at the end of the string if you get to 0 because the ASCII value for null is #0

    @cmp the value to 0

    @if 0 then branch out of the loop

    @if not 0 then do other stuff
    @turn the ascii value into something
    @bl iterateLoop

    @iterateLoop:
    @{
        ldrb r1, [r0] @dereference the character that r0 points to
        @puts the byte that was in r0 into r1

        mov r0, r1 @move the ascii value back into r0 maybe?
        pop {lr}
        bx lr        
    @}

.size get_string, .-get_string @@ - symbol size (not strictly required, but makes the debugger happy)






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
.global bc_Game @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type bc_Game, %function @ Declares that the symbol is a function (not strictly required)


@ Function Declaration : int bc_Game(int delay, char * pattern, int target)
@
@ Input: r0, r1, r2 (r0 holds delay, r1 holds the pattern, and r2 holds the target light)
@ Returns: nothing
@r
@
@ Here is the actual add_test function
bc_Game:
@this function gets input from the program at r0 r1 and r2 so I need to do something with all of those values
push {r0-r7, lr}
@lets first get the pattern becasue it is arguably the most inportant
mov r4, r1 @loading the whole string into r4
mov r5, r0 @moving delay into r5 for use later
mov r6, r2 @moving the winning number into r6 for us later


mov r3, #1000 @for some reason I can't just multiply r5 by 1000 so I needed to put that number somewhere that hadn't been touched by the input from C
@after this line r3 being 1000 does not matter and is not needed

mul r5, r5, r3 @getting the delay to be larger, ie original delay = 500, and the new delay is 500,000
mov r7, r5 @moving the delay into a safer register that will only be used to replenish the delay after the loops
mov r2, #0 @make sure r2 is 0 because it is now going to be used for the index of the string
mov r9, #0 @make r9 0
bl toggle_light @start the progtam with the light on

@need to set up a loop

@work for later: Get the button press thing working
@get polling working
@TEST EVERYTHING TO MAKE SURE WHAT IS DONE CURRENTLY IS WORKING
@SPECIFICALLY STEPPING THROUGH THE STRING TO GET THE PATERN

pattern_loop:
    @loop while delay > 0
    mov r0, #0 @make sure r0 is 0 before calling get state
    bl BSP_PB_GetState @comparing the button to 1
    cmp r0, #1
    beq win_or_lose
    subs r5, r5, #1 @subtract one from r5 every time    
    bge pattern_loop @looping

@when done looping
    b toggle_light


toggle_light:
@this function is going to toggle the light that is currently turned on
    ldrb r8, [r4, r2] @loading r8 with the ascii character that is at r3 of the string r4
    @going to check if r8 is null
    @make an if statement to check if r8 is 0 because it shouldn't ever be unles the string has reached the end
    @if it has reached the end the function is goint o be called again after the index has been reset
    cmp r8, #0 @if r8 == 0
    beq reset_iterator
    @if r8 is not == 8
    @need to use a variable to demonstrate if the loop has currently gone through and the light is on still
    @ill use r9 for now    
    add r9, r9, #1 @add 1 into r9

    subs r8, r8, 48 @subtracting 48 from r8 to get the actual integer value instead of the ascii value
    mov r0, r8 @move r8 into r0 to be used when calling BSP_LED_TOGGLE
    bl BSP_LED_Toggle @turn on the light that r0 is equal to
    mov r5, r7 @move r7 into r5 to loop again
    cmp r9, #2 @if r9 is 2

    bge update_iterator @go to update the iterator if r9 is 2 meaning this is the second loop through

    bl pattern_loop @go back into the loop



reset_iterator:
    mov r2, #0 @resetting r3 to be 0
    bl toggle_light @going back to try again now that the index is reset


update_iterator:
    add r2, r2, #1 @increment the index
    mov r9, #0 @put 0 back into r9
@we need to reset the dealy and then go back to the loop from here
    mov r5, r7 @move delay back
    bl pattern_loop @going back to loop again


win_or_lose:
@this function is going to check if the user pressed the button at the right time
    cmp r6, r3 @comparing the target button to the current light that is active

pop {r0-r7, lr}
bx lr @return
.size bc_Game, .-bc_Game @@ - symbol size (not strictly required, but makes the debugger happy)


.end