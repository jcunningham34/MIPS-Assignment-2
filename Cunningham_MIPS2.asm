#MIPS 2 Assignment Jarrett Cunningham

.data #lets processor know that we will be submitting data to program

userinput: .space 1001 #Need space for a 1000 digit hex

prompt: .asciiz "Enter string: " 

outputmessage: .asciiz "\n The string you entered was "

invalid: .asciiz "NaN"

useroutput: .asciiz " "

stringlenmess: .asciiz "\n The length of this string is: "

nextline: .asciiz "\n"

comma: .asciiz ","

sizemess: .asciiz "too large"

.text

main: 

#prints prompt message

	la $a0, prompt #load prompt address from memory and store it in $a0

	li $v0, 4 #loading 4 into $v0 is the opcode to print a string

	syscall #executes the previous commands

#storing user input

    li $v0, 8 #op code for getting user input for a string

	la $a0, userinput #loads the address of space and stores it into $a0

	la $a1, 1001 #SPACE OF STRING

	syscall 

#prints user input

#	la $a0, outputmessage #load the address of message from memory and store it into $a0

#3	li $v0, 4 #opcode to print a string

#	syscall 

#	la $a0, userinput #load address for the users input from memory and store it into $a0

#	li $v0, 4 #opcode to print a string

#	syscall 	

jal subprogram_2 #Function call to actually convert the integer
jal subprogram_3 #function to print

exit: 

	li $v0, 10 #loads op code exit program

	syscall #exits program

#END OF MAIN

#FUNCTIONS USED IN THE MAIN FUNCTION

######################################
########################################Finding Length of String##########################################

getlength:

lb $t0,0($a0)

beq $t0,0,exit

beq $t0,44,exitgetlength #if there is a comma 

beq $t0,10,exitgetlength

addi $a0, $a0, 1

addi $t2,$t2, 1

move $s6,$t2 #this will be later used for if there is a 2s complement problem
 
beq $t0,9, spacelen #if theres a tab

beq $t0,32, spacelen #if theres a space

j getlength

spacelen:

sub $t2,$t2,1

j getlength

exitgetlength: #t2 has the length of the string
bgt $t2,8,printlarge
#move $s5,$a0

jr $ra

printlarge:
move $s5,$a0 #store the address value
la $a0,sizemess
li $v0,4
syscall

la $a0,comma
li $v0,4
syscall

li $t2,0
move $a0,$s5
addi $a0,$a0,1
j getlength

##########################################################################################################

####################SUBPROGRAM2 TO GET WHOLE STRING AND CONVERT TO DECIMAL#################################

 subprogram_2: #loop for conversion
 
 jal getlength

move $t5,$t2 #length is in $t5

sub $a0,$a0,$t5

startprog2:
	
	lb $t1,0($a0) #start searching each byte

	beq $t1,0,exit #exit program completely

	beq $t1,10,exitnprint #exit the program completely
	
	beq $t1,44,commafunct #once the program hits a comma it will drop into the comma function, print the value, re initialize the variables and send it back to the top of sub prog 2
	
	addi $a0,$a0,1 #move to the next byte
	
	sub $t5,$t5,1 #incrementing the length - 1
	
	jal subprogram_1

	j startprog2


	commafunct:

	move $s3,$t3 #save the overall value
	
	move $s4, $a0 #Address that the program left off from (the comma) will be loaded back into the a0 and then jump to the top of the subprogram 2 to redo the loop
	
	#bgt $s6,7,negnum

	jal subprogram_3
	
	li $t0,0 #initialize the i of this loop
	
	li $t2,0
	
	li $t3,0 #initialize overall number for output
	
	li $t4,0
	
	move $a0,$s4
	
	addi $a0,$a0,1 #takes the register off of the comma and gears it up for the next loop
	
	j subprogram_2 
	
#Accounting for 2 compliment
        exitnprint:
      #  bgt $s6,7,negnum
        move $a0, $t3
        li $v0,1
        syscall
        j exit
	
	negnum:
	la $a0, nextline #load the address of message from memory and store it into $a0

	li $v0, 4 #opcode to print a string

	syscall

	li $t7,10000

	move $t3,$s3

	divu $t3,$t3,$t7

	mflo $t7

	move $a0,$t7

	li $v0,1

	syscall

	mfhi $t7

	move $a0,$t7

	li $v0,1

	syscall

	j subprogram_2

#############################################################################################################

#############################SUBPROGRAM1 TO CONVERT EACH LETTER INTO DECIMAL#################################

subprogram_1:

	#Checking if the byte falls into the ranges then will send byte to designated loop


	beq $t1,32, Space
	beq $t1,9,Space
	
	blt $t1,48, Invalid 

	blt $t1,58, Decimal

	blt $t1,65, Invalid

	blt $t1,71, Uppercase

	blt $t1,97, Invalid

	blt $t1,103, Lowercase

	bgt $t1,102, Invalid
	 
	Space:
	
	addi $t5,$t5,1
	
	j subprogram_2

	Decimal:

	sub $t1,$t1,48 #subtract 48 to get the decimal number of the byte being checked $t1 is ripped char

	sll $t4,$t5,2 #shifting for the exponent value

	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number

	add $t3,$t3,$t2 #overall num is overall num plus value found in this loop

	jr $ra

	
	Uppercase:

	sub $t1,$t1,55 #subtract 55 to get the decimal number of the byte being checked

	sll $t4,$t5,2 #shifting for the exponent value

	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number

	add $t3,$t3,$t2 #overall num = overall num plus value found in this loop

	jr $ra

	

	Lowercase:

	sub $t1,$t1,97 #subtract 87 to get the decimal number of the byte being checked

	addi $t1, $t1, 10 #Add 10 for value

	sll $t4,$t5,2 #shifting for the exponent value

	sllv $t2,$t1,$t4 #Finding the actual value of the Hex number

	add $t3,$t3,$t2 #overall num = overall num plus value found in this loop

	jr $ra

	

	Invalid: #print invalid message and exit the loop

 	la $a0, invalid #print length premessage

	li $v0, 4 #opcode to print a string

	syscall
	
	la $a0,comma
        li $v0,4
        syscall
	
	move $a0,$s5
	
	addi $a0,$a0,1
	
	j subprogram_2

	 #RETURNS VALUE TO SUBP2

###########################################################################################################################

subprogram_3:#printing overall value

	 move $a0,$s3

	 li $v0,1

	 syscall
	 
	 la $a0,comma
	 
	 li $v0,4
	 
	 syscall
	 
	 jr $ra

