@ Filename :    Schwalb.s
@ Author   :    Joseph Schwalb
@ Email    :    jds0099@uah.edu
@ CS413-02 :    2020
@ Purpose  :    ARM Lab 2: use the stack to pass parameters to and from
@               their own defined subroutines/functions in ARM Assembly.
@
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Schwalb.o Schwalb.s
@    gcc -o Schwalb Schwalb.o
@    ./Schwalb ;echo $?
@    gdb --args ./Schwalb

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook.
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error.
.equ CHAR_READERROR, 0 @Used to check for scanf read error.


.global main @ Have to use main because of C library uses.

main:

ldr r0, =startthumb + 1
bx  r0
.code 16 @Make all this code thumb mode. Will not exit back out. 
startthumb:


@*******************
welcome_prompt:
@*******************

@ Ask the user to enter a number.

   ldr r0, =welcomeLab2         @ Put the address of my string into the first parameter
   bl printf                    @ Call the C printf to display input prompt.
   ldr r0, =instructions        @ Put the address of my string into the first parameter
   bl printf                    @ Call the C printf to display input prompt.
   ldr r0, =sampleInput         @ Put the address of my string into the first parameter
   bl printf                    @ Call the C printf to display input prompt.


@*******************
userInput:
@*******************
  mov r5, #0                    @ used to store the first integer
  mov r6, #0                    @ used to store the operation type
  mov r7, #0                    @ used to store the second integer

  ldr r0, =numInputPattern      @ Setup to read in one number.
  ldr r1, =intInput             @ load r1 with the address of where the
                                @ input value will be stored.
  bl  scanf                     @ scan the keyboard.
  cmp r0, #READERROR            @ Check for a read error.
  it eq
  beq readerror                 @ If there was a read error go handle it.
  ldr r1, =intInput             @ Have to reload r1 because it gets wiped out.
  ldr r1, [r1]                  @ Read the contents of intInput and store in r1 so that
                                @ it can be stored.
  mov r7, r1                    @ move contents of r1 into r5

  cmp r7, #0                    @ check if first operand is negative
  it lt
  blt invalidOperand            @ branch to invalidOperand routine
  push {r7}                     @ push first integer to stack

  ldr r0, =opInputPattern       @ Setup to read in one char.
  ldr r1, =charInput            @ load r1 with the address of where the
                                @ input value will be stored.
  bl  scanf                     @ scan the keyboard.
  cmp r0, #CHAR_READERROR       @ Check for a read error.
  it eq
  beq readerror                 @ If there was a read error go handle it.
  ldr r1, =charInput            @ Have to reload r1 because it gets wiped out.
  ldr r1, [r1]                  @ Read the contents of intInput and store in r1 so that
                                @ it can be stored.
  mov r6, r1                    @ move contents of r1 into r6

 
  cmp r6, #0x2F                 @ check if operand is greater than 0x2F
  it gt
  bgt invalidOperator           @ if greater than, branch to invalidOperator
  cmp r6, #0x2A                 @ check if operand is less than 0x2A
  it lt
  blt invalidOperator           @ if less than, branch to invalidOperator
  cmp r6, #0x2E                 @ check if operand equals 0x2E
  it eq
  beq invalidOperator           @ if equals, branch to invalidOperator

  ldr r0, =numInputPattern      @ Setup to read in one number.
  ldr r1, =intInput             @ load r1 with the address of where the
                                @ input value will be stored.
  bl  scanf                     @ scan the keyboard.
  cmp r0, #READERROR            @ Check for a read error.
  it eq
  beq readerror                 @ If there was a read error go handle it.
  ldr r1, =intInput             @ Have to reload r1 because it gets wiped out.
  ldr r1, [r1]                  @ Read the contents of intInput and store in r1 so that
                                @ it can be stored.
  mov r7, r1                    @ move contents of r1 into r7
  
  cmp r7, #0                    @ check if second operand is negative
  blt invalidOperand            @ branch to invalidOperand routine
  
  pop {r0}                      @ pop first operand from stack (for ordering purposes)
  push {r7}                     @ push second operand to stack
  push {r0}                     @ push first operand back to stack


  

@*******************
determineOperation:
@*******************
  @ Test operation type by ascii table lookup

  cmp r6, #0x2A                 @ if operator equals *
  it eq
  beq multiplication
  
  cmp r6, #0x2B                 @ if operator equals +
  it eq
  beq addition                 @ branch to Addition subroutine, return here

  cmp r6, #0x2D                 @ if operator equals -
  it eq
  beq subtraction              @ branch to Subtraction subroutine, return here

  cmp r6, #0x2F                 @ if operator equals /
  it eq
  beq division                 @ branch to Division subroutine, return here

  b wrapUpWithRemainder         @ branch to wrapUpWithRemainder


