/*
* FILE : bc_hook.c
* PROJECT : A2 Calling Functions
* PROGRAMMER : Brayden Chapple
* FIRST VERSION : 2022-10-12
* DESCRIPTION : This program was created to turn on and off all the lights on the board as many times as the user wants at the speed the user wants
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
ADD_CMD("add", AddTest,"Test the new add function");




int bc_led_demo_a2(int count, int delay);
/*
* Function: _bc_A2
* Description: This function is used to call the function from within my assembly code
* It also will
* Parameters: none
* Returns: nothing
*/
void _bc_A2(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("LED DEMO\n\n"
"This command tests that I know hwo to turn on all the LEDS\n"
);
return;
}

uint32_t count;
int fetch_status2;
fetch_status2 = fetch_uint32_arg(&count);
if(fetch_status2) {
// Use a default value
count = 1;
}

uint32_t led_delay;
int fetch_status1;
fetch_status1 = fetch_uint32_arg(&led_delay);
if(fetch_status1) {
// Use a default value
led_delay = 0xFFFFFF;
}



printf("bc_led_demo_a2 has finished. Here is register 0:%d \n", bc_led_demo_a2(count, led_delay)); //0 is the counter and delay is the delay from the user
}
ADD_CMD("demo", _bc_A2, "Test the _bc_A2 function");

char * get_string(char *destptr);

void getString(int action)
{
    int fetch_status;
    char *destptr;
    fetch_status = fetch_string_arg(&destptr);

    if(fetch_status) {
        //default logic here
    }
    printf("get_string has been called and it has returned this: %s\n", get_string(destptr));
}
ADD_CMD("gets", getString, "This function should get a string and pass it into ARM assembly");


char * bc_Game(int delay, char * pattern, int target);

void bcGame(int action)
{

    uint32_t led_delay;
    int fetch_status1;
    fetch_status1 = fetch_uint32_arg(&led_delay);
    if(fetch_status1) {
    // Use a default value
    led_delay = 0xFFFFFF;
    }   


    int fetch_status;
    char *destptr;
    fetch_status = fetch_string_arg(&destptr);

    if(fetch_status) {
        //default logic here
    }

    uint32_t target;
    int fetch_status2;
    fetch_status2 = fetch_uint32_arg(&target);
    if(fetch_status2) {
    // Use a default value
    target = 1;
    }
    printf("function has been called and it has returned this: %s\n", bc_Game(led_delay, destptr, target));
}
ADD_CMD("bcGame", bcGame, "This function should get a string and pass it into ARM assembly");