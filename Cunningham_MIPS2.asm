#MIPS 2 Assignment Jarrett Cunningham

.data #lets processor know that we will be submitting data to program



userinput: .space 1001 #Need space for a 1000 digit hex

prompt: .asciiz "Enter string: " 

outputmessage: .asciiz "\n The string you entered was "

invalid: .asciiz "\nInvalid hexadecimal number.\n"

useroutput: .asciiz " "

stringlenmess: .asciiz "\n The length of this string is: "

nextline: .asciiz "\n"





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

	la $a0, outputmessage #load the address of message from memory and store it into $a0

	li $v0, 4 #opcode to print a string

	syscall 

	la $a0, userinput #load address for the users input from memory and store it into $a0

	li $v0, 4 #opcode to print a string

	syscall 	



#Converting Userin into Decimal

  

  #Function call to pull in the length of the string

 jal getlength

 move $t5,$t2 #length is in $t5

 move $s0,$t5 #length of string

 li $t0,0 #initialize the i of this loop

 li $t3,0 #initialize overall number for output

li $t2,0
li $t4,0
la $a0,userinput #loading the users input

jal subprogram_2 #Function call to actually convert the integer
jal subprogram_3 #function to print

exit: 

	li $v0, 10 #loads op code exit program

	syscall #exits program

#FUNCTIONS USED IN THE MAIN FUNCTION


######################################

######################################
########################################Finding Length of String##########################################

#li $t2,0 #initialize count to zero

getlength:

 lb $t0,0($a0)

 beq $t0,0,exitgetlength

 beq $t0,10,exitgetlength

 addi $a0, $a0, 1

 addi $t2,$t2, 1
 
 beq $t0,9, spacelen
 beq $t0,32, spacelen
 
  j getlength

spacelen:
 sub $t2,$t2,1
 j getlength
 
 


 exitgetlength:

 #move $a0, $t2 

 #prints user input length

    la $a0, stringlenmess #print length premessage

	li $v0, 4 #opcode to print a string

	syscall

	
move $a0,$t2
	li $v0, 1 #opcode to print the length of the string

	syscall 
	la $a0, nextline
	li $v0,4
	syscall
 jr $ra	
	#$a0 now has the length of the string

##########################################################################################################

 

 ####################SUBPROGRAM2 TO GET WHOLE STRING AND CONVERT TO DECIMAL#################################

 subprogram_2: #loop for conversion

	lb $t1,0($a0) #start searching each byte

	beq $t1,0,exitsubprogram_2

	beq $t1,10,exitsubprogram_2
	
	addi $a0,$a0,1 #move to the next byte

	sub $t5,$t5,1 #incrementing the length - 1
	

	jal subprogram_1

	

	j subprogram_2

	

	exitsubprogram_2:

	move $s3,$t3 #save the overall value

	bgt $s0,7,negnum

	j subprogram_3

#Accounting for 2 compliment

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

	

	jr $ra

#############################################################################################################



#############################SUBPROGRAM1 TO CONVERT EACH LETTER INTO DECIMAL#################################

subprogram_1:

	#Checking if the byte falls into the ranges then will send byte to designated loop


	beq $t1,32, Space
	beq $t1,9,Space
	#beq $t1,44,Comma
	blt $t1,48, Invalid 

	blt $t1,58, Decimal

	blt $t1,65, Invalid

	blt $t1,71, Uppercase

	blt $t1,97, Invalid

	blt $t1,103, Lowercase

	bgt $t1,102, Invalid

	#Comma:
	#will print current value of t4, reset t5 and t4, and print the comma
	 #move $a0,$t3

	 #li $v0,1

	 #syscall
	 
	 #move $a0,$t1
	 
	 #li $v0,4
	 
	 #syscall
	 
	 #li $t4,0
	 #li $t5,0
	 
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

	#addi $t1, $t1, 10 #Adding 10

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
	
	j exit

	 #RETURNS VALUE TO SUBP2

###########################################################################################################################

subprogram_3:#printing overall value

	 move $a0,$s3

	 li $v0,1

	 syscall
	 
	 jr $ra

