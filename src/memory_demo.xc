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

void mem2_write(unsigned int start_addr, unsigned char d[n], unsigned n) {
    // write some data (write wave form 1, ce controlled)
    // bus switch high (off)
    bus_sw <: 0;
    // oe high, we low
    cam_oe_we <: OE;
    // ce high for unused data chip
    ce1 <: 1;
    // start loop
    for(int i = 0; i < n; i++) {
        // ce high
        ce2 <: 1;
        // write address
        addr <: start_addr + i;
        // write data
        data <: d[i];
        // ce low (data writes)
        ce2 <: 0;
    }
}

void mem2_read_init() {
    // bus switch high (off)
    bus_sw <: 0;
    // ce high (off) for unusued data chip
    ce1 <: 1;
    // we high (off), oe low
    cam_oe_we <: WE;
    // ce low (on) for used data chip
    ce2 <: 0;
}

unsigned char mem_read_byte(unsigned int start_addr) {
    // read some data, wave form 1
    unsigned char d;

    // start loop
    // write address
    addr <: start_addr;
    // increase addresss (delay the correct amount of time )
    start_addr += 1;
    // get data
    data :> d;
    // end loop

    return d;
}

void mem_read(unsigned int start_addr, unsigned char buffer[n], unsigned int n) {
    // read some data, wave form 1
    unsigned char d;

    // start loop
    for(int i = 0; i < n; i++) {
        // write address
        addr <: start_addr;
        // increase addresss (delay the correct amount of time )
        start_addr += 1;
        // get data
        data :> buffer[i];
        // end loop
    }

    return d;
}

void memory_thread(void) {
    int write_len = 11;
    unsigned char out_val[] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE,
                                    0xFF, 0x00, 0x11, 0x22, 0x33, 0x44};
    unsigned char in_val[12];
    unsigned int start_addr = 1;
    timer t;
    int time;
    t :> time;

    while(1) {
        mem2_write(start_addr, out_val, write_len);
        mem2_read_init();
        mem_read(start_addr, in_val, write_len);
        for(int i = 0; i < write_len; i++) {
            printf("in_val[%d] = 0x%0X\r\n", i, in_val[i]);
        }
        printf("\n");

        // delay
        time += 1000 * 1000 * 100 * 5;
        t when timerafter(time) :> void;
    }
}

int main() {
    par {
        on tile[0]:memory_thread();
    }
    return 0;
}
