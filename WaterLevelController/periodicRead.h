#include "TM4C123GH6PM.h"
#include "stdio.h"

#define SAMPLE_PERIOD 0xFFFFFFFF //in us


void	updateLED(void);

int currentBufferSize=0;
uint32_t buffer[256];
uint32_t currLevel;
char str[100];

uint8_t	plotCounter=13;

int state=0;
uint32_t lowLimit=0;
uint32_t highLimit=0;

uint8_t sensorFlag=0;
uint8_t modeChangeFlag=0;



void num2str(int num,char* msg){
	sprintf(msg,"%d\4",num);
}

void Delay(int delay_ms){
	delay_ms*=4000;
	while(delay_ms > 0)
		delay_ms--; 
}  




/* ENABLE TIMER0  [PB6]   */
void periodicReadInitialization(){
	
	volatile int *NVIC_EN0 = (volatile int*) 0xE000E100;
	volatile int *NVIC_PRI4 = (volatile int*) 0xE000E410;
	
	SYSCTL->RCGCTIMER	|=0x01; 						 // Start timer0
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	//SYSCTL->PRTIMER
	
	TIMER0->CTL			=0; 										//Disable timer during setup
	TIMER0->CFG			=0x04;  								//Set 16 bit mode
	TIMER0->TAMR		=0x02; 									// set to periodic, count down
	TIMER0->TAILR		= 64000-1 ;//SAMPLE_PERIOD; 				//Set interval load to determine time
	TIMER0->TAPR		= 250-1  ;      //0xFF;   									// Divide the clock by 16 to get 1us
	TIMER0->IMR			=0x01; 									//Enable timeout intrrupt	
	
	//Timer0A is interrupt 19
	//Interrupt 16-19 are handled by NVIC register PRI4
	//Interrupt 19 is controlled by bits 31:29 of PRI4
	*NVIC_PRI4 &=0x0FFFFFFF; //Clear interrupt 19 priority
	*NVIC_PRI4 |=0x40000000; //Set interrupt 19 priority to 2
	
	
	//NVIC has to be enabled
	//Interrupts 0-31 are handled by NVIC register EN0
	//Interrupt 19 is controlled by bit 19
	*NVIC_EN0 |=0x00080000;
	
	//Enable timer
	TIMER0->CTL			 |=0x03; // bit0 to enable and bit 1 to stall on debug
	return;
}


/*  WHAT HAPPENS PERIODICALLY   */
void TIMER0A_Handler (void){ //PB6 PORT IS TIMER0A
	
	OutStr("BAM!\n\r\4");
	
}


/* ENABLE TIMER1A  [PB4]   */
void Time1A_1sec_delay(void){
	SYSCTL->RCGCTIMER |= (1<<1);
		__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
		__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
		__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	TIMER1->CTL = 0;
	TIMER1->CFG = 0x0;
	TIMER1->TAMR=0x02;
	TIMER1->TAPR=10;			//250-1;
	TIMER1->TAILR=64000000-1;
	TIMER1->ICR=0x1;
	TIMER1->IMR|=(1<<0);
	TIMER1->CTL|=0x01;
	NVIC->ISER[0] |= (1<<21);
	
}
void TIMER1A_Handler(){
	OutStr("BAM!\n\r\4");
}
void	sysTick_1sec_delay(){
	SysTick->LOAD = 7999; 	//200sample/sec   | 15999999-> 1 sec
	SysTick->CTRL = 7;
	SysTick->VAL=0;
}
void SysTick_Handler(void){

	sensorFlag=1;
	
}

void	updateLED(){
	
	if(currLevel>highLimit){ // BLUE LED
		GPIOF->DATA &= ~0x0E;
		GPIOF->DATA |= 0x04;
	}
		
	else if (currLevel<lowLimit){ // RED LED
		GPIOF->DATA &= ~0x0E;
		GPIOF->DATA |= 0x02;
	}

		else{ //GREEN LED
			GPIOF->DATA &= ~0x0E;
			GPIOF->DATA |= 0x08;
		}
		
}