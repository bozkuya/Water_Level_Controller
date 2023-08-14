		
;***************************************************************
; Screen <-> SSI0
; PA2 - SSI0CLK
; PA3 - SSI0Fss
; PA4 - SSI0Rx
; PA5 - SSI0Tx
; PA6 - RESET
; PA7 - D/C
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
;GPIO Registers
GPIO_PORTA_DATA			EQU	0x400043FC	; Port A Data
GPIO_PORTA_IM      		EQU 0x40004010	; Interrupt Mask
GPIO_PORTA_DIR   		EQU 0x40004400	; Port Direction
GPIO_PORTA_AFSEL 		EQU 0x40004420	; Alt Function enable
GPIO_PORTA_DEN   		EQU 0x4000451C	; Digital Enable
GPIO_PORTA_AMSEL 		EQU 0x40004528	; Analog enable
GPIO_PORTA_PCTL  		EQU 0x4000452C	; Alternate Functions
;SSI Registers
SSI0_CR0				EQU	0x40008000
SSI0_CR1				EQU	0x40008004
SSI0_DR					EQU	0x40008008
SSI0_SR					EQU	0x4000800C
SSI0_CPSR				EQU	0x40008010
SSI0_CC					EQU	0x40008FC8	
	
;System Registers
SYSCTL_RCGCGPIO  		EQU 0x400FE608	; GPIO Gate Control
SYSCTL_RCGCSSI			EQU	0x400FE61C	; SSI Gate Control
SYSCTL_PRGPIO			EQU 0x400FEA08  ; GPIO Ready State
SYSCTL_PRSSI			EQU 0x400FEA1C	; SSI Ready State
;***************************************************************
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA    	routines, READONLY, CODE
				THUMB

