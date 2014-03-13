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
#include <memory.h>

int main() {
    par {
        on tile[0]:memory_test_full_write();
    }
    return 0;
}