@*******************
addition:
@*******************

  ldr r0, =determineOperation
  add r0, r0, #12
  mov lr, r0

  mov r3, #0                    @ clear for use as scratchpad
  pop {r4}                      @ first operand as stored on stack
  pop {r5}                      @ second operand as stored on stack

  add r4, r4, r5                @ add r4, r5, store in r4. 

  push {lr}                         @ push lr, preserving lr in case of overflow
  
  cmp r4, r5                    @ Set flags
  ldr r0, =overflowDetectedString @ if overflow, load r0 with overflow string
  add r2, pc, #8
  push {r2}
  it vs
  bvs printf                       @ if overflow, call printf and return here
  pop {r1}                      @ pop stack into r1 (previous lr)
  mov lr, r1                    @ returning lr to original state

  push {r4}                     @ push result
  push {r3}                     @ push remainder 0

  mov pc, lr                    @ return from subroutine

@*******************
subtraction:
@*******************

  ldr r0, =determineOperation
  add r0, r0, #18
  mov lr, r0

  mov r3, #0
  pop {r4}                     @ first operand as stored on stack
  pop {r5}                     @ second operand as stored on stack

  cmp r4, r5
  sub r4, r4, r5

  push {lr}                         @ push lr, preserving lr in case of overflow
  @ldrvs r0, =overflowDetectedString @ if overflow, load r0 with overflow string
  @blvs printf                       @ if overflow, call printf and return here
  pop {r1}                      @ pop stack into r1 (previous lr)
  mov lr, r1                    @ returning lr to original state

  push {r4}                     @ push result
  push {r3}                     @ push remainder 0

  mov pc, lr                    @ return from subroutine

@*******************
multiplication:
@*******************
  ldr r0, =determineOperation
  add r0, r0, #6
  mov lr, r0

  mov r2, #0                    @ clear for use as scratchpad
  mov r3, #0                    @ clear for use as scratchpad
  mov r4, #0                    @ clear for use as scratchpad
  pop {r5}
  pop {r6}


  smull r3, r4, r5, r6        @ mul r5, r6, store in r3,r4 (64 bits)

  @cmp r3, r4, ASR #31           @ shift 31st bit across register, compare with
                                @ higher order 32 bits in r9.If not equal, overflow has occured

  push {lr}                         @ push lr, preserving lr in case of overflow
  @ldrne r0, =overflowDetectedString @ if overflow, load r0 with overflow string
  @blne printf                       @ if overflow, call printf and return here
  pop {r1}                          @ pop lr, returning lr to original state
  mov lr, r1

  push {r3}                     @ push result
  push {r2}                     @ push remainder 0

  mov pc, lr                    @ return from subroutine

@*******************
division:
@*******************
  ldr r0, =determineOperation
  add r0, r0, #24
  mov lr, r0

  mov r3, #0
  mov r4, #0                    @ clear for use as quotient
  pop {r5}                      @ first operand as stored on stack
  pop {r6}                      @ second operand as stored on stack       

  cmp r6, #0                   @ check if the second operand is zero
  beq divByZero                 @ if zero, raise divide by zero error

  cmp r6, #1                   @ check if the second operand is one
  beq done_l                    @ if zero, branch to done_l

  cmp r5, r6                  @ check if the first operand is less than the second
  blt done                      @ if less than, branch to done


loop:
  sub r5, r5, r6             @ r10-r11, store in r10
  add r4, r4, #1                @ add one to quotient
  cmp r5, #0                   @ compare divisor to zero
  bgt loop                      @ if greater than, branch to loop
  beq done                      @ if equal, branch to done

  @addlt r5, r5, r6           @ if divisor is less than zero, revert last step.
                                @ remainders are positive
  @sublt r4, r4, #1              @ revert last quotient increment
done:
  push {r4}                     @ push quotient
  push {r5}                    @ push remainder
  mov pc, lr                    @ return from subroutine

done_l:
  push {r5}                    @ push quotient
  push {r4}                     @ push remainder
  mov pc, lr                    @ return from subroutine

@***********
invalidOperand:
@***********
  ldr r0, =invalidOperandString @ load r0 with the noValidOperator string
  bl printf                     @ call printf, return here
  ldr r0, =progRestart          @ load r0 with the progRestart string
  bl printf                     @ call printf, return here
  b main
@*******************
invalidOperator:
@*******************
  ldr r0, =noValidOperator      @ load r0 with the noValidOperator string
  bl printf                     @ call printf, return here
  ldr r0, =progRestart          @ load r0 with the progRestart string
  bl printf                     @ call printf, return here
  b main                        @ branch to main

