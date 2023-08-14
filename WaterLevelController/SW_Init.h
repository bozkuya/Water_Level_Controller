

#include <stdint.h>
#include <TM4C123GH6PM.h>       

void	SW_Init(){
		
	SYSCTL->RCGCGPIO |= 0x02 ;  								/* START CLOCK FOR PORT B */
	
	while( (SYSCTL->PRGPIO & 0x02) == 0x00 ) ;	/* WAIT FOR PORT B TO STABILIZE*/
	
	GPIOB->DEN |= 0x01 ;  // DEN PB0
	
	GPIOB-> DIR &= ~0x1 ;  // PB0 INPUT
		
	GPIOB->AFSEL &= ~0x1 ; //	PB0 no alternative function
		
}


/*	RETURN 1 IF BUTTON PRESSED
		ELSE RETURN 0
		DEBOUNCING IS IMPLEMENTED
*/
int	readSW(){

	if	( GPIOB->DATA & 0x1 ){  //BASIC SOFTWARE DEBOUNCING	
		msDelay(100);
		return (GPIOB->DATA & 0x1 );
	}
	return 0;
		
}