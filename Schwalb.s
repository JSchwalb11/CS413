@ Filename :    Schwalb.s
@ Author   :    Joseph Schwalb
@ Email    :    jds0099@uah.edu
@ CS413-02 :    2020
@ Purpose  :    ARM Lab 4: Simulate the operation of a coffee machine like Keurig.
@               
@         <SECRET CODE IS '9'>
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


@*******************
welcome_prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =welcomeLab4    @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt.

   mov r2, #48             @ move 48 into r2
   ldr r1, =waterLevel     @ load r1 with the address of waterLevel
   str r2, [r1]            @ store r2 in the contents of r1


@*******************
choose_coffee_size:
@*******************
  
  ldr r0, =choose_coffee_size_string  @ load r0 with the contents of choose_coffee_size_string
  bl printf                           @ branch to printf, return here

  ldr r0, =numInputPattern    @ Setup to read in one number.
  ldr r1, =intInput           @ load r1 with the address of where the
                              @ input value will be stored. 
  bl  scanf                   @ scan the keyboard.
  cmp r0, #READERROR          @ Check for a read error.
  beq readerror               @ If there was a read error go handle it.  
  ldr r1, =intInput           @ Have to reload r1 because it gets wiped out. 
  ldr r1, [r1]                @ Read the contents of intInput and store in r1 so that
                              @ it can be stored.
  ldr r2, =coffeeSize         @ load r2 with the address of coffeeSize
  str r1, [r2]                @ store r1 in the contents of r2

  cmp r1, #9                    @ compare r1 to secret code '9'
  ldreq lr, =choose_coffee_size @ if equal, load link register with the address of choose_coffee_size
  beq hidden_menu               @ if equal, branch to hidden menu

  cmp r1, #'t'
  beq myexit

  cmp r1, #'T'
  beq myexit


@*******************
check_reservoir:
@*******************
  ldr r1, =coffeeSize           @ load r1 with the address of coffeeSize
  ldr r1, [r1]                  @ load r1 with the contents of r1

  ldr r2, =waterLevel           @ load r2 with the address of waterLevel
  ldr r2, [r2]                  @ load r2 with the contents of r2
  
  cmp r1, #1                    @ check if small coffee
  subeq r2, r2, #6              @ if equal, decrement water level by 6
  cmp r2, #0                    @ check if water level is less than zero
  blt refill_reservoir          @ if less than, branch to refill_reservoir

  cmp r1, #2                    @ check if medium coffee
  subeq r2, r2, #8              @ if equal, decrement water level by 8
  cmp r2, #0                    @ check if water level is less than zero
  blt choose_another_size       @ if less than, branch to refill_reservoir

  cmp r1, #3                    @ check if large coffee
  subeq r2, r2, #10             @ if equal, decrement water level by 10
  cmp r2, #0                    @ check if water level is less than zero
  blt choose_another_size       @ if less than, branch to refill_reservoir


@*******************
brew:
@*******************
  
  ldr r0, =ready_to_brew        @ Put the address of my string into the first parameter
  bl  printf                    @ Call the C printf to display input prompt.
  ldr r0, =opInputPattern       @ Setup to read in one char.
  ldr r1, =charInput            @ load r1 with the address of where the
                                @ input value will be stored.
  bl  scanf                     @ scan the keyboard.
  cmp r0, #CHAR_READERROR       @ Check for a read error.
  beq readerror                 @ If there was a read error go handle it.
  ldr r1, =charInput            @ Have to reload r1 because it gets wiped out.
  ldr r1, [r1]                  @ Read the contents of intInput and store in r1 so that
                                @ it can be stored.

  cmp r1, #0x42                 @ Compare r1 with 'B'
  beq begin_brewing             @ if equal, branch to begin_brewing
  cmp r1, #0x62                 @ Compare r1 with 'b'
  beq begin_brewing             @ if equal, branch to begin_brewing
  
  cmp r1, #'9'                  @ Compare r1 with secret code '9'
  ldreq lr, =brew               @ if equal, load lr with address of brew
  beq hidden_menu               @ if equal, branch to hidden menu

  cmp r1, #'t'                  @ compare r1 to 't'
  beq myexit                    @ if equal, branch to myexit

  cmp r1, #'T'                  @ compare r1 to 'T'
  beq myexit                    @ if equal, branch to myexit

  bne brew                      @ if not equal, branch to brew


