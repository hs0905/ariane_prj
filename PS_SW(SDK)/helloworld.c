#include <xil_misc_psreset_api.h>
#ifndef XSLCR_FPGA_RST_CTRL_ADDR
#define XSLCR_FPGA_RST_CTRL_ADDR (XSLCR_BASEADDR + 0x00000240U)
#endif
#ifndef XSLCR_LOCK_ADDR
#define XSLCR_LOCK_ADDR (XSLCR_BASEADDR + 0x4)
#endif
#ifndef XSLCR_LOCK_CODE
#define XSLCR_LOCK_CODE 					0x0000767B
#endif

#include "platform.h"
#include "xil_printf.h"
#include "xuartps_hw.h"
#include "string.h"
#include "xil_cache.h"

#define CMD_DONE_ADDRESS 					0x43C80000
#define CMD_ADDRESS 							0x43C80004
#define DATA_ADDRESS_REGNUM				0x43C80008
#define DATA_ADDRESS_BITNUM				0x43C8000C
// #define PROGRAM_COUNTER_ADDRESS		0x43C8001C
#define RESET_FLAG_ADDRESS				0x17FFFFF0
#define STATE_LOCK_CMD_ADDRESS    0x43c8001c

// ===================================================
// Change This Area
// ===================================================
#define ARIANE_TEXT_ADDRESS						0x200000
//#define ARIANE_TEXT_SIZE							0xed96
#define ARIANE_TEXT_SIZE							0xea48

//#define ARIANE_RODATA_STR1_8_ADDRESS	0x20F7c0
//#define ARIANE_RODATA_STR1_8_SIZE			0x400
#define ARIANE_RODATA_STR1_8_ADDRESS	0x20F470
#define ARIANE_RODATA_STR1_8_SIZE			0x348

//#define BSS_ADDRESS										0x20fbc0
//#define BSS_SIZE											0x648
#define BSS_ADDRESS										0x20f7b8
#define BSS_SIZE											0x648

//#define ARIANE_RODATA_ADDRESS					0x20ed98
//#define ARIANE_RODATA_SIZE						0xA24
#define ARIANE_RODATA_ADDRESS					0x20ea48
#define ARIANE_RODATA_SIZE						0xA24

//====================================================
// NO TOUCH HERE
//====================================================
#define SPARE_TEXT_ADDRESS						0x17FAFE00
#define SPARE_RODATA_STR1_8_ADDRESS		0x17FBEBB4
#define SPARE_RODATA_ADDRESS					0X17FBEFCC

#define HOST_IP_ADDR							(XPAR_NVMEHOSTCONTROLLER_0_BASEADDR)

#define DEV_IRQ_MASK_REG_ADDR			(HOST_IP_ADDR + 0x4)
#define DEV_IRQ_CLEAR_REG_ADDR		(HOST_IP_ADDR + 0x8)
#define DEV_IRQ_STATUS_REG_ADDR		(HOST_IP_ADDR + 0xC)
#define IO_WRITE32(addr, val)		*((volatile unsigned int *)(addr)) = val
#define IO_READ32(addr)					*((volatile unsigned int *)(addr))
typedef struct _DEV_IRQ_REG
{
	union {
		unsigned int dword;
		struct {
			unsigned int pcieLink				:1;
			unsigned int busMaster			:1;
			unsigned int pcieIrq				:1;
			unsigned int pcieMsi				:1;
			unsigned int pcieMsix				:1;
			unsigned int nvmeCcEn				:1;
			unsigned int nvmeCcShn			:1;
			unsigned int mAxiWriteErr		:1;
			unsigned int mAxiReadErr		:1;
			unsigned int pcieMreqErr		:1;
			unsigned int pcieCpldErr		:1;
			unsigned int pcieCpldLenErr	:1;
			unsigned int reserved0			:20;
		};
	};
} DEV_IRQ_REG;

void mem_migration()
{
	memset((void*)SPARE_TEXT_ADDRESS, 					0, ARIANE_TEXT_SIZE);
	memset((void*)SPARE_RODATA_STR1_8_ADDRESS, 	0, ARIANE_RODATA_STR1_8_SIZE);
	memset((void*)SPARE_RODATA_ADDRESS, 				0, ARIANE_RODATA_SIZE);

	memcpy((void*)SPARE_TEXT_ADDRESS, 					(const void*)ARIANE_TEXT_ADDRESS, 					ARIANE_TEXT_SIZE);
	memcpy((void*)SPARE_RODATA_STR1_8_ADDRESS, 	(const void*)ARIANE_RODATA_STR1_8_ADDRESS, 	ARIANE_RODATA_STR1_8_SIZE);
	memcpy((void*)SPARE_RODATA_ADDRESS, 				(const void*)ARIANE_RODATA_ADDRESS, 				ARIANE_RODATA_SIZE);
}

