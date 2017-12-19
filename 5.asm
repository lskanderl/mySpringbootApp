;***********************************************************************************
;		  	  ��������� ���������� �������
;***********************************************************************************
;-----------------------------------------------------------------------------------
;----------------------���������� ���� ������ � �� �����----------------------------
;-----------------------------------------------------------------------------------

;----------------------------���������� ��������------------------------------------
NRK		Equ 2		;���-�� ����� ����������
NCK		Equ 4		;���-�� ������� ����������
NKey		Equ NRK*NCK	;���-�� ������ ����������
NR		EQU 4		;���-�� ����� ������
NC	  	EQU 16		;���-�� ������� �������
NS	  	EQU NR*NC	;����� �������� �������
N		EQU 91		;����� �������� �������� � ������� ���������

;---------------------���������� ���� ������ � �� �����-----------------------------
KEYPORT		EQU P1		;���� ������ ������ ����������
DPORT		EQU P2		;���� ������ ������ �� �������
CPORT		EQU P0		;���� ����������
RS		EQU DPORT.2	
E		EQU DPORT.3


;-----------------------���������� ������� ����������-------------------------------
X		Equ 24
X1		Equ 25
Y		Equ 26
CTR		Equ 27
CTC		Equ 28
MSK		Equ 29
FL		Equ 32
Key 		Equ 33
CTS		EQU 30		;����� ������� ������������� �� �������
COM		EQU 31		;������� �������
NTEXT		EQU 35		;������� ������ ������� ���������� ������
KKey		EQU 40		;���� ����������
ATEXT		EQU 41		;��������� ����� ���������� ������


;------------------------------������ ���������-------------------------------------

;---------------------------����� ����������������----------------------------------
Org 0
JMP Init

;--------------------------�-� ���������� ������� �0--------------------------------
Org 0Bh
JMP Int_opros

;------------------------������������� ����������������-----------------------------
Init:
MOV KEYPORT,#0FFh
MOV DPORT,#0
MOV FL,#0			;�������� ���� ����������
MOV X,#0			;�������� ������� ��� ����������
MOV X1,#0			;�������� ���������� ��� ����������
MOV Y,#0			;�������� �������� ��� ����������
CALL INIT_LCD			;������������� �������
CALL CLEARBUF			;������� ���������� ������
CALL Timer0_Init		;��������� ������ �0
	
;-----------------------------�������� ���������------------------------------------
Begin:
CALL FLK1
CALL FLK2
CALL FLK3
CALL KEY_FORM
CALL KEY_TEST

SJMP Begin

;----------������������ ��������� ������� �0 �� 30�� ����� ������-------------------
Timer0_Init:			
MOV TMOD,#00000001b		;��������� ������ 1 ������� �0
MOV TH0, #HIGH(-30000)		;��������� ������� ���� �������
MOV TL0, #LOW(-30000)		;��������� ������� ���� �������
ORL IE,#10000010b		;��������� ���������� �� �������
SETB TR0			;�������� ������
RET				;� ��������� � �������� ���������

;-----------������������ ���������� �� ����� � ������ ����������--------------------
Int_opros:
MOV TH0, #HIGH(-30000)		;��������� ������� ���� �������
MOV TL0, #LOW(-30000)		;��������� ������� ���� �������
PUSH ACC			;��������� � ����� �����������
PUSH PSW			;��������� � ����� ����� ���������
CALL Opros_Key			;�������� ����������
CALL Analiz_Key			;���������������� ��� ����������
POP PSW				;������� �� ����� ����� ���������
POP ACC				;������� �� ����� �����������
RETI				;������� �� ������������ ����������

;-------------------������������ ������ ��������� ������----------------------------
Opros_Key:
MOV A, P1			;������ ��������� ������
MOV X, #0			;�=0
Next_opros:			;������ ������ ���� ������
INC X				;��������� �������� ��������� ������
MOV R2, X				
CJNE R2, #(NKey+1), Shift
MOV X, #0
JMP Opros_end
Shift:				;�������� ������� ������
RRC A
JC Next_opros			;���������� ��������, ���� ������ ������
Opros_end:
RET

;--------------------������������ ������� ����� ����������--------------------------
Analiz_Key:
MOV A, X			;�������� �=�1, �, ���� ���, �� ������� � Set_X1,
CJNE A, X1, Set_X1		;�����:
CJNE A, Y, Set_Y		;�������� Y=X, �, ���� ���, �� ������� � Set_Y,
JMP End_analis			;����� ���������� �������
Set_X1:
MOV X1, A			;�1=�
JMP End_analis
Set_Y:
MOV R2, Y			;�������� Y=0 � ���� ���, �� ������� � CLR_FL,
CJNE R2, #0, CLR_FL		;�����:
MOV Y, A			;Y=X
MOV FL, #1			;��������� ����� FL=1
JMP End_analis
CLR_FL:
MOV Y, A			;Y=X
MOV FL, #0			;FL=0
End_analis:
RET				;������� �� ������������
	
