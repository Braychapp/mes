/*
* C to assembler menu hook
*
*/
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "common.h"
int add_test(int x, int y, uint32_t delay, int count);
void AddTest(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Addition Test\n\n"
"This command tests new addition function\n"
);
return;
}
//creating a variable of type uint32_t called delay and a regular int called fetch_status
uint32_t delay;
int fetch_status;
fetch_status = fetch_uint32_arg(&delay);
if(fetch_status) {
// Use a default delay value
delay = 0xFFFFFF;
}
// When we call our function, pass the delay value.
// printf(“<<< here is where we call add_test – can you add a third parameter? >>>”);
//r0 = 98
//r1 = 87
//r2 = 0xFFFFFF
//r3 = 20
//r3 needs to be 20 because to toggle on the LED is one and to turn it off is also 1 so each on / off counts for 2
printf("add_test returned: %d\n", add_test(98, 87, delay, 20));
}
ADD_CMD("ads", AddTest,"Test the new add function");




int bc_led_demo_a2(int count, int delay);
void _bc_A2(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("LED DEMO\n\n"
"This command tests that I know hwo to turn on all the LEDS\n"
);
return;
}
uint32_t user_input;
int fetch_status;
fetch_status = fetch_uint32_arg(&user_input);
if(fetch_status) {
// Use a default value
user_input = 0xFFFFFF;
}
printf("bc_led_demo_a2 has finished, if 0 it has worked correctly: %d", bc_led_demo_a2(1, 0xFFFFFF)); //0 is the counter and delay is the delay from the user
}
ADD_CMD("add", _bc_A2, "Test the _bc_A2 function");