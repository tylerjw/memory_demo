/*
 * memory_demo.xc
 *
 *  Created on: Mar 13, 2014
 *      Author: tylerjw
 */
#include <platform.h>
#include <stdio.h>
#include <xs1.h>
#include <uart.h>

out port addr = on tile[0]:XS1_PORT_32A;
port data = on tile[0]:XS1_PORT_8B;
out port bus_sw = on tile[0]:XS1_PORT_1H;
out port cam_oe_we = on tile[0]:XS1_PORT_4E;
out port ce1 = on tile[0]:XS1_PORT_1I;
out port ce2 = on tile[0]:XS1_PORT_1L;

#define WE  0b1000
#define OE  0b0100

void mem1_write(int start_addr, unsigned char d) {
    // write some data (write wave form 1, ce controlled)
    // bus switch high (off)
    bus_sw <: 0;
    // oe high, we low
    cam_oe_we <: OE;
    // ce high for unused data chip
    ce2 <: 1;
    // start loop
    // ce high
    ce1 <: 1;
    // write address
    addr <: start_addr;
    // write data
    data <: d;
    // ce low (data writes)
    ce1 <: 0;
    // end loop
}

unsigned char mem1_read(int start_addr) {
    // read some data
    unsigned char d;
    // bus switch high (off)
    bus_sw <: 0;
    // ce high (off) for unusued data chip
    ce2 <: 1;
    // we high (off), oe low
    cam_oe_we <: WE;
    // ce low (on) for used data chip
    ce1 <: 0;
    // start loop
    // write address
    addr <: 0;
    // read data
    data :> d;
    // end loop

    return d;
}

void memory_thread(void) {
    char c;
    timer t;
    int time;
    t :> time;

    while(1) {
        // write some data (write wave form 1, ce controlled)
        // bus switch high (off)
        bus_sw <: 0;
        // oe high, we low
        cam_oe_we <: OE;
        // ce high for unused data chip
        ce2 <: 1;
        // start loop
        // ce high
        ce1 <: 1;
        // write address
        addr <: 0;
        // write data
        data <: 'a';
        // ce low (data writes)
        ce1 <: 0;
        // end loop

        // read some data
        // bus switch high (off)
        bus_sw <: 0;
        // ce high (off) for unusued data chip
        ce2 <: 1;
        // we high (off), oe low
        cam_oe_we <: WE;
        // ce low (on) for used data chip
        ce1 <: 0;
        // start loop
        // write address
        addr <: 0;
        // read data
        data :> c;
        // end loop

        printf("Character recieved: %c - %d\r\n", c, (int)c);

        // delay
        time += 1000 * 1000 * 100 * 2;
        t when timerafter(time) :> void;
    }
}

int main() {
    par {
        on tile[0]:memory_thread();
    }
    return 0;
}