;---------------------������������ ������������� �������----------------------------
INIT_LCD:
	CALL DELAY_40ms
	MOV DPORT, #00101011b
	CLR E
	CALL DELAY_43us
	MOV COM, #00101000b
	CALL WRITE_COM
	CALL WRITE_COM
	MOV COM, #00001110b
	CALL WRITE_COM
	MOV COM, #00000110b
	CALL WRITE_COM
	CALL CLEAR_LCD
	RET

;--------------------������������ ������ ������� � �������--------------------------
WRITE_COM:
	MOV A, COM
	ORL A, #00001111b
	ANL A, #11111001b
	MOV DPORT, A
	CLR E
	MOV A, COM
	SWAP A
	ORL A, #00001111b
	ANL A, #11111001b
	MOV DPORT, A
	CLR E
	CALL DELAY_43us
	RET

;------------------������������ �������� ���������� �������--------------------------
WAIT_BF:
MOV DPORT,#0FFh
CLR RS
	
;---------------------������������ ������� ������ �������----------------------------
CLEAR_LCD:
	MOV COM, #00000001b
	CALL WRITE_COM
	MOV CTS, #0
	;MOV ADR, #0
	CALL ADDR_SET
	RET

;--------------------������������ ��������� ������ �������---------------------------
ADDR_SET:
	ORL A, #10000000b
	MOV COM, A
	CALL WRITE_COM
	RET

;--------------------������������ ������ �������� �� �������-------------------------
WRITE_SYMB:
CALL ADDR_CALC
	CALL ADDR_SET
	MOV A, Key
	ADD A,#20h
	ORL A, #00001111b
	ANL A, #11111101b
	MOV DPORT, A
	CLR E
	MOV A, Key
	ADD A,#20h
	SWAP A
	ORL A, #00001111b
	ANL A, #11111101b
	MOV DPORT, A
	CLR E
	CALL DELAY_43us
	INC CTS
	
	CALL ADDR_CALC
	CJNE A,#64+2*NC,WRITE_END
	DEC A
	WRITE_END:
	CALL ADDR_SET
	RET

;------------------������������ ���������� ������ ������ �������---------------------
;----------------------------(��� ������� �� 4 ������)-------------------------------
ADDR_CALC:
	MOV A, CTS
	CLR C
	SUBB A, #NC
	JC ROW1
	SUBB A, #NC
	JC ROW2
	SUBB A, #NC
	JC ROW3
	SUBB A, #NC
	JC ROW4
	SUBB A, #NC
	MOV A, #64+2*NC-NS
	JMP ADDCTS

	ROW1:
	MOV A, #0
	JMP ADDCTS
	
	ROW2:
	MOV A, #64-NC
	JMP ADDCTS
	
	ROW3:
	MOV A, #256-NC
	JMP ADDCTS
	RET
	
	ROW4:
	MOV A, #64-2*NC

	
	ADDCTS:
	ADD A, CTS
	RET
;-------------------------������������ �������� �� 43 ���----------------------------
DELAY_43us:
	MOV R5, #20
LABEL1:
	DJNZ R5, LABEL1
        RET

;-------------------------������������ �������� �� 1,53 ��---------------------------
DELAY_1530us:
	MOV R6, #35
LABEL2:
	CALL DELAY_43us
	DJNZ R6, LABEL2
	RET
	
;--------------------------������������ �������� �� 40 ��----------------------------
DELAY_40ms:
	MOV R7, #26
LABEL3:
	CALL DELAY_1530us
	DJNZ R7, LABEL3
	RET

;-------------------------���� ���� ������ ������� �������---------------------------
FLK1:
CALL FLK_TEST
MOV R3, A
MOV COM, #00001100b
CALL WRITE_COM
RET

;-------------------------���� ���� ������ ������� �������---------------------------
FLK2:
CALL FLK_TEST
MOV R4, A
MOV COM, #00001111b
CALL WRITE_COM
RET

;-------------------------���� ���� ������� ������� �������---------------------------
FLK3:
CALL FLK_TEST
MOV R7, A
MOV COM, #00001110b
CALL WRITE_COM
RET

;--------------------������������ �������� ����� ������� �������---------------------
FLK_TEST:
MOV A, FL
CJNE A, #1, FLK_TEST
MOV FL, #0
MOV A, Y

DEC A
RET

;---------------------������������ ������������ ���� ����������----------------------
KEY_FORM:
MOV A, R3
MOV B, #NKey
MUL AB
ADD A, R4
MOV B, #NKey
MUL AB
ADD A, R7
MOV Key, A
RET