; ASCII table 
ASCII		DCB		0x00, 0x00, 0x00, 0x00, 0x00 ; 20
			DCB		0x00, 0x00, 0x5f, 0x00, 0x00 ; 21 !
			DCB		0x00, 0x07, 0x00, 0x07, 0x00 ; 22 "
			DCB		0x14, 0x7f, 0x14, 0x7f, 0x14 ; 23 #
			DCB		0x24, 0x2a, 0x7f, 0x2a, 0x12 ; 24 $
			DCB		0x23, 0x13, 0x08, 0x64, 0x62 ; 25 %
			DCB		0x36, 0x49, 0x55, 0x22, 0x50 ; 26 &
			DCB		0x00, 0x05, 0x03, 0x00, 0x00 ; 27 '
			DCB		0x00, 0x1c, 0x22, 0x41, 0x00 ; 28 (
			DCB		0x00, 0x41, 0x22, 0x1c, 0x00 ; 29 )
			DCB		0x14, 0x08, 0x3e, 0x08, 0x14 ; 2a *
			DCB		0x08, 0x08, 0x3e, 0x08, 0x08 ; 2b +
			DCB		0x00, 0x50, 0x30, 0x00, 0x00 ; 2c ,
			DCB		0x08, 0x08, 0x08, 0x08, 0x08 ; 2d -
			DCB		0x00, 0x60, 0x60, 0x00, 0x00 ; 2e .
			DCB		0x20, 0x10, 0x08, 0x04, 0x02 ; 2f /
			DCB		0x3e, 0x51, 0x49, 0x45, 0x3e ; 30 0
			DCB		0x00, 0x42, 0x7f, 0x40, 0x00 ; 31 1
			DCB		0x42, 0x61, 0x51, 0x49, 0x46 ; 32 2
			DCB		0x21, 0x41, 0x45, 0x4b, 0x31 ; 33 3
			DCB		0x18, 0x14, 0x12, 0x7f, 0x10 ; 34 4
			DCB		0x27, 0x45, 0x45, 0x45, 0x39 ; 35 5
			DCB		0x3c, 0x4a, 0x49, 0x49, 0x30 ; 36 6
			DCB		0x01, 0x71, 0x09, 0x05, 0x03 ; 37 7
			DCB		0x36, 0x49, 0x49, 0x49, 0x36 ; 38 8
			DCB		0x06, 0x49, 0x49, 0x29, 0x1e ; 39 9
			DCB		0x00, 0x36, 0x36, 0x00, 0x00 ; 3a :
			DCB		0x00, 0x56, 0x36, 0x00, 0x00 ; 3b ;
			DCB		0x08, 0x14, 0x22, 0x41, 0x00 ; 3c <
			DCB		0x14, 0x14, 0x14, 0x14, 0x14 ; 3d =
			DCB		0x00, 0x41, 0x22, 0x14, 0x08 ; 3e >
			DCB		0x02, 0x01, 0x51, 0x09, 0x06 ; 3f ?
			DCB		0x32, 0x49, 0x79, 0x41, 0x3e ; 40 @
			DCB		0x7e, 0x11, 0x11, 0x11, 0x7e ; 41 A
			DCB		0x7f, 0x49, 0x49, 0x49, 0x36 ; 42 B
			DCB		0x3e, 0x41, 0x41, 0x41, 0x22 ; 43 C
			DCB		0x7f, 0x41, 0x41, 0x22, 0x1c ; 44 D
			DCB		0x7f, 0x49, 0x49, 0x49, 0x41 ; 45 E
			DCB		0x7f, 0x09, 0x09, 0x09, 0x01 ; 46 F
			DCB		0x3e, 0x41, 0x49, 0x49, 0x7a ; 47 G
			DCB		0x7f, 0x08, 0x08, 0x08, 0x7f ; 48 H
			DCB		0x00, 0x41, 0x7f, 0x41, 0x00 ; 49 I
			DCB		0x20, 0x40, 0x41, 0x3f, 0x01 ; 4a J
			DCB		0x7f, 0x08, 0x14, 0x22, 0x41 ; 4b K
			DCB		0x7f, 0x40, 0x40, 0x40, 0x40 ; 4c L
			DCB		0x7f, 0x02, 0x0c, 0x02, 0x7f ; 4d M
			DCB		0x7f, 0x04, 0x08, 0x10, 0x7f ; 4e N
			DCB		0x3e, 0x41, 0x41, 0x41, 0x3e ; 4f O
			DCB		0x7f, 0x09, 0x09, 0x09, 0x06 ; 50 P
			DCB		0x3e, 0x41, 0x51, 0x21, 0x5e ; 51 Q
			DCB		0x7f, 0x09, 0x19, 0x29, 0x46 ; 52 R
			DCB		0x46, 0x49, 0x49, 0x49, 0x31 ; 53 S
			DCB		0x01, 0x01, 0x7f, 0x01, 0x01 ; 54 T
			DCB		0x3f, 0x40, 0x40, 0x40, 0x3f ; 55 U
			DCB		0x1f, 0x20, 0x40, 0x20, 0x1f ; 56 V
			DCB		0x3f, 0x40, 0x38, 0x40, 0x3f ; 57 W
			DCB		0x63, 0x14, 0x08, 0x14, 0x63 ; 58 X
			DCB		0x07, 0x08, 0x70, 0x08, 0x07 ; 59 Y
			DCB		0x61, 0x51, 0x49, 0x45, 0x43 ; 5a Z
			DCB		0x00, 0x7f, 0x41, 0x41, 0x00 ; 5b [
			DCB		0x02, 0x04, 0x08, 0x10, 0x20 ; 5c '\'
			DCB		0x00, 0x41, 0x41, 0x7f, 0x00 ; 5d ]
			DCB		0x04, 0x02, 0x01, 0x02, 0x04 ; 5e ^
			DCB		0x40, 0x40, 0x40, 0x40, 0x40 ; 5f _
			DCB		0x00, 0x01, 0x02, 0x04, 0x00 ; 60 `
			DCB		0x20, 0x54, 0x54, 0x54, 0x78 ; 61 a
			DCB		0x7f, 0x48, 0x44, 0x44, 0x38 ; 62 b
			DCB		0x38, 0x44, 0x44, 0x44, 0x20 ; 63 c
			DCB		0x38, 0x44, 0x44, 0x48, 0x7f ; 64 d
			DCB		0x38, 0x54, 0x54, 0x54, 0x18 ; 65 e
			DCB		0x08, 0x7e, 0x09, 0x01, 0x02 ; 66 f
			DCB		0x0c, 0x52, 0x52, 0x52, 0x3e ; 67 g
			DCB		0x7f, 0x08, 0x04, 0x04, 0x78 ; 68 h
			DCB		0x00, 0x44, 0x7d, 0x40, 0x00 ; 69 i
			DCB		0x20, 0x40, 0x44, 0x3d, 0x00 ; 6a j
			DCB		0x7f, 0x10, 0x28, 0x44, 0x00 ; 6b k
			DCB		0x00, 0x41, 0x7f, 0x40, 0x00 ; 6c l
			DCB		0x7c, 0x04, 0x18, 0x04, 0x78 ; 6d m
			DCB		0x7c, 0x08, 0x04, 0x04, 0x78 ; 6e n
			DCB		0x38, 0x44, 0x44, 0x44, 0x38 ; 6f o
			DCB		0x7c, 0x14, 0x14, 0x14, 0x08 ; 70 p
			DCB		0x08, 0x14, 0x14, 0x18, 0x7c ; 71 q
			DCB		0x7c, 0x08, 0x04, 0x04, 0x08 ; 72 r
			DCB		0x48, 0x54, 0x54, 0x54, 0x20 ; 73 s
			DCB		0x04, 0x3f, 0x44, 0x40, 0x20 ; 74 t
			DCB		0x3c, 0x40, 0x40, 0x20, 0x7c ; 75 u
			DCB		0x1c, 0x20, 0x40, 0x20, 0x1c ; 76 v
			DCB		0x3c, 0x40, 0x30, 0x40, 0x3c ; 77 w
			DCB		0x44, 0x28, 0x10, 0x28, 0x44 ; 78 x
			DCB		0x0c, 0x50, 0x50, 0x50, 0x3c ; 79 y
			DCB		0x44, 0x64, 0x54, 0x4c, 0x44 ; 7a z
			DCB		0x00, 0x08, 0x36, 0x41, 0x00 ; 7b {
			DCB		0x00, 0x00, 0x7f, 0x00, 0x00 ; 7c |
			DCB		0x00, 0x41, 0x36, 0x08, 0x00 ; 7d }
			DCB		0x10, 0x08, 0x08, 0x10, 0x08 ; 7e ~
			
dotPlot		DCB		0x80, 0x00, 0x00  ; 0
			DCB		0xC0, 0x00, 0x00   ; 1
			DCB		0xA0, 0x00, 0x00    ; 2
			DCB		0x90, 0x00, 0x00    ; 3
			DCB		0x88, 0x00, 0x00    ; 4
			DCB		0x84, 0x00, 0x00    ; 5
			DCB		0x82, 0x00, 0x00    ; 6
			DCB		0x81, 0x00, 0x00    ; 7
			DCB		0x80, 0x80, 0x00    ; 8
			DCB		0x80, 0x40, 0x00    ; 9
			DCB		0x80, 0x20, 0x00    ; 10
			DCB		0x80, 0x10, 0x00    ; 11
			DCB		0x80, 0x08, 0x00    ; 12
			DCB		0x80, 0x04, 0x00    ; 13
			DCB		0x80, 0x02, 0x00    ; 14
			DCB		0x80, 0x01, 0x00    ; 15
			DCB		0x80, 0x00, 0x80    ; 16
			DCB		0x80, 0x00, 0x40    ; 17
			DCB		0x80, 0x00, 0x20    ; 18
			DCB		0x80, 0x00, 0x10    ; 19
			DCB		0x80, 0x00, 0x08    ; 20
			DCB		0x80, 0x00, 0x04    ; 21
			DCB		0x80, 0x00, 0x02    ; 22
			DCB		0x80, 0x00, 0x01    ; 23
;***************************************************************
			

;limits		DCB		"Limits:    ",0x04
;			;SPACE	1		; for padding				
;currLevel	DCB		"Current Level:       ",0x04
;			;SPACE	1		; for padding
;				
;			
	
;***************************************************************






		
			AREA	|.text|, READONLY, CODE, ALIGN=2
			THUMB
			
			;EXTERN
			EXPORT 	LCD_Init
			EXPORT 	sendBYTE
			EXPORT 	sendCHAR
			EXPORT 	msDelay
			EXPORT 	setLocation
			EXPORT 	sendSTRING
			EXPORT	sendSTRINGinverse
			EXPORT	LCD_Clear
			EXPORT	plotGraph
			
;*******************************************************************************************
;*******************************************************************************************			

LCD_Init	
			PUSH {R0,R1,R2,R3,R4,LR}
			
			LDR		R1,=SYSCTL_RCGCGPIO 	; START CLOCK FOR PORT A
			LDR		R0,[R1]
			ORR		R0,#0x01
			STR		R0,[R1]
			
			LDR		R1,=SYSCTL_PRGPIO		; WAIT UNTIL PORT A STABILAZED
PAnotReady	LDR		R0,[R1]
			ANDS	R2,R0, #0x01
			BEQ		PAnotReady
			
			LDR		R1,=GPIO_PORTA_DEN 		; DEN PA2-3-4-5-6-7
			LDR		R0,[R1]
			ORR		R0,#0xFC
			STR		R0,[R1]
			
			LDR		R1,=GPIO_PORTA_DIR		; OUT:PA2-3-5-6-7 ; IN:PA4
			LDR		R0,[R1]
			ORR		R0,#0xEC
			STR		R0,[R1]
			
			LDR		R1,=GPIO_PORTA_AFSEL	; MAKE PA2-3-4-5 ALTERNATIVE
			MOV		R0,#0x3C
			STR		R0,[R1]
			
			LDR		R1,=GPIO_PORTA_PCTL		; MAKE PA2-3-4-5 SSI0
			MOV32	R0,#0x00222200
			STR		R0,[R1]
			
			LDR		R1,=SYSCTL_RCGCSSI		; ENABLE SSI0
			LDR		R0,[R1]
			ORR		R0,#0x01
			STR		R0,[R1]
			
			LDR		R1,=SYSCTL_PRSSI		; WAIT UNTIL SSI0 STABILAZED
SSInotReady	LDR		R0,[R1]
			ANDS	R2,R0, #0x01
			BEQ		SSInotReady
			
			LDR		R1,=SSI0_CR1			; DISABLE SSI 
			MOV		R0,#0x0
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CPSR			; CPSDVSR=2
			MOV		R0,#0x2					; SSI0Clk = SysClk / (CPSDVSR * (1 + SCR))
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CR0			 
			MOV		R0,#0x09C7
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CC			 
			MOV		R0,#0x05
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CR1			; ENABLE SSI 
			MOV		R0,#0x02
			STR		R0,[R1]
			
			
			
			LDR		R3,=GPIO_PORTA_DATA 	; ACTIVATE RST
			LDR		R4,[R3]
			AND		R4,#0xBF 
			STR		R4,[R3]
			
			MOV		R0,#150					; GIVE TIME FOR RESET
			
			LDR		R3,=GPIO_PORTA_DATA 	; DEACTIVATE RST
			LDR		R4,[R3]
			ORR		R4,#0x40				
			STR		R4,[R3]
			
			
			LDR		R3,=GPIO_PORTA_DATA 	; ACTIVATE COMMAND MODE
			LDR		R4,[R3]
			AND		R4,#0x7F 
			STR		R4,[R3]
			
			MOV		R0,#0x21
			BL		sendBYTE
			
			MOV		R0,#0xBF
			BL		sendBYTE
			
			MOV		R0,#0x04
			BL		sendBYTE
			
			MOV		R0,#0x14
			BL		sendBYTE
			
			MOV		R0,#0x20
			BL		sendBYTE
			
			MOV		R0,#0x0C
			BL		sendBYTE
			
			MOV		R0,#0x80
			BL		sendBYTE
			
			MOV		R0,#0x40
			BL		sendBYTE
			
			LDR		R3,=GPIO_PORTA_DATA 	; DEACTIVATE COMMAND MODE
			LDR		R4,[R3]
			ORR		R4,#0x80				
			STR		R4,[R3]
			
			
			
			POP {R0,R1,R2,R3,R4,LR}
			BX		LR
			
	

;*******************************************************************************************
;*******************************************************************************************
			
setLocation	;
			;	 R0 X LOCATION
			;	 R1 Y LOCATION
			PUSH {R0,R1,R2,R3,R4,R5,R6,LR}
			
			LDR		R3,=GPIO_PORTA_DATA 	;OPEN COMMAND MODE
			LDR		R4,[R3]
			AND		R4,#0x7F
			STR		R4,[R3]
			
			ORR		R0,#0x80
			BL		sendBYTE
			
			MOV		R0,R1
			ORR		R0,#0x40
			BL		sendBYTE
			
			LDR		R3,=GPIO_PORTA_DATA 	;OPEN COMMAND MODE
			LDR		R4,[R3]
			ORR		R4,#0x80
			STR		R4,[R3]
			
			POP {R0,R1,R2,R3,R4,R5,R6,LR}
			BX		LR
			
;*******************************************************************************************
;*******************************************************************************************			
			
sendBYTE	;	 R0 is BYTE
			
			PUSH {R1,R2,R3,R4,R5,R6,LR}
			
			LDR		R1,=SSI0_DR 	;WRITE DATA TO FIFO
			STR		R0,[R1]
			
			LDR		R1,=SSI0_SR
DRnotReady	LDR		R2,[R1]			;WAIT UNTIL DATA TRANSFERRED
			ANDS	R2,#0x10
			BNE		DRnotReady
			
			POP {R1,R2,R3,R4,R5,R6,LR}
			BX		LR
;*******************************************************************************************
;*******************************************************************************************			
			
sendCHAR	;	 R0 is ASCII
			PUSH {R0,R1,R2,R3,R4,R5,R6,LR}
			
			LDR		R1,=ASCII 		;CALCULATE THE LOCATION OF THE CALLED CHARACTER
			SUB		R0,#0x20			;AND PUT THE ADDRESS TO R1
			MOV		R2,#5
			MUL		R0,R2
			ADD		R1,R0		
nextColmn
			LDR		R0,[R1]			;LOOP UNTIL ALL 5 BYTES ARE WRITTEN
			BL		sendBYTE
			ADD		R1,#1
			SUBS	R2,#1
			BNE		nextColmn
			
			MOV		R0,#0x00		;LEAVE A SPACE AFTER
			BL		sendBYTE
			
			POP 	{R0,R1,R2,R3,R4,R5,R6,LR}
			BX		LR	
			
;*******************************************************************************************
;*******************************************************************************************			
			
sendCHARinverse	;	 R0 is ASCII
			PUSH {R0,R1,R2,R3,R4,R5,R6,LR}
			
			LDR		R1,=ASCII 		;CALCULATE THE LOCATION OF THE CALLED CHARACTER
			SUB		R0,#0x20			;AND PUT THE ADDRESS TO R1
			MOV		R2,#5
			MUL		R0,R2
			ADD		R1,R0		
nextColmnInv
			LDR		R0,[R1]			;LOOP UNTIL ALL 5 BYTES ARE WRITTEN
			EOR		R0,#0xFF
			BL		sendBYTE
			ADD		R1,#1
			SUBS	R2,#1
			BNE		nextColmnInv
			
			MOV		R0,#0xFF		;LEAVE A SPACE AFTER
			BL		sendBYTE
			
			POP 	{R0,R1,R2,R3,R4,R5,R6,LR}
			BX		LR	

;*******************************************************************************************
;*******************************************************************************************

sendSTRING	;	 R0 is beginning of STRING
			PUSH {R0,R1,R2,R3,R4,R5,R6,LR}
			MOV		R1,R0
nextChar	
			LDREXB	R0,[R1]
			CMP		R0,#0x04
			BEQ     endofStr
			ADD		R1,#1
			BL		sendCHAR
			B		nextChar
				
endofStr			
			
			POP 	{R0,R1,R2,R3,R4,R5,R6,LR}
			BX		LR	
;*******************************************************************************************
;*******************************************************************************************

sendSTRINGinverse	;	 R0 is beginning of STRING
			PUSH {R0,R1,R2,R3,R4,R5,R6,LR}
			MOV		R1,R0
nextCharInv	
			LDREXB	R0,[R1]
			CMP		R0,#0x04
			BEQ     endofStrInv
			ADD		R1,#1
			BL		sendCHARinverse
			B		nextCharInv
				
endofStrInv			
			
			POP 	{R0,R1,R2,R3,R4,R5,R6,LR}
			BX		LR	
;*******************************************************************************************
;*******************************************************************************************

LCD_Clear	PUSH {R0,R1,LR}
			MOV		R1,#503
			MOV		R0,#0
clr			BL		sendBYTE
			SUBS	R1,#1
			BNE		clr
			

			POP	{R0, R1, LR}
			BX		LR
;*******************************************************************************************
;*******************************************************************************************
plotGraph	; TAKES MAGNITUDE AS R0, X LOCATION AS R1
			PUSH {R0,R1,R2,R3,R4,R5,LR}
			MOV		R4,R0		;PUT MAGNITUDE INTO R4
			MOV		R0,R1		;PUT XLOC INTO R0
			MOV		R1,#5		;CHOOSE YLOC TO BE 5
			BL		setLocation	;Choose Starting Point
			LDR		R5,=dotPlot	;Load Starting addres to R5
			MOV		R3,#3
			MUL		R4,R3
			ADD		R5,R4
			
			MOV		R3,R0		;NOW LOAD X LOC INTO R3
			
			LDREXB	R0,[R5]	;PRINT LOWER COLUMN
			ADD		R5,#1
			BL		sendBYTE
			
			MOV		R0,R3
			MOV		R1,#4
			BL		setLocation
			
			LDREXB	R0,[R5]	;PRINT MIDDLE COLUMN
			ADD		R5,#1
			BL		sendBYTE
			
			MOV		R0,R3
			MOV		R1,#3
			BL		setLocation
			
			LDREXB	R0,[R5]	;PRINT UPPER COLUMN
			BL		sendBYTE
			
			POP {R0,R1,R2,R3,R4,R5,LR}
			BX	LR




;*******************************************************************************************
;*******************************************************************************************

msDelay		PUSH 	{R0,R1,LR}
			
			MOV		R1,#4000
			MUL		R0,R1
msWait		SUBS	R0,#1
			BNE		msWait
			POP 	{R0,R1,LR}
			BX		LR
			
			
			ALIGN
			END
				
				