void mem_recovery()
{
	memcpy((void*)ARIANE_TEXT_ADDRESS, 					(const void*)SPARE_TEXT_ADDRESS, 						ARIANE_TEXT_SIZE);
	memcpy((void*)ARIANE_RODATA_STR1_8_ADDRESS, (const void*)SPARE_RODATA_STR1_8_ADDRESS, 	ARIANE_RODATA_STR1_8_SIZE);
	memcpy((void*)ARIANE_RODATA_ADDRESS, 				(const void*)SPARE_RODATA_ADDRESS, 					ARIANE_RODATA_SIZE);
}

void dev_irq_init()
{
	DEV_IRQ_REG devReg;

	devReg.dword 				= 0;
	devReg.pcieLink 			= 1;
	devReg.busMaster 			= 1;
	devReg.pcieIrq 				= 1;
	devReg.pcieMsi 				= 1;
	devReg.pcieMsix 			= 1;
	devReg.nvmeCcEn 			= 1;
	devReg.nvmeCcShn 			= 1;
	devReg.mAxiWriteErr 		= 1;
	devReg.pcieMreqErr 			= 1;
	devReg.pcieCpldErr 			= 1;
	devReg.pcieCpldLenErr 		= 1;

	IO_WRITE32(DEV_IRQ_MASK_REG_ADDR, devReg.dword);
}