;-----------������������ ������������ ���� ���������� � ���������� ������------------
KEY_TEST:			;�������� ������ ��� �������
MOV A, Key
CLR C
SUBB A, #05Bh
JNC COMAND_TEST
;----------------------������ ������� � ����� � ������ �� �����----------------------
CALL WRITE_BUF
CALL WRITE_SYMB			;������ ������� �� �������
JMP END_TEST			;���������� ������������ ����� ����������

;-------------------�������� � ��������� ����� ������ ����������---------------------
COMAND_TEST:
MOV A, Key

;-------------------�������� � ���������� ������� ������� ������---------------------
TEST91:
CJNE A, #05Bh, TEST92		;�������� ���=5Bh, ���� ���, �� ������� �
				;�������� ��������� �������, ���� ��, ��
CALL CLEARBUF			
CALL CLEAR_LCD			;������� ������ �������
JMP END_TEST			;���������� ������������ ����� ����������

;---------------------�������� � ���������� ������� ����� (134)----------------------
TEST92:
CJNE A, #5CH, TEST93		;�������� ���=5��, ���� ���, �� ����������
				;���� ��, �� ���������� ������ ����� (�����):
MOV R1, CTS			;�������� ������� �������
CJNE R1, #0, zab		;���� ������� �������, �� �����
JMP END_TEST			;���� �������, �� ���������� ��� �����

zab:				;���������� �����
DEC CTS				;��������� ������� �������
MOV Key, #0			;������ ���� ������� �� �������
CALL WRITE_BUF			
CALL WRITE_SYMB			;(������� �������)
DEC CTS				;��������� ������� �������
CALL ADDR_CALC			;���������� ������� �������
CALL ADDR_SET			;��������� ������ �������
CALL END_TEST			;���������� ������������ ����� ����������
END_TEST:
RET

;--------�������� � ��������� ������� "���� �����" (��� 135)--------
;------------------(������ ������ ������� ������)-------------------
TEST93: CJNE A, #93, TEST94
MOV A, ATEXT		;������ ������� ������� ������
MOV KKey, ACC		;���������� �����
RET

;-----�������� � ��������� �������. ����������� ����� (��� 136)-----
TEST94: CJNE A, #94, TEST95
MOV A, CTS		;������ ����� �������� ��������
MOV R1, A		;���������� ����� ��������
MOV CTS, #0		;��������� �������� ��������
MOV A, #0
CALL ADDR_SET		;��������� ����� (�������) � ������� �������
MOV R0, #ATEXT		;��������� ��������� ���������� ������ � ������
Read_x:
MOV A, @R0		;������ ������� ��������� ������
ADD A, KKEY		;���������� �+k
MOV B, #N		;�������� n
DIV AB			;���������� �=(x+k)mod n
MOV @R0, B		;������ � � ������� ������� ������ ������
INC R0			;��������� ������ ������� ������
MOV Key, B		;��������� ���� ������� ����������
CALL WRITE_SYMB		;������ ������� �� �������
DJNZ R1, Read_x		;�������� �������� ��������, � ���� �� 0, ������
RET

;--------------------�������� � ��������� �������-----------------------
;------------------------������������ ������----------------------------
TEST95: CJNE A, #95, END_TEST
MOV A, CTS		;������ ����� ��������� ��������
JZ END_TEST		;���� 0, �� ����������, �����
MOV R1, A		;���������� ����� ��������
MOV CTS, #0		;��������� �������� ��������
MOV ACC, #0
CALL ADDR_SET		;��������� ������ (�������) � ������� �������
MOV R0, #ATEXT		;��������� ��������� ���������� ������ � ������
Read_y:
MOV A, @R0		;������ ������� ��������� ������
ADD A, #N		;���������� �+n
CLR C			;������� ���� ��������
SUBB A, KKEY		;���������� y+n-k
MOV B, #N		;�������� n
DIV AB			;���������� �=(y+n-k)mod n
MOV @R0, B		;������ � � ������� ������� ������ ������
INC R0			;��������� ������ ������� ������
MOV Key, B		;��������� ���� ������� ����������
CALL WRITE_SYMB		;������ ������� �� �������
DJNZ R1, Read_y		;��������� �������� ��������, � ���� �� 0, �� ������

;---------------������������ ������� ���������� ������----------------
CLEARBUF:
MOV R0, #ATEXT
MOV R2, #NS
MOV A, #0
CLRB:
MOV @R0, A
INC R0
DJNZ R2, CLRB
RET

;----------------������������ ������ � ��������� �����----------------
WRITE_BUF:
MOV R2, CTS
CJNE R2, #NS, WRB
JMP END_WR
WRB:
MOV A, #ATEXT
ADD A, R2
MOV R0, A
MOV A, KEY
MOV @R0, A
END_WR:
RET

END