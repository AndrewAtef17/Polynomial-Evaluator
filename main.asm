INCLUDE Irvine32.inc
INCLUDE macros.inc
.data
equationWithSpaces byte 100 dup(?)
equation byte 100 dup(?)
equationsize dword ?
Xvalue dword ?
NumArray sdword 100 dup(?)
numarraysize dword ?
OpArray byte 100 dup(?)
oparraysize dword ?
Count dword 0
toInt byte 5 dup(?)
negativenum dword 0
.code

main PROC

call ReadEquation
call OperationsArray
call IntegerArray
call PowerCalculate
call multcalculate
call ADDSUBcalculate

mov eax,numarray[0]
mWrite<"f(x)= ">
call writeint

    exit
main ENDP

;--------------------------------------------------------------------------------------------
;Reads the Equation as a string and remove the spaces in it then Read 'X' value as signed int
;--------------------------------------------------------------------------------------------
ReadEquation proc
mWrite<"Enter a polynomial equation: ">
mov edx,offset equationWithSpaces
mov ecx,100
call readstring
;removing spaces
mov ecx,eax
mov edx,offset equationWithSpaces
mov eax,0
RemoveSpaces:
mov bl ,[edx]
cmp bl,32
je ignoreee
mov equation[eax],bl
inc eax
ignoreee:
inc edx
loop RemoveSpaces
mov equation[eax],0
mov equationsize,eax
mWrite<"Enter the value of X: ">
call Readint
mov Xvalue,eax
ret
ReadEquation endp

;------------------------------------------------------------------------------------------
;Fills the operations Array with '1' for adding, '2' for subtracting, '3' for multiplying,
;'4' for power operation and change them into a flag which is '!'
;if there is negative sign not a subraction(means operative followed by '-') it stays the same.
;------------------------------------------------------------------------------------------
OperationsArray proc
;checking if the equation start with negative sign then adds zero at the beginning
mov edx,-1
inc edx
cmp equation[edx],45
jne continuee
mov edx,equationsize
dec edx
mov ecx , equationsize
LoopZero:
mov al,equation[edx]
mov equation[edx+1],al
dec edx
loop LoopZero
inc equationsize
mov equation[0],48
continuee:
mov eax,offset equation
mov edx,0
mov ecx,equationsize
;string into 2 arrays ops and integers
L1:
	mov bl,[eax]
	CMP bl,88
	je ree
	CMP bl,57
	ja Notnumber
	CMP bl,48
	jb Notnumber
	jmp ree
	Notnumber:
	;if "+" add 1 to op array
	CMP bl,43 
	jne checksub
	mov OpArray[edx],1
	jmp loopp
	;if "-" add 2 to op array
	checksub:
	CMP bl,45
	jne checkmult
	mov bl,[eax-1]
	;if there is op before the "-" then its negative not op
	CMP bl,88
	je subb
	CMP bl,57
	ja ree
	CMP bl,48
	jb ree
	subb:
	mov OpArray[edx],2
	jmp loopp
	;if "*" add 3 to op array
	checkmult:
	CMP bl,42
	jne checkpower
	mov OpArray[edx],3
	jmp loopp
	;if "^" add 4 to op array
	checkpower:
	CMP bl,94
	mov OpArray[edx],4
	loopp:
	mov [eax],byte ptr 33 ;flag for integer array function
	inc edx
	ree:
	inc eax
loop L1
	mov oparraysize,edx
ret
OperationsArray endp

;-----------------------------------------------------------------------------------
;Takes the numbers between every two flags left from operation array function '!' 
;and add then in the numbers Array
;uses CharToint to covert the numbers in the string to actual integers
;-----------------------------------------------------------------------------------
IntegerArray proc
	;Filling the integer array
	mov esi,0
	mov eax,offset equation
	mov edx,0
	mov ecx,equationsize
	mov equation[ecx],byte ptr 33
	inc ecx
	Loop2:
	mov bl,[eax]
	CMP bl ,45
	jne notnegative
	mov negativenum,1
	jmp ree
	notnegative:
	CMP bl,88
	je ifX
	CMP bl,57
	ja NotNum
	CMP bl,48
	jb NotNum
	mov toInt[edx],bl
	inc edx
	jmp ree
	NotNum:
	cmp edx ,0
	je ree
	mov toInt[edx],0
	call CharToInt
	mov edx,0
	jmp ree
	ifX:
	mov edx,Xvalue
	mov NumArray[esi],edx
	add esi,4
	mov edx,0
	ree:
	inc eax
	loop Loop2
	SHR esi,2
	mov numarraysize,esi
ret
IntegerArray endp

;--------------------------------------------------------------------------------------------------
;turn char to integer and returns the int value in the eax register then added in the numbers array
;---------------------------------------------------------------------------------------------------
ChartoInt proc uses edx ecx ebx eax
;covert from char to int
mov edx ,offset toInt
mov ecx, 0
mov ebx, 0
xor eax, eax ; zero a "result so far"
top:
mov cl, [edx] ; get a character
inc ebx
inc edx ; ready for next one
cmp ecx, 48 ; valid?
jb done
cmp ecx, 57
ja done
sub ecx, 48 ; "convert" character to number
imul eax, 10 ; multiply "result so far" by ten
add eax, ecx ; add in current digit
jmp top ; until done
done:
cmp negativenum,1
jne notnegative
neg eax
mov negativenum,0
notnegative:
mov NumArray[esi] , eax
add esi,4
ret
ChartoInt endp

