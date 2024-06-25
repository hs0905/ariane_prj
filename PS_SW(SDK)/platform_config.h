#ifndef __PLATFORM_CONFIG_H_
#define __PLATFORM_CONFIG_H_

#define STDOUT_IS_PS7_UART
#define UART_DEVICE_ID 0
#endif
#define STDOUT_BASEADDRESS      0xE0001000
#define XUARTPS_CR_TXRST 				0x00000002U 	/**< TX logic reset */
#define XUARTPS_CR_RXRST 				0x00000001U 	/**< RX logic reset */
#define XUARTPS_CR_OFFSET 			    0x0000U		 	/**< Control Register */
