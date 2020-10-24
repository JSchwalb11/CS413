@ Filename :    CS413_Schwalb_Lab1.s
@ Author   :    Joseph Schwalb
@ Email    :    jds0099@uah.edu
@ CS413-02 :    2020
@ Purpose  :    ARM Lab 1: Use the ARM Auto-Indexing
@               to access array elements and to do nested subroutine calls.
@ 
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o CS413_Schwalb_Lab1.o CS413_Schwalb_Lab1.s
@    gcc -o CS413_Schwalb_Lab1 CS413_Schwalb_Lab1.o
@    ./CS413_Schwalb_Lab1 ;echo $?
@    gdb --args ./CS413_Schwalb_Lab1

@ ***********************************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ***********************************************************************

.equ READERROR, 0 @Used to check for scanf read error.

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
 
   ldr r0, =welcomeLab1    @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

@*******************
writeArrays:
@*******************

   mov r2, #0                  @ loop counter
   mov r3, #0                  @ index offset (4 byte words)
   mov r4, #0                  @ arr


@*******************
firstArray:
@*******************
   ldr r4, =arr1               @ load r1 with the address of our first array

loopArr1:

   str r2, [r4]            @ store the counter in the element
   add r4, r4, #4
   add r2, r2, #1              @ increment counter
   cmp r2, #10                 @ compare counter with #11
   it lt
   blt loopArr1                @ if < 10 loops, continue to loopArr1


@*******************
secondArray:
@*******************
   ldr r4, =arr2               @ load r4 with the pointer to the next array

   ldr r0, =inputFormatStr     @ Put the address of my string into the first parameter
   bl  printf                  @ Call the C printf to display input prompt.
   mov r5, #0                  @ set counter to zero for next array

loopArr2:
   ldr r0, =loopArr2
   add r0, r0, #8
   @add r0, r0, #16
   mov lr, r0
   b userInput                @ branch to userInput subroutine, return here after
   str r1, [r4]            @ store contents returned from userInput into r4
   add r4, r4, #4
   @str r5, [r4], #4            @ store the counter in the element
   add r5, r5, #1              @ increment counter
   cmp r5, #10                 @ compare counter with #11
   blt loopArr2                @ if < 10 loops, continue to loopArr2
   
   b thirdArray                @ else branch to thirdArray


@*******************
userInput:                     
@*******************
   
   @stmfd sp!, {r2-r4, lr}     @ store working registers {r2-r4, lr}
   push {lr}
   push {r4}
   push {r3}
   push {r2}

   ldr r0, =numInputPattern    @ Setup to read in one number.
   ldr r1, =intInput           @ load r1 with the address of where the
                               @ input value will be stored. 
   bl  scanf                   @ scan the keyboard.
   cmp r0, #READERROR          @ Check for a read error.
   it eq
   beq readerror               @ If there was a read error go handle it.  
   ldr r1, =intInput           @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]                @ Read the contents of intInput and store in r1 so that
                               @ it can be stored.

   pop {r2}
   pop {r3}
   pop {r4}
   pop {r0}
   mov lr, r0
   
   @ldmfd sp!, {r2-r4, lr}     @ reload working registers from stack {r2-r4, lr}
   mov pc, lr                 @ move lr to pc to step out of subroutine

   

@*******************
thirdArray:
@*******************   
   ldr r4, =arr1               @ load r4 with the pointer to arr1
   ldr r5, =arr2               @ load r5 with the pointer to arr2
   ldr r6, =arr3               @ load r6 with the pointer to arr3
   @mov r7, #0                  @ clear register, used for scratch
   @mov r8, #0                  @ clear register, used for scratch
   @mov r9, #0                  @ clear register, used for scratch
   mov r0, #0                  @ replaces r7
   mov r1, #0                  @ replaces r8
   mov r2, #0                  @ set counter to zero
   mov r3, #0                  @ replaces r9
 

@*******************
multArr1Arr2:
@*******************   
   
   ldr r0, [r4]            @ load r7 with arr1 element
   add r4, r4, #4
   ldr r1, [r5]            @ load r7 with arr2 element
   add r5, r5, #4
   @mul r3, r1, r0              @ multiply r8, r7 (contents of arr1,arr2), store in r9
   mul r1, r1, r0
   mov r3, r1

   str r3, [r6]            @ store multiplication results in arr3
   add r6, r6, #4
   add r2, r2, #1              @ increment pointer
   cmp r2, #10                 @ compare counter with #10
   bne multArr1Arr2            @ if < 10 loops, continue to multArr1Arr2


@*******************   
wrapUp:
@*******************   
   ldr r0, =arr1String         @ load r0 with string for printing
   bl printf                   @ branch to printf, return here after

   ldr r4, =arr1               @ load r4 with arr1
   push {r4}                   @ push r4 to stack for use as parameter
   bl printArray               @ branch with link to printArray
   pop {r4}                    @ pop r4 from stack

   ldr r0, =arr2String         @ load r0 with string for printing
   bl printf                   @ branch to printf, return here after

   ldr r4, =arr2               @ load r4 with arr2
   push {r4}                   @ push r4 to stack for use as parameter
   bl printArray               @ branch with link to printArray
   pop {r4}                    @ pop r4 from stack

   ldr r0, =arr3String         @ load r0 with string for printing
   bl printf                   @ branch to printf, return here after

   ldr r4, =arr3               @ load r4 with arr3
   push {r4}                   @ push r4 to stack for use as parameter
   bl printArray               @ branch with link to printArray
   pop {r4}                    @ pop r4 from stack

   b myexit                    @ branch to myexit


@***********
printArray:
@***********
   @stmfd r13!, {r2-r4, lr}     @ store working registers {r2-r4, lr}
   push {lr}
   push {r4}
   push {r3}
   push {r2}

   ldr r4, [sp, #16]           @ pull the array pointer from the stack (16 spots above sp)
   mov r5, #0                  @ loop counter, different for this subroutine because printf quashes r2

printLoop:

   mov r1, r5                  @ move counter into r1 for printing
   ldr r2, [r4]            @ load element in array into r2 for printing
   add r4, #4
   bl _printf                  @ call printf, return after
   
   add r5, r5, #1              @ increment pointer
   cmp r5, #10                 @ compare counter with #10
   it ne
   bne printLoop               @ if < 10 loops, continue to printLoop
   
   pop {r2}
   pop {r3}
   pop {r4}
   pop {r0}
   mov lr, r0

   @ldmfd r13!, {r2-r4, lr}     @ reload working registers from stack {r2-r4, lr}

   mov pc, lr                 @ return from subroutine

@***********
_printf:
@***********

    PUSH {LR}               @ store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return

   
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
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @ SVC call to exit
   svc 0         @ Make the system call. 


.data

@ Declare the strings and data needed


arr1: .skip 40                 @ 4 bytes * 10 elements = 40 bytes
arr2: .skip 40                 @ 4 bytes * 10 elements = 40 bytes
arr3: .skip 40                 @ 4 bytes * 10 elements = 40 bytes

.balign 4
arr1String: .asciz "\nArray 1 contents:\n"

.balign 4
arr2String: .asciz "\nArray 2 contents:\n"

.balign 4
arr3String: .asciz "\nArray 3 contents:\n"

.balign 4
printf_str:     .asciz      "a[%d] = %d\n"

.balign 4
welcomeLab1: .asciz "Welcome to the Lab 1 program, please enter 10 positive numbers.\n"

.balign 4
inputFormatStr: .asciz "Please enter each value followed by a carriage return.\n"

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
intInput: .word 0   @ Location used to store the user input.


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
