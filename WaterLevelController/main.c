#include "SW_Init.h"
#include "LEDnMotorDriver.h"
#include "setLimitInitialization.h"
#include "WaterLevelSensorInitialization.h"
#include "periodicRead.h"
#include "TM4C123GH6PM.h"
#include "stdio.h"



int main(){
		SW_Init();												//MODE SELECTION
		LEDnMotorInitialization();
		WaterSensor_ADC_Initialization(); //WATER SENSOR INPUT
		setLimit_ADC_Initialization(); 		//POT INPUT
		
	
		/*GENERAL PURPOSE TIMERS DO NOT WORK AS INTENTED!!!!*/
		//periodicReadInitialization();		//PERIODIC SENSOR READ
		//Time1A_1sec_delay();
		sysTick_1sec_delay();
		/**********************/
		
	
		/*	LCD INITIALIZATIONS	*/
		LCD_Init();
		LCD_Clear();
		setLocation(0,0);
		sendSTRING("Upper Limit:\4");
		setLocation(0,1);
		sendSTRING("Lower Limit:\4");
		setLocation(0,2);
		sendSTRING("Curr Level :\4");
		setLocation(0,3);
		num2str(9,str);
		sendSTRING(str);
		setLocation(0,5);
		num2str(5,str);
		sendSTRING(str);
		
		/* SETTING THE PLOT GRAPH */
		setLocation(12,3);
		sendBYTE(0xFF);
		setLocation(12,4);
		sendBYTE(0xFF);
		setLocation(12,5);
		sendBYTE(0xFF);
		for(int i=0 ; i<64 ; i++)
			sendBYTE(0x80);
		/**********************/
	
		while(1){
		
			switch (state){
				case 0:
					if(modeChangeFlag){  					/*FOR MODE HIGHLIGHTING*/
					setLocation(0,1);							
					sendSTRING("Lower Limit\4");	
					modeChangeFlag=0;
					}									
					break;

				case 1:
					if(modeChangeFlag){						/*FOR MODE HIGHLIGHTING*/
					setLocation(0,0);
					sendSTRINGinverse("Upper Limit\4");
					modeChangeFlag=0;
					}															//******
				
					highLimit = readLimits()/100 + 50; //MAP VALUES 10 - 20
					setLocation(70,0);
					num2str(highLimit,str);
					sendSTRING( str );
					
					break;
				
				case 2:
					if(modeChangeFlag){						/*FOR MODE HIGHLIGHTING*/
						setLocation(0,0);
						sendSTRING("Upper Limit\4");
						setLocation(0,1);
						sendSTRINGinverse("Lower Limit\4");
						modeChangeFlag=0;         //****************
					}
					lowLimit = readLimits()/100 + 50; //MAP VALUES 10 - 20
					setLocation(70,1);
					num2str(lowLimit,str);
					sendSTRING( str );
					
					break;
		
				default:
					break;			
			}
			
			if( readSW() ){
				modeChangeFlag=1;
				msDelay(500); //BLOCK UNCONTROLLED INCREASE
				if(state<2)	state++;
				else				state=0;
			}
		
			if(sensorFlag){
					/*
					READ VALUE INTO BUFFER HERE AND INCREASE CURRENT BUFFER SIZE
					WHEN REACHED MAX SIZE, TAKE AVERAGE OF THE VALUE
					*/
					
					buffer[currentBufferSize] = readWaterLevel() ;	//READ MEASUREMENT
					currentBufferSize++;														//INCREASE SIZE
					
					
					/* DECIDE WHAT HAPPENS WHEN BUFFER[256] IS FULL */
					if(currentBufferSize>=255){
						currentBufferSize=0;
						int iterate = 0;
						currLevel= 0;
						for(iterate=0 ; iterate < 256 ; iterate++){
							currLevel += buffer[iterate];

						}
						
						currLevel /= 256;
						currLevel = currLevel/22 + 50; //MAP VALUES 5 - 9
						
						/* 	Water Sensor changes it's behaviour time to time 
						*		so we mitigate the errors due to this by setting 
						* 	a cap value */
						if(currLevel>99)	currLevel=99;
						
						sprintf(str,"value: %d \n\r\4",currLevel);
						OutStr(str);
						
						setLocation(70,2);
						num2str(currLevel,str);
						sendSTRING( str );
						updateLED();
						plotGraph( (currLevel-48) /2 +2 ,plotCounter);
						plotCounter++;
						if (plotCounter>=80)	plotCounter=13;
						
					}
					sensorFlag=0;
			}
		
		
		}	
}