;-------------------------------------------------------------------------------------------------------
;check the operations array for power operation which is '4' and does the operation in the numbers array
;calls removeFlag to remove the flag left after every power operation and the flag left by the integers after the calculations
;-------------------------------------------------------------------------------------------------------
PowerCalculate proc
;Power
	cmp oparraysize,0
	je exitt
	mov ebx,0
	mov ecx,oparraysize
	poweroperation:
	mov al,oparray[ebx]
	cmp al,4
	jne lloopp
	inc Count
	mov edx,ebx
	shl edx,2
	mov ecx , numarray[edx+4]
	cmp ecx,0
	jne notpowerzero
	mov esi,1
	jmp powerzero
	notpowerzero:
	dec ecx
	mov esi,numarray[edx]
	Power:
	IMUL esi,numarray[edx]
	loop Power
	powerzero:
	mov numarray[edx],esi
	mov numarray[edx+4],989898 ;flag
	mov oparray[ebx],9 ;flag
	call RemoveFlag
	mov ecx,oparraysize
	inc ecx
	mov ebx,-1
	mov Count ,0
	lloopp:
	inc ebx
	loop poweroperation
	cmp count,0
	je enddd
	call RemoveFlag
	enddd:
	exitt:
ret
PowerCalculate endp

;-------------------------------------------------------------------------------------------------------
;check the operations array for multiplications operation which is '3' and multiplies the numbers array
;calls removeFlag to remove the flag left after every multiplication operation and the flag left by the integers after the calculations
;-------------------------------------------------------------------------------------------------------
multcalculate proc
;Mult
	cmp oparraysize,0
	je exitt
	mov Count ,0
	mov ebx,0
	mov ecx,oparraysize
	multop:
	mov al,oparray[ebx]
	cmp al,3
	jne llll
	inc Count
	mov edx,ebx
	shl edx,2
	mov ecx , numarray[edx+4]
	cmp ecx, 8000h
	JB NotNegative
	neg ecx
	NotNegative:
	dec ecx
	mov esi,numarray[edx]
	cmp ecx,0
	je skiploop
	Mult:
	add esi,numarray[edx]
	loop Mult
	skiploop:
	mov ecx , numarray[edx+4]
	cmp ecx, 8000h
	JB NN
	neg esi
	NN:
	mov numarray[edx],esi
	mov numarray[edx+4],989898 ;flag
	mov oparray[ebx],9 ;flag
	call RemoveFlag
	mov ecx,oparraysize
	inc ecx
	mov ebx,-1
	mov Count ,0
	llll:
	inc ebx
	loop multop
	exitt:
ret
multcalculate endp

;-----------------------------------------------------------------------------------------------------------------------------
;check the operations array for additions and subtractions operation which is '1','2' then adds and subtracts the numbers array
;Returns the final answer in the first index of the number array
;------------------------------------------------------------------------------------------------------------------------------
ADDSUBcalculate proc

;ADD,SUB
	cmp oparraysize,0
	je exitt
	mov ebx,0
	mov ecx,oparraysize
	AddSub:
	mov edx,ebx
	shl edx,2
	mov esi , numarray[edx+4]
	mov al,oparray[ebx]
	cmp al,1
	jne checksub
	;if add
	add numarray[0],esi
	jmp ree
	
	checksub:
	cmp al,2
	jne ree
	;if sub
	sub numarray[0],esi
	ree:
	inc ebx
	loop AddSub
	exitt:
ret
ADDSUBcalculate endp

;-----------------------------------------------------------------------------------------------------------------------------
;remove the flags left after every operation and the flag left by the integers after the calculations
;------------------------------------------------------------------------------------------------------------------------------
RemoveFlag proc uses ecx eax ebx
;REMOVE NUMM ARRAY FLAGS
	mov ecx,Count
	removenumflag:
	push ecx
	mov  ecx,numarraysize
	mov ebx,offset numarray
	haha:
	mov eax,[ebx]
	cmp eax,989898
	jne notused
	mov eax, [ebx+4]
	mov [ebx],eax
	mov eax,989898
	mov [ebx+4],eax
	notused:
	add ebx,4
	loop haha
	dec numarraysize
	pop ecx
	loop removenumflag


	;REMOVE OPERATIONS FLAGS
	mov ecx, Count
	mov eax,0
	removeOPflag:
	push ecx
	mov  ecx,oparraysize
	mov ebx,offset oparray
	haha2:
	mov al,[ebx]
	cmp al,9
	jne notused2
	mov al,[ebx+1]
	mov [ebx],al
	mov al,9
	mov [ebx+1],al
	notused2:
	inc ebx
	loop haha2
	dec oparraysize
	pop ecx
	loop removeOPflag

ret
RemoveFlag endp
End main