@*******************
begin_brewing:
@*******************

  ldr r1, =coffeeSize           @ load r1 with the address of coffeeSize
  ldr r1, [r1]                  @ load r1 with the contents of the address at coffeeSize

  ldr r2, =waterLevel           @ load r2 with the address of waterLevel
  ldr r2, [r2]                  @ load r2 with the contents of the address at waterLevel

  cmp r1, #1                    @ check if small coffee selected
  ldreq r4, =smallCoffeeCount   @ load r4 with address of smallCoffeeCount
  ldreq r3, [r4]                @ load r3 with the contents of the address in r4
  addeq r3, r3, #1              @ increment r3
  streq r3, [r4]                @ store r3 in contents of r4
  subeq r2, r2, #6              @ decrement r2 by 6 (waterLevel - coffeeSize )
  
  cmp r1, #2                    @ check if medium coffee selected
  ldreq r4, =mediumCoffeeCount  @ load r4 with the address of mediumCoffeeCount
  ldreq r3, [r4]                @ load r3 with the contents of r4
  addeq r3, r3, #1              @ increment r3
  streq r3, [r4]                @ store r3 in the contents of r4
  subeq r2, r2, #8              @ decrement r2 by 8 (waterLevel - coffeeSize)
  
  cmp r1, #3                    @ check if large coffee selected
  ldreq r4, =largeCoffeeCount   @ load r4 with the address of largeCoffeeCount
  ldreq r3, [r4]                @ load r3 with the contents of r4
  addeq r3, r3, #1              @ increment r3
  streq r3, [r4]                @ store r3 in the contents of r4
  subeq r2, r2, #10             @ decrement r2 by 10 (waterLevel - coffeeSize)

  ldr r1, =waterLevel           @ load r1 with the address of waterLevel
  str r2, [r1]                  @ store r2 in the contents of r1

  ldr r2, =coffeeSize           @ load r2 with the address of coffeeSize
  str r1, [r2]                  @ store r1 in the contents of r2

  ldr r0, =successful_brew      @ load r0 with the address of successful_brew
  bl printf                     @ branch to printf, return here

  b choose_coffee_size          @ branch to choose_coffee_size

@*******************
refill_reservoir:
@*******************

  mov r3, #0                        @ clear r3
  ldr r0, =refill_reservoir_string  @ load r0 with the address of refill_reservoir_string
  bl printf                         @ branch to printf, return here

  b myexit

@*******************
choose_another_size:
@*******************
  ldr r0, =choose_another_size_string  @ load r0 with the address of choose_another_size_string
  bl printf                            @ branch to printf, return here

  b choose_coffee_size                 @ branch to choose_coffee_size

@*******************
hidden_menu:
@*******************

  stmfd r13!, {r0-r3, lr}              @ store working registers and link register

  ldr r0, =water_remaining_string      @ load r0 with the address of water_remaining_string
  ldr r1, =waterLevel                  @ load r1 with the address of waterLevel
  ldr r1, [r1]                         @ load r1 with the contents of r1
  bl printf                            @ branch to printf, return here

  ldr r0, =coffee_count_string         @ load r0 with the address of coffee_count_string
  ldr r1, =smallCoffeeCount            @ load r1 with the address of smallCoffeeCount
  ldr r2, =mediumCoffeeCount           @ load r2 with the address of mediumCoffeeCount
  ldr r3, =largeCoffeeCount            @ load r3 with the address of largeCoffeeCount

  ldr r1, [r1]                         @ load r1 with the contents of r1
  ldr r2, [r2]                         @ load r2 with the contents of r2
  ldr r3, [r3]                         @ load r3 with the contents of r3
  bl printf                            @ branch to printf, return here

  ldmfd r13!, {r0-r3, lr}              @ restore working registers and link register

  mov pc, lr                           @ move link register into program counter

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

waterLevel:        .skip 4
coffeeSize:        .skip 4
smallCoffeeCount:  .skip 4
mediumCoffeeCount: .skip 4
largeCoffeeCount:  .skip 4

.balign 4
welcomeLab4: .asciz "Welcome to the Coffee Maker\nInsert K-cup and press B to begin making coffee.\nPress T to turn off the machine.\n"

.balign 4
choose_coffee_size_string: .asciz "1. Small (6 oz)\n2. Medium (8 oz)\n3. Large (10 oz)\n<9. Hidden Menu>\n"

.balign 4
choose_another_size_string: .asciz "Not enough water left for that size, please choose a smaller size.\n"

.balign 4
ready_to_brew: .asciz "Ready to Brew!\nPlease place a cup in the tray and press B to begin brewing.\n"

.balign 4
successful_brew: .asciz "Done brewing, enjoy!\n"

.balign 4
refill_reservoir_string: .asciz "Please refill reservoir.\n"

.balign 4
water_remaining_string: .asciz "Water remaining: %d\n"

.balign 4
coffee_count_string: .asciz "Small Coffee Count: %d\nMedium Coffee Count: %d\nLarge Coffee Count: %d\n"

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
opInputPattern: .asciz "%s"   @ character format for read

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

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
