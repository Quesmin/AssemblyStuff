IN_STR MACRO MEM, LEN			; takes a DB variable for string 
    LOCAL  READ, END			; and a DW var for length

		PUSH SI					; save the SI and AX registers
		PUSH AX
		XOR SI, SI
		XOR AX,AX
		
READ:
		MOV AH,01h 				; prepare AH for input
		INT 21H  				; read char

		CMP AL,0Dh 				; check if enter key was pressed
		JE END 					; if key was enter, jump to END label 
				
		MOV MEM[SI],AL 			; if not store the char in MEM and read another char
		INC SI
		JMP READ
		
END:
		MOV MEM[SI], '$'		; add the string terminator char, NULL
		MOV LEN, SI				; store in LEN the length of the string
		POP AX					; restore the registers
		POP SI

ENDM

IN_NUM MACRO MEM				; takes DB/DW as a variable
    LOCAL  READ, END
		
		PUSH AX
		PUSH BX
		XOR AX, AX				; save and init the registers
		XOR BX, BX

READ:
		MOV AH,01H 				; prepare AH for input
		INT 21H  				; read char
		
		CMP AL, 20H				; check if enter key was pressed
		JE END 					; if key was enter, jump to END label
				
		CMP AL, 0DH				; check if space key was pressed
		JE END 					; if key was space, jump to END label
					
		PUSH AX					; compute the number using the AX register so we save it on the stack
			MOV AX, BX			; in BX we construct the number digit by digit so we multiply it by 10
			MOV BX, 10			; to add the next read digit
			MUL BX				; current_number = prev_number * 10 + recent_read_digit
			MOV BX, AX			  
		POP AX

		SUB AL, '0'				; convert from ASCII to its real value
		ADD BX, AX				; add to the number
		JMP READ
		
END:
		MOV MEM, BL				; store the input number in MEM
		POP BX
		POP AX					; restore registers
ENDM

IN_NUM_STR MACRO MEM, LEN
	LOCAL  READ, END, NEW_NUM

		PUSH SI
		PUSH AX
		PUSH BX					; save on stack and init registers
		XOR AX, AX
		XOR BX, BX
		XOR SI, SI

READ:
		MOV AH,01H 				; prepare AH for input
		INT 21H  				; read char
			
		CMP AL, 0DH				; check if enter key was pressed
		JE END 					; if key was enter, go to END label to store the result
				
		CMP AL, 20H				; check if space key was pressed
		JE NEW_NUM 				; if key was space, go to NEW_NUM label to store the current number
					
		PUSH AX             	; compute the number using the AX register so we save it on the stack
			MOV AX, BX			; in BX we construct the number digit by digit so we multiply it by 10
			MOV BX, 10			; to add the next read digit
			MUL BX				; current_number = prev_number * 10 + recent_read_digit  
			MOV BX, AX
		POP AX				

		SUB AL, '0'				; convert from ASCII to its real value
		ADD BL, AL				; add to number
		JMP READ

NEW_NUM:
		MOV MEM[SI], BL			; store the current number in MEM[SI]
		XOR BX, BX
		INC SI 
		JMP READ

END:
		MOV MEM[SI], BL			; store the last number computed before the enter was pressed
		INC SI
		MOV LEN, SI				; store the length in LEN
		
		POP BX
		POP AX					; restore the registers
		POP SI

ENDM

OUT_STR MACRO MEM				; takes a DB variable for the output string
	LOCAL
	
		PUSH AX					; save the registers on the stack and init them
		PUSH DX
		XOR AX, AX
		XOR DX, DX

		LEA DX, MEM				; store the message's address
    	MOV AH, 09H				; set the function to print the string
    	INT 21H					; print
		
		POP DX
		POP AX

ENDM

OUT_NUM MACRO MEM						; takes a DB\DW variable to output
	LOCAL DIGITS, PRINT

	 	PUSH AX
		PUSH BX
		PUSH CX					; save the registers on the stack and init them
		PUSH DX
		XOR AX, AX
		XOR CX, CX
		XOR BX, BX
		XOR DX, DX
		
		MOV AL, MEM				; switch between AX/AL by case (DW /DB)
		MOV BX, 10				; we will use BX to get each digit of the number

DIGITS:
		XOR DX, DX 				; init the DX for the result
		DIV BX					; div by 10 to get the digit to print
		ADD DX, '0'				; convert to ASCII by adding '0' value
		PUSH DX					; we use the the stack to store the digits
		INC CX					; we will use CX to pop from the stack
		CMP AX, 0H				; check if there are still any digits in the number
		JNZ DIGITS

PRINT:
		POP DX					; pop the digit from the stack
		MOV AH, 02H				; by using the stack we print them in the correct order
		INT 21H
		LOOP PRINT

		POP DX					; restore registers
		POP CX
		POP BX
	 	POP AX
ENDM

OUT_NUM_STR MACRO MEM, LEN
	LOCAL NUM_PRINT

		PUSH SI					; save the registers on the stack
		PUSH CX
		
		MOV SI, 0				; we init SI with 0 and store in CX the length
		MOV CX,LEN				; so we can loop through our array of numbers
		NUM_PRINT:
			OUT_NUM MEM[SI]		; we print the number
			SPACE				; we put a space after that
			INC SI				; and we move to the next one
			LOOP NUM_PRINT

		POP CX					; restore registers
		POP SI

ENDM

ENDLINE MACRO					; to print the endline on console
	LOCAL
		PUSH AX					; save on stack and init the registers
		PUSH DX
		XOR DX, DX
		XOR AX, AX

		
		MOV DL, 0AH				; store the '\n' in DL
		MOV AH, 02H				; print it
		INT 21H
		
		POP DX					; restore registers
		POP AX