void fpga_reset()
{
	printf("-------%lu",(void*)Xil_In32(RESET_FLAG_ADDRESS));
	printf("\r\n");

	usleep(10000);
// write unlock code to the unlock address to allow writes to other SLCR registers
	Xil_Out32(XSLCR_UNLOCK_ADDR, XSLCR_UNLOCK_CODE);
	uint32_t oldValue = Xil_In32(XSLCR_FPGA_RST_CTRL_ADDR) & ~0x0F;
	Xil_Out32(XSLCR_FPGA_RST_CTRL_ADDR, oldValue | 0x0F);


	usleep(10000);
	Xil_Out32(XSLCR_FPGA_RST_CTRL_ADDR, oldValue | 0x00);
	Xil_Out32(XSLCR_LOCK_ADDR, XSLCR_LOCK_CODE);

	usleep(15);

	cleanup_platform();
}
int bits[1024] = {10,25,29,0,19,17,5,17,5,22,24,19,28,26,26,12,23,30,10,5,0,16,22,4,16,12,23,6,27,7,18,29,28,31,20,10,15,17,23,2,11,27,24,13,26,19,20,6,20,13,3,9,6,20,8,28,20,8,16,26,1,19,3,27,31,29,28,3,1,22,10,5,20,9,25,6,4,22,16,22,27,23,19,21,20,3,10,8,31,12,5,20,13,28,14,18,16,19,23,1,13,28,10,2,23,24,21,21,31,4,23,28,22,10,14,23,18,1,31,21,22,14,25,26,27,9,0,1,5,21,24,13,17,8,24,23,24,29,19,10,3,21,10,31,10,3,0,7,13,9,19,4,28,7,11,17,24,11,31,14,3,16,17,8,29,6,19,9,20,22,0,17,13,23,26,9,3,29,4,15,6,22,11,31,6,15,18,2,27,20,17,13,5,22,24,5,26,31,12,1,16,9,4,18,24,15,6,13,28,3,22,20,27,22,14,31,14,12,30,8,21,17,14,24,15,10,4,29,5,29,10,15,19,11,21,11,24,2,0,31,26,1,8,31,5,3,7,29,18,15,2,16,1,9,6,9,9,0,11,15,31,14,17,3,23,21,26,21,8,31,15,23,6,14,11,16,19,19,6,13,4,9,10,4,8,11,14,25,7,1,25,27,18,19,26,16,25,15,19,13,12,20,27,21,18,21,31,11,24,27,11,15,27,16,8,22,31,27,14,28,20,19,19,17,13,24,25,31,1,26,14,28,3,5,13,7,2,26,4,1,8,4,23,12,2,25,31,17,28,0,26,26,27,14,27,6,7,22,17,27,25,23,30,25,0,31,29,13,31,20,16,25,18,9,21,17,28,11,1,22,4,21,5,4,29,25,10,21,27,14,29,21,21,5,4,8,26,0,13,11,18,25,27,30,14,18,5,27,25,9,10,16,1,25,11,5,9,16,17,19,13,9,12,29,15,5,12,21,27,10,10,20,1,2,5,19,11,29,13,23,27,17,21,1,9,30,20,28,10,13,18,22,2,24,29,20,12,21,20,18,25,18,21,27,25,28,30,16,27,29,11,1,15,4,9,22,8,20,11,25,25,27,28,5,19,16,11,2,0,15,25,26,31,17,0,31,2,19,22,7,4,31,17,10,30,16,28,9,21,14,28,11,16,11,2,15,2,13,19,16,19,25,0,7,11,16,27,10,1,8,19,0,21,18,19,31,8,1,24,17,24,23,31,6,28,25,27,27,15,25,15,0,10,16,21,22,16,6,21,31,18,10,20,23,21,2,9,28,18,23,13,6,20,23,2,19,31,16,7,1,12,21,6,17,27,27,21,4,29,7,24,31,23,20,4,4,31,9,2,5,16,7,23,2,21,1,8,3,8,2,15,6,5,25,25,3,19,13,21,4,4,19,17,31,30,28,8,0,23,21,1,24,25,15,17,20,27,26,26,6,0,28,15,18,1,1,6,31,10,11,24,25,17,7,11,2,31,0,31,14,1,22,12,13,22,10,13,15,10,18,20,5,13,26,0,22,10,20,31,0,4,6,25,26,0,22,28,0,1,31,14,7,0,24,8,27,10,26,15,4,28,23,0,12,2,21,2,25,24,7,28,7,25,16,25,14,25,30,25,26,12,27,0,28,8,8,31,19,8,10,5,17,24,2,6,24,6,1,7,17,30,18,21,10,15,20,22,17,0,18,1,13,27,7,13,9,27,11,14,3,11,5,12,10,16,19,12,7,12,7,13,6,17,3,12,9,19,0,8,14,21,8,6,20,12,29,4,14,2,7,29,22,2,2,25,11,4,21,12,7,28,21,11,1,24,28,9,5,30,26,15,28,24,7,30,19,19,31,22,4,0,5,0,9,25,10,11,16,16,12,0,7,14,13,5,30,12,28,25,31,7,14,9,25,24,8,25,4,3,15,5,17,22,29,19,31,26,2,29,20,29,26,9,15,6,24,5,17,22,13,31,12,29,28,17,1,3,11,25,15,0,7,13,5,3,18,13,12,12,13,9,28,10,16,14,16,6,31,31,5,11,26,22,30,17,27,7,31,12,16,19,21,11,6,4,14,19,4,7,22,21,4,8,16,30,24,17,5,6,13,16,18,13,19,11,18,25,2,8,29,12,13,16,9,16,26,9,0,12,4,12,26,22,17,19,19,8,26,30,9,1,30,25,9,12,27,20,22,16,23,29,20,18,12,27,19,20,5,31,7,0,26,17,24,12,14,28,28,16,21,21,30,9,11,12,11,3,5,26,23,22,20,12,24,26,15,6,19,13,19,6,9,7,9,11,28,26,20,17,22,31,3,2,28};
int regs[1024] = {11,14,7,20,5,26,13,1,4,22,9,1,27,28,27,18,22,5,18,5,19,26,11,1,8,22,17,10,8,31,5,16,31,13,24,1,5,4,2,13,25,7,9,2,2,25,20,22,24,17,18,24,3,14,10,10,16,2,15,23,14,22,17,3,30,28,14,12,18,2,10,11,27,28,1,7,4,1,29,28,25,12,6,4,16,17,25,13,28,14,20,22,16,20,23,12,12,19,5,25,24,6,3,20,2,10,16,22,21,5,26,19,10,8,29,28,23,26,25,20,5,16,3,16,3,30,30,9,19,18,13,10,14,8,18,9,9,2,15,28,21,25,11,25,24,6,1,5,2,8,7,21,14,21,9,29,15,19,13,17,11,23,28,3,31,23,6,29,20,14,23,28,8,27,7,4,24,29,31,17,15,28,6,15,17,2,1,30,16,17,17,7,5,24,1,10,8,21,20,3,15,18,18,29,27,11,16,4,17,5,17,5,8,13,26,15,7,23,14,9,20,17,10,23,20,26,26,1,30,8,3,24,12,23,19,22,11,20,30,27,13,6,9,24,12,31,16,13,17,13,2,26,30,28,4,9,21,13,15,2,1,1,8,22,15,27,5,13,11,15,30,24,14,18,14,26,18,15,9,26,4,27,19,23,11,16,6,10,24,14,3,13,19,7,15,28,22,26,24,8,29,12,26,22,10,21,21,9,7,5,25,16,22,22,4,24,27,11,9,31,15,12,3,22,1,20,11,5,24,17,17,8,14,4,24,5,8,6,9,9,27,16,23,15,11,1,9,30,12,17,17,11,30,5,18,29,16,13,19,23,19,16,30,19,1,30,16,15,16,11,2,9,27,25,20,15,29,11,10,9,7,14,12,8,8,11,6,10,24,2,3,18,29,25,29,12,28,22,12,10,12,14,28,1,10,11,8,3,3,20,21,16,31,26,25,2,18,8,28,15,29,16,23,17,13,26,22,23,27,27,25,27,14,28,15,8,18,30,26,2,9,19,20,2,27,15,19,7,5,14,17,15,3,9,25,22,20,26,4,19,27,5,15,1,6,2,29,9,2,5,6,22,19,6,16,24,18,4,3,9,21,14,15,22,8,16,21,5,20,30,18,16,19,29,24,11,13,7,21,3,2,2,1,22,25,28,19,15,19,10,10,6,13,2,22,2,17,29,13,15,8,13,28,6,30,23,3,10,30,19,22,28,24,10,20,10,16,11,15,12,26,4,4,1,4,17,14,25,19,26,2,30,28,28,14,8,12,3,20,25,18,17,4,27,6,3,11,7,16,23,20,5,21,1,29,26,29,14,3,12,19,24,1,15,24,12,5,11,25,27,8,3,24,25,7,2,9,3,8,13,29,12,12,18,28,25,21,22,29,24,6,26,19,11,2,10,12,22,16,18,10,21,3,31,16,6,27,27,17,4,31,5,18,17,4,21,21,27,10,20,23,8,14,29,20,17,3,31,31,15,21,11,5,17,13,12,6,15,17,19,31,29,25,18,28,29,21,13,25,11,3,27,25,30,9,29,5,22,16,23,31,22,10,15,11,23,8,18,30,3,28,15,10,30,25,24,1,10,22,20,20,10,8,21,1,28,10,31,29,19,27,13,19,14,26,13,29,28,28,23,10,14,31,25,1,18,13,19,27,7,30,7,3,18,6,27,11,29,7,20,11,15,29,11,7,16,5,15,10,26,3,1,6,30,17,14,23,4,8,3,15,16,16,28,5,26,3,21,12,14,7,23,19,31,25,19,25,28,18,23,5,10,2,1,7,22,7,21,30,19,14,30,29,15,18,15,15,24,17,30,19,19,7,13,20,21,14,6,6,17,9,15,1,27,3,28,3,13,11,23,21,11,15,15,14,12,3,23,6,15,9,28,24,11,18,13,6,1,19,14,7,16,30,8,31,26,8,15,24,4,6,29,10,9,13,2,27,26,20,12,21,9,9,9,1,25,17,31,4,16,12,13,27,9,19,3,24,24,25,20,10,21,9,28,23,31,8,22,1,8,16,31,26,4,25,1,15,10,25,18,12,12,6,21,5,17,17,10,18,28,13,23,5,2,9,14,21,18,24,6,28,21,6,8,19,10,5,1,14,15,17,19,26,18,2,20,23,13,14,6,25,31,17,23,30,14,15,16,29,22,21,24,8,14,7,26,4,4,2,30,20,23,1,16,2,6,19,9,3,27,31,17,7,22,3,19,10,6,15,5,31,25,7,20,8,13,17,21,3,5,27,29,7,14,12,11,16,31,3,27,2,28,1,29,10,17,17,18,7,17,30,9,4,14,15,19,13,23,8,31,15,16,8,5};

int main()
{
	init_platform				();
	Xil_ICacheDisable		();
	Xil_DCacheDisable		();
	Xil_DCacheFlush			();
	Xil_ICacheInvalidate();
//
//    __asm__ volatile (".word 0x0000100f");

	printf("%lu",(void*)Xil_In32(RESET_FLAG_ADDRESS));
	printf("\r\n");

	if(Xil_In32(RESET_FLAG_ADDRESS) != 85465)
	{
		mem_migration();
		printf("mem_migration done\r\n");

	}else if(Xil_In32(RESET_FLAG_ADDRESS) == 85465)
	{
		Xil_Out32(RESET_FLAG_ADDRESS,0);
		mem_recovery();
		printf("mem_recovery done\r\n");
	}
		Xil_Out32(STATE_LOCK_CMD_ADDRESS, 0x1); // lock the state to idle
		fpga_reset();
		Xil_Out32(STATE_LOCK_CMD_ADDRESS, 0x0); // unlock the state
    return 0;
}