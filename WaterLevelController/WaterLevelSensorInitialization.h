#include "TM4C123GH6PM.h"



/* SET PE3 AS ADC
	FOR WATER SENSOR*/
void WaterSensor_ADC_Initialization () {
	
	SYSCTL->RCGCGPIO |= 0x10; //START CLOCK FOR GPIOE
	while( (SYSCTL->PRGPIO & 0x10) == 0x00 ) ;	/* WAIT FOR PORT E TO STABILIZE*/
	
	
	/* SET PE3 AS ADC */
	GPIOE->DIR |= 0x08;
	GPIOE->AMSEL |= 0x08;
	GPIOE->AFSEL |= 0x08;
	
	SYSCTL->RCGCADC |= 0x1;  									/* START CLOCK FOR ADC0 */
	while( (SYSCTL->PRADC & 0x01) == 0x00 ) ;	/* WAIT FOR ADC0 TO STABILIZE*/


	ADC0->ACTSS &= 0x00; 			// DISABLE SAMPLER TO CONFIGURE IT  ***LAB MANUAL SAYS ONYL CONFIGURE BIT 3
	ADC0->EMUX &=  0x0FFF; 		// CONFIGURE THAT SAMPLE TRIGERRING IS BY SOFTWARE FOR SAMPLER3	
	ADC0->SSMUX3 &= 0x0 ; 		//TELL MUXSELECT3 TO TAKE INPUT FROM AIN0 ***IT IS 0 ALREADY SO NO NEED TO SET	
	ADC0 -> SSCTL3 |= 0x06; 	//INTERRUPT ENABLE AND FIRST SAMPLE IS LAST SAMPLE
	ADC0->PC = 0x01;
	ADC0->ACTSS |= 0x08; 			// ENABLE SAMPLER3
	ADC0->PSSI |= 0x08;				// TELL SAMPLER TO START SAMPLING
	
}

uint32_t readWaterLevel(){
	
	uint32_t value;
	ADC0->PSSI |= 0x08; //start run
	while (  (ADC0->RIS & 0x08) != 0x08  )  ; 	//INTERRUPT RAISED AND SAMPLE TAKEN 
	value = ADC0->SSFIFO3 ;	//READ MEASUREMENT
	ADC0->ISC |= 0x08;  												//CLEAR INTERRUPT
	
	return value;
}