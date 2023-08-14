#include <TM4C123GH6PM.h>     

/*
	PF1->RED LED   | FILL MOTOR
	PF2->BLUE LED  | DRAIN MOTOR
	PF3->GREEN LED | NO MOTOR

*/

void LEDnMotorInitialization(){
	SYSCTL->RCGCGPIO |= 0x20; //turn on bus clock for PORT F
	while( (SYSCTL->PRGPIO & 0x20)  == 0x00 ) ; // WAIT UNTIL PORTF CLK IS READY
	
	GPIOF->DIR |= 0x0E	; //set PF1-3 as output
	GPIOF->DEN |= 0x0E	; //enable PF1-3 digital pin
	
}