@*******************
wrapUpWithRemainder:
@*******************

  pop {r4}                      @ remainder
  pop {r5}                      @ quotient
  ldr r0, =resultWithRemainder  @ load r0 with resultWithRemainder string
  mov r1, r5                    @ move quotient into r1 for printing
  mov r2, r4                    @ move remainder into r2 for printing

  push {lr}                     @ preserve link register
  bl printf                     @ call printf, return here
  pop {r1}                      @ pop stack into r1 (previous lr)
  mov lr, r1                    @ returning lr to original state

@*******************
continue:
@*******************
  ldr r0, =cont                 @ load r0 with cont string
  bl printf                     @ call printf, return here

  ldr r0, =opInputPattern       @ Setup to read in one char.
  ldr r1, =charInput            @ load r1 with the address of where the
                                @ input value will be stored.
  bl  scanf                     @ scan the keyboard.
  cmp r0, #CHAR_READERROR       @ Check for a read error.
  beq readerror                 @ If there was a read error go handle it.
  ldr r1, =charInput            @ Have to reload r1 because it gets wiped out.
  ldr r1, [r1]                  @ Read the contents of intInput and store in r1 so that
                                @ it can be stored.

  cmp r1, #0x59                 @ compare to "Y"
  it eq
  beq main                      @ if equal, branch to main
  cmp r1, #0x79                 @ compare to "y"
  it eq
  beq main                      @ if equal, branch to main
  cmp r1, #0x6e                 @ compare to "N"
  it eq
  beq myexit                    @ if equal, branch to myexit
  cmp r1, #0x4e                 @ compare to "n"
  it eq
  beq myexit                    @ if equal, branch to myexit

@***********
divByZero:
@***********

  ldr r0, =divByZeroError       @ load r0 with the divByZeroError string
  bl printf                     @ call printf, return here
  ldr r0, =progRestart          @ load r0 with the progRestart string
  bl printf                     @ call printf, return here
  b main                        @ branch to main

@***********
overflowDetected:
@***********
  push {lr}                     @ push link register to stack

  ldr r0, =overflowDetectedString @ load r0 with overflowDetectedString string
  bl printf                     @ call printf, return here

  pop {r1}                      @ pop stack into r1 (previous lr)
  mov lr, r1                    @ returning lr to original state

@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value.
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user
@ presses the CR.

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.
@  The input buffer should now be clear so get another input.

   b myexit


@*******************
myexit:
@*******************
  ldr r0, =exitNotice
  bl printf

@ End of my code. Force the exit and return control to OS

  mov r7, #0x01 @ SVC call to exit
  svc 0         @ Make the system call.


.data

@ Declare the strings and data needed


.balign 4
welcomeLab2: .asciz "Welcome to the Lab 2 program!\n"

.balign 4
instructions: .asciz "Enter a positive integer followed by one of {+,-,*,/} followed by another positive integer.\n"

.balign 4
sampleInput: .asciz "Sample: \n4\n/\n22\n\n"

.balign 4
inputFormatStr: .asciz "Please enter each value followed by a carriage return.\n"

.balign 4
cont: .asciz "Would you like to continue? (y/n)\n"

.balign 4
exitNotice: .asciz "Goodbye.\n"

.balign 4
result: .asciz "The result is %d\n"

.balign 4
resultWithRemainder: .asciz "The result is %d remainder %d\n"

.balign 4
overflowDetectedString: .asciz "Overflow detected... Calculation is incorrect\n"

.balign 4
invalidOperandString: .asciz "Invalid operand entered, please follow the instructions.\n"

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input.

.balign 4
noValidOperator: .asciz "Invalid operator entered, please follow the instructions.\n"

.balign 4
progRestart: .asciz "Program restarting...\n\n"

.balign 4
divByZeroError: .asciz "Division by zero detected, this is not allowed.\n"

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input.


@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read.

.balign 4
opInputPattern: .asciz "%s"   @ character format for read

.balign 4
intInput: .word 0   @ Location used to store the user input.

.balign 4
charInput: .word 0   @ Location used to store the user input.


@ Let the assembler know these are the C library functions.

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed.
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern,
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else.
@
@ Additional notes about scanf and the input patterns:
@    1. If the pattern is %s or %c it is not possible for the user input to generate
@       and error code. Anything that can be typed by the user on the keyboard
@       will be accepted by these two input patterns.
@    2. If the pattern is %d and the user input 12.123 scanf will accept the 12 as
@       valid input and leave the .123 in the input buffer.
@    3. If the pattern is "%c" any white space characters are left in the input
@       buffer. In most cases user entered carrage return remains in the input buffer
@       and if you do another scanf with "%c" the carrage return will be returned.
@       To ignore these "white" characters use " $c" as the input pattern. This will
@       ignore any of these non-printing characters the user may have entered.
@

@ End of code and end of file. Leave a blank line after this.
