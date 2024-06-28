#include <xil_misc_psreset_api.h>
#ifndef XSLCR_FPGA_RST_CTRL_ADDR
#define XSLCR_FPGA_RST_CTRL_ADDR (XSLCR_BASEADDR + 0x00000240U)
#endif
#ifndef XSLCR_LOCK_ADDR
#define XSLCR_LOCK_ADDR (XSLCR_BASEADDR + 0x4)
#endif
#ifndef XSLCR_LOCK_CODE
#define XSLCR_LOCK_CODE 0x0000767B
#endif

#define BASE_ADDRESS 0x43C80000

#include "platform.h"
#include "xil_printf.h"
#include "xuartps_hw.h"
#include "stdlib.h"
#include "xtime_l.h"

int main()
{
	XTime seed;
	init_platform();
//    Xil_ICacheDisable();
//    Xil_DCacheDisable();
	XTime_GetTime(&seed);
	srand(seed);
	int rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
	rand_num = rand() % 64;
	xil_printf("experiment seed num : %d\r\n",rand_num);
  
    return 0;
}