ENDM

SPACE MACRO						; print space
	LOCAL
		PUSH AX					; save on stack and init the registers
		PUSH DX
		XOR DX, DX
		XOR AX, AX
		
		MOV DL, 20H				; store in DL the ' ' char
		MOV AH, 02H				; print it
		INT 21H
		
		POP DX					; restore registers
		POP AX
ENDM

IN_CHR MACRO CHR
	LOCAL READ, END
	
	PUSH AX						; save on stack the registers
	PUSH DX
	XOR DX, DX
	XOR AX, AX
	
READ:
	
	MOV AH, 01H					; get the char
	INT 21H
	
	CMP AL, 0DH					; read untill the enter key is pressed
	JE END		
	
	MOV CHR, AL					; store in CHR the last read char if it was not enter key
	JMP READ
	
END:
	POP DX						; restore registers
	POP AX
	
ENDM

OUT_CHR MACRO CHR
	LOCAL
	
	PUSH AX						; save on stack the registers
	PUSH DX
	XOR DX, DX
	XOR AX, AX
	
	MOV AH, 02H					
	MOV DL, CHR					; print the char in CHR 
	INT 21H
	
	POP DX						; restore registers
	POP AX
	
ENDM

OUTPUT MACRO 					; print "OUTPUT: "
	LOCAL
	
	PUSH AX						; save on the stack the registers
	PUSH DX
	XOR DX, DX
	XOR AX, AX
	
	MOV AH, 02H
	MOV DX, 4FH					; print "O"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 55H					; print "U"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 54H					; print "T"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 50H					; print "P"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 55H					; print "U"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 54H					; print "T"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 3AH					; print ":"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 20H					; print " "
	INT 21H
	
	POP DX						; restore the registers
	POP AX
	
ENDM

INPUT MACRO 					; print "INPUT: "
	LOCAL
	
	PUSH AX						; save on the stack the registers
	PUSH DX
	XOR DX, DX
	XOR AX, AX
	
	MOV AH, 02H
	MOV DX, 49H					; print "I"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 4EH					; print "N"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 50H					; print "P"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 55H					; print "U"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 54H					; print "T"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 3AH					; print ":"
	INT 21H
	
	MOV AH, 02H
	MOV DX, 20H					; print " "
	INT 21H
	
	POP DX						; restore the registers
	POP AX
	
ENDM

IN_SIGN_NUM MACRO MEM
    LOCAL  READ, END, NEW_DIGIT, STORE

        PUSH AX					; save the registers on the stack and init them
        PUSH BX
        PUSH CX
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX

READ:
        MOV AH,01H              ; prepare AH for input
        INT 21H                 ; get the char
            
		CMP AL, 20H             ; check if enter key was pressed
        JE END                  ; if key was enter, go and store the number
                
		CMP AL, 0DH             ; check if space key was pressed
        JE END                  ; if key was space, go and store the number
                    
		CMP AL, '-'             ; check if '-' key was pressed           
		JNE NEW_DIGIT           ; if key wasn't '-' then it surely was a digit, go and add the new digit to number
                    
		MOV CX, 1				; otherwise we know that '-' key was pressed so we use CX as an indicator
        JMP READ				; if the number was negative CX = 1, else CX = 0
                   
NEW_DIG:
        PUSH AX                 ; compute the number using the AX register so we save it on the stack
        MOV AX, BX				; in BX we construct the number digit by digit so we multiply it by 10 
        MOV BX, 10				; to add the next read digit
        MUL BX					; current_number = prev_number * 10 + recent_read_digit
        MOV BX, AX             
        POP AX                   

        SUB AL, '0'             ; convert from ASCII to its value
        MOV AH, 0
        ADD BX, AX
        JMP READ
		
END:
		CMP CX, 1				; check if the number was negative or not
        JNE STORE
		
        NOT BL					; if the number was negative we convert it using 2's complement
        ADD BL, 1

STORE:
        MOV MEM, BL             ; store the number in MEM
        POP CX
        POP BX					; and restore the registers
        POP AX
ENDM

OUT_SIGN_NUM MACRO MEM
    LOCAL DIGITS, PRINT, POSITIVE

        PUSH AX					; save and init the registers
        PUSH BX
        PUSH CX
        PUSH DX
        XOR AX, AX
		XOR BX, BX
		XOR CX, CX
		XOR DX, DX
		
        MOV AH,0
        MOV AL, MEM             ; get the number in AL
        
		CMP AL, 0				; check if number is negative or not according to 2's complement
        JNL POSITIVE
            
		SUB AL, 1				; if the number is negative we convert it to positive value
        NOT AL
		
        PUSH AX					; push AX to print '-' if the number is negative
        MOV DL, '-'
        MOV AH, 02H
        INT 21H
        POP AX

POSITIVE:
        MOV BX, 10              ; so we cand print each digit

DIGITS:
		XOR DX, DX 				; init the DX for the result
		DIV BX					; div by 10 to get the digit to print
		ADD DX, '0'				; convert to ASCII by adding '0' value
		PUSH DX					; we use the the stack to store the digits
		INC CX					; we will use CX to pop from the stack
		CMP AX, 0H				; check if there are still any digits in the number
		JNZ DIGITS

PRINT:
		POP DX					; pop the digit from the stack
		MOV AH, 02H				; by using the stack we print them in the correct order
		INT 21H
		LOOP PRINT

        POP DX					; restore the registers
        POP CX
        POP BX
        POP AX
ENDM
