########################################################################
# Program: Robots games Homework 5	          Programmer: Alan Huang
# Due Date: Dec 12, 2019			  Course: CS2640
########################################################################
# Overall Program Functional Description:
#	This programs is a Robots game.  This parts of programs will make
#       robots to chase player. Also, my programs is little different than
#       the orginal one since the Pseudocodes for initBoard was provided
#       after I finished the whole homework 3, 4, 5. I also have a 
#	print board method to print my board. (I didn't know how use
#	stack to store my value before, so I almost use all of the 
#	registers but it's too hard to chage it to stack now and everything
#	 work ok. Sorry aboout that.)
########################################################################
# Register usage in Main:
# $a0, $v0 -- Subroutine parameter and return passing.
# $a0 -- also use $a0 with syscall to print
# $t9 -- Pointer I pass to every movement
########################################################################
# Pseudocode Description:
#	1. Print a enter seed number message
#	2. Read the seed number
#	3. Call seedrand and sent seed number to that function
#	4. Call initBoard to setup my board
#	5. Call addWalls to place wall at random place 
#	6. Call placeObj and sent 1 to place player
#	7. Call drawobj to write placer location into array
#	8. Adding robot to the game 
#	9. Print message and ask player for movement input
#	10. Main loop
#		10a. if input is u call eraseobj to erase X to a .
#		10a. call moveN to calculate player new location
#		10a. Call CheckMove to see if new location is safe
#		10a. Call drawobj to draw  player new location
#		10a. CAll PrintaAfter to print new board
#		10b. if input is d call eraseobj to erase X to a .
#		10b. call moveS to calculate player new location
#		10b. Call CheckMove to see if new location is safe
#		10b. Call drawobj to draw  player new location
#		10b. CAll PrintaAfter to print new board
#		10c. if input is l call eraseobj to erase X to a .
#		10c. call moveW to calculate player new location
#		10c. Call CheckMove to see if new location is safe
#		10c. Call drawobj to draw  player new location
#		10c. CAll PrintaAfter to print new board
#		10d. if input is r call eraseobj to erase X to a .
#		10d. call moveE to calculate player new location
#		10d. Call CheckMove to see if new location is safe
#		10d. Call drawobj to draw  player new location
#		10d. CAll PrintaAfter to print new board
#		10e. if input is j call eraseobj to erase X to a .
#		10e. call moveJ to calculate player new location
#		10e. Call drawobj to draw  player new location
#		10e. CAll PrintaAfter to print new board
#               10f. if input is p just CAll PrintaAfter to print new board
#		10g. if input is q end the game
#		10h. Move each robot
#	11. Programe will keep looping unless player input q to end the game
#           or hit a wall
#	12. There are few different ending if player hit a wall call EXIT
#	13. If user enter q go to Exit3 to print GAME OVER
#		
#
########################################################################
		.data
		MSG1: 	   .asciiz "Enter a seed number: "
		MSG2: 	   .asciiz "Enter u to moveup, d to move down i to move left, r to move right, p to pause, j to jump to a random loaction \n"
		MSG3:	   .asciiz "Please enther you movement: "
		MSG4:	   .asciiz "Oh no you hit a wall!!! \n\n"
		MSG5:	   .asciiz "Oh no a robot kiled you!! \n\n"	
		MSG6:	   .asciiz "GAME OVER"
		MSG7:	   .asciiz "All robot die you win!!"
		newLine:   .asciiz "\n"
		newLines:  .asciiz "\n\n\n\n\n"
		newSpace:  .asciiz " "
		wid:	   .word 39  #Row number
		hgt:	   .word 30  #Col number
		linelen:   .word 39  # wid ( I don't have \n in my array, so no +1)
		numwalls:  .word 50
		boardlen:  .word 1170  #wid * hgt
		byte:      .word 4
		numrobots: .word 20 # How many robots to add to the game
		numalive: .word 20
		OffsetRo:  .word 16	
		myArray:   .space 4680
		PlayerObjects:   .space 340
		
	.globl main
	.text
main:	
	li $v0, 4     	    	# Call the Print String I/O service to print (1)
  	la $a0, MSG1  	 	# Call MSG1 to ask user to input seed number (1)
	syscall                 #(1)
	
	li $v0, 5   		# Call the Read Integer I/O Service to get the (2)
	syscall			# read user seed number (2)
	
	move $a0, $v0 		# Move the number to $a0, for the subroutine (3)
	jal seedrand 		# Call the 'seedrand' function to save this value (3)
	jal initBoard	        # Call the initBoard to set up the Board (4)
	jal addWalls		# Call addWalls to place wall at random place (5)

#We star adding person to the map by pass 1 to placeObj (6)
		move $s2, $zero 	#set s2 to 0  (6)
		addi $s2,$s2, 1		#set s2 to 1 so we can pass to placeObj(6)
		move $t9, $zero		#Set index to 0 (6)
	jal placeObj			#(6)
	jal drawobj			#(7)
#************	
		move $s2, $zero 	#set s2 to 0 (8)
		addi $s2,$s2, 2		#Set s2 to 2 for robot type (8)		
	move $t8, $zero 	#Zero our loop counter (8)	
	move $t9, $zero		#Set index to 0 (8)	
	lw   $t7, OffsetRo	#Load our offset to correct index (8)	
AddingRobot:
	addi $t8, $t8, 1 	#Loop counter (8)	
	mult $t7, $t8		#Correct the offset by 16 (8)	
	mflo $t9           	#$t9 has the correst index (8)	
	jal placeObj
	jal drawobj
	bne $t8, 20 AddingRobot	#If not equal to 0 go back to AddingRobot (8)	
	jal PrintBoard
	lw $s5, numalive	#Robot alive counter (8)	
#***********	
#Ask user for movement (9)
		li $v0, 4
		la $a0, newLines
		syscall
	
		li $v0, 4     	 	# Call the Print String I/O service to print (9)
  		la $a0, MSG2  		# call MSG2 (9)
		syscall
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		addi $s6, $zero, 19 
		
mainLoop:		
		li $v0, 4     	 	# Call the Print String I/O service to print (9)
  		la $a0, MSG3  		# call MSG3 (9)
		syscall	
				
		li $v0, 12   		# Call the Read char to read input (9)
		syscall
		
		move $t8, $v0		#Move user input into t8 (9)
		li $v0, 4     	 	# Call the Print String I/O service to print (9)
  		la $a0, newLines  	# call MSG2 (9)
		syscall
				
		#Moving option		
moveUp:		
		bne $t8, 117, moveDown  # If not u go to moveDown(10a)
		move $t9, $zero		#Set index to 0 (10a)
			jal eraseobj	#(10a)
			jal moveN
			jal checkmove
		move $t9, $zero		#Set index to 0	 (10a)				
			jal drawobj
			j PrintAfter

moveDown:			
		bne $t8, 100, moveLeft	#If not d go to moveLeft (10b)
		move $t9, $zero		#Set index to 0 (10b)
			jal eraseobj
			jal moveS
			jal checkmove	
		move $t9, $zero		#Set index to 0	(10b)			
			jal drawobj
			j PrintAfter

moveLeft:	
		bne $t8, 108, moveRight	#If not l go to moveRight (10c)
		move $t9, $zero		#Set index to 0 (10c)
			jal eraseobj
			jal moveW
			jal checkmove	
		move $t9, $zero		#Set index to 0	(10c)			
			jal drawobj
			j PrintAfter

moveRight:
		bne $t8, 114, moveJump	#If not r go to moveJump (10d)
		move $t9, $zero		#Set index to 0 (10d)
			jal eraseobj
			jal moveE
			jal checkmove
		move $t9, $zero		#Set index to 0	(10d)				
			jal drawobj
			j PrintAfter

moveJump:
		bne $t8, 106, Pause	#If not j go to Pausse (10e)
		move $t9, $zero		#Set index to 0 (10e)
			jal eraseobj
			jal moveJ
		move $t9, $zero		#Set index to 0	(10e)				
			jal drawobj
			j PrintAfter			
Pause:
		bne $t8, 112, QuitGame #If not p go to QuitGame (10f)
		j PrintAfter	

QuitGame:	
		bne $t8, 113, mainLoop#If not thing match go back and ask movement again (10g)
		j Exit3	
					
checkmove:
		addiu $sp, $sp, -4 #Save the return address on the stack
		sw $ra, 0($sp)	   #Save the return address on the stack
		move $t9, $zero		#Set index to 0	
		jal whatthere
		lw $ra, 0($sp)	   #Restore the return address	
		addiu $sp, $sp, 4  #Restore the return address
		jr $ra 		   #Return	
PrintAfter:	
#Robot movement 
	move $t8, $zero 	#Zero our loop counter (10h)
	move $t9, $zero		#Set index to 0 (10h)
	lw   $t7, OffsetRo	#Load our offset to correct index (10h)	
#********	
MoveRobotLoop:
	addi $t8, $t8, 1 	#Loop counter (10h)
	mult $t7, $t8		#Correct the offset by 16 (10h)
	mflo $t9           	#$t9 has the correst index (10h)
	jal moveRobot 		# (10h)
	beq $v0, 1, Exit2
	bne $t8, 20 MoveRobotLoop	#If not equal to 0 go back to AddingRobot (10h)	

		jal PrintBoard
		j mainLoop # keep loop until all robot or player die (11)	
#********								

Exit:
	li $v0, 4     	 		# Call the Print String I/O service to print (12)
  	la $a0, MSG4  			# call MSG4 (12)
		syscall
	li $v0, 4     	 		# Call the Print String I/O service to print (12)
  	la $a0, MSG6  			# call MSG6 (12)
		syscall
	li, $v0, 10
	syscall
Exit2:
	li $v0, 4     	 		# Call the Print String I/O service to print
  	la $a0, MSG5  			# call MSG5
		syscall
	li $v0, 4     	 		# Call the Print String I/O service to print
  	la $a0, MSG6  			# call MSG5
		syscall
	li, $v0, 10
	syscall	
Exit3:	
	li $v0, 4     	 		# Call the Print String I/O service to print (13)
  	la $a0, MSG6  			# call MSG6 (13)
		syscall
	li, $v0, 10
	syscall
Win: 	
	li $v0, 4     	 		# Call the Print String I/O service to print
  	la $a0, MSG7  			# call MSG7
		syscall
	li, $v0, 10
	syscall	
										

		
########################################################################
# Function Name: printBoard
########################################################################
# Functional Description:
#  This method will print myArray like a 2 x 2 array. This is like a 
#  Nested Loop in Java
#
########################################################################
# Register Usage in the Function:
# -- Since this calls subroutines, we save $ra on the stack, then
# -- restore it. We also save $s0 and $s1 on the stack.
# $t4 -- Loop counter: how many rows left to print
# $s1 -- Use to load array into it and print
# $t0 -- Pointer use to print next index
# $a0 -- Use $a0 with syscall to print
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address and S registers on the stack
# 2. set pointer to 0
# 3. Use width value as a counter to print each rows
# 4. Loop by the number of rows to place and how many array left.
# 4a.when the row counter is 0 go to next loop and print a \n
# 4b.check if the pointer is at 4680 if not good back to For2 and print 
#    next rows
# 5. Restore the return address and S registers
########################################################################	
PrintBoard:	
	addiu $sp, $sp, -4 	#Save the return address on the stack (1)
	sw $ra, 0($sp)	   	#Save the return address on the stack (1)	
	addi $t0, $zero, 0	#Set index bakc to 0 (2)	
	lw $t4, wid		#Loop counter: how many rows left to print (3)	

	li $v0, 4
	la $a0, newLine 	# This will print newLine
	syscall	
########################################################################
# Inner for loop		
For2:
	beq $t0, 4680, End 	# loop control If pointer is at last index end printBoard (4)
	beqz $t4, For1 		# If row counter equal zero end program	
	lw $s1, myArray($t0) 	# load corrent corrent location array into t6
	#Print current number.
	li $v0, 11    		# Use 11 to print ASCII  
	move $a0 $s1		# Move t6 to a0 to print
	syscall
	#Prints a new space.
	li $v0, 4
	la $a0, newSpace
	syscall
	
	addi $t0, $t0, 4 	# Pointer add 4 to go to next offset
	addi $t4, $t4, -1	# Row counter -1		
	j For2   		# go back to For2
########################################################################
# Outer for loop		
For1:
	#Prints a new line.
	li $v0, 4
	la $a0, newLine
	syscall	

	add $t4, $zero, $t3	#Reset the row counter 
	bne $t0, 4680, For2 	# if still array left keep printing
########################################################################	
End:
	li $v0, 4     	 	 # Call the Print String I/O service to print
  		la $a0, newLine  # call newLine
		syscall
	lw $ra, 0($sp)        #Restore the return address (5)
	addiu $sp, $sp, 4     #Restore the return address (5)
	jr $ra                #Return 	 
########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
# This routine initializes the board. This will be a 2D array in
# row-order. The edges of the board will all be Wall characters ('#'),
# and the center will be filled with '.'. At the end of each row
# will be a newline, and at the end of the array will be a 0 to terminate
# the string.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls subroutines, we save $ra on the stack, then
# -- restore it. We also save $s0 and $s1 on the stack.
# $a0, $v0 -- Subroutine parameter and return passing.
# $s0 -- Loop counter: how many walls still to place
# $s1 -- The x-coordinate of the wall
# $t0 -- Pointer where to store the wall in the board
# $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address and S registers on the stack
# 2. Use boardlen as my counter
# 3. Use $t4 as my counter and $t3 to reset $t4 when it became 0
# 4. Use $t2 as my column counter
# 5. Loop by the column and row number
#	5a If it is rows 1 and 30  write # only
#	5b If not write # to first and last columns and rest with "."
# 6. When pointer is 4680 go back the main
# 7. Restore the return address
#
########################################################################
#Start
initBoard:
	addiu $sp, $sp, -4 	#Save the return address on the stack (1)
	sw $ra, 0($sp)	   	#Save the return address on the stack (1)
	lw $t1, boardlen  	#Use boardlen as my counter (2)
	addi $t0, $zero, 0      #Index = $t0	
	
	#This loop will write my value into my array 
	#Below give a row col counter
	lw $t4, wid	#ROW my Row counter (3)
	lw $t3, wid     #Use $t3 to reset my $t4 Row counter (3)	
	lw $t2, hgt     #Use $t2 as my Col counter (4)
#######################################################################
#Below is my nested loops   (5)                                          #
#######################################################################	
loop2:  #my inner loop (this will print last row with # only) (5a)
	bne $t2, 30, Option2      # 30 and 1 is the border so only need to write # into Boarder (5a)
	addiu $s0, $zero, 35      # number 35 in ASCII is #. I will save in to $s0 (5a)
	sw $s0, myArray($t0)      #Store ($s0) into myArray and t0 is my pointer (5a)
		addi $t0, $t0, 4  # move offset to next location (5a)
		addi $t4, $t4, -1 # -1 to my Row counter (5a)
	bnez  $t4, loop2          #if Row counter is not zero keep printing (5a)
	j loop1			  # Once Row counter is 0 go to loop1 (5a)
Option2:	# This will print first row with # only (5a)
#If = 1 Print all #	
	bne $t2, 1, Option3      # 30 and 1 is the border so only need to write # into Boarder (5a)
	addiu $s0, $zero, 35     # number 35 in ASCII is #. I will save in to $s0 (5a)
	sw $s0, myArray($t0)     # Store ($s0) into myArray and t0 is my pointer (5a)
		addi $t0, $t0, 4 # move offset to next location (5a)
		addi $t4, $t4, -1
	bnez  $t4, loop2         # if Row counter is not zero keep printing (5a)	 	
	j loop1                  # Once Row counter is 0 go to loop1 (5a)	
	
Option3:	#This part will print the row 2 to 29. First and last col is # and other is all "." (5b)
	OptionA:
		bne $t4, 1, OptionB   # If row = 1 print print # (5b)
		addiu $s0, $zero, 35  # number 35 in ASCII is # i will use t1 to write it to my array (5b)
		sw $s0, myArray($t0)  # Store ($s0) into myArray and t0 is my pointer (5b)
		addi $t0, $t0, 4      # move offset to next location  (5b)
		addi $t4, $t4, -1 
		bnez  $t4, loop2      #if wid is finish with 10 go to new hgt	 (5b)	
		j loop1               # While loop (5b)
	OptionB:
		bne $t4, 39, OptionC  # If row = 39 print print # (5b)
		addiu $s0, $zero, 35  # number 35 in ASCII is # i will use t1 to write it to my array (5b)
		sw $s0, myArray($t0)  # Store ($s0) into myArray and t0 is my pointer (5b)
		addi $t0, $t0, 4      # move offset to next location (5b)
		addi $t4, $t4, -1
		bnez  $t4, loop2      #if wid is finish with 10 go to new hgt (5b)	 	
		j loop1               # While loop (5b)	
	OptionC:
		addiu $s0, $zero, 46  # number 46 in ASCII is . i will is t1 to write it to my array (5b)
		sw $s0, myArray($t0)  # Store ($s0) into myArray and t0 is my pointer (5b)
		addi $t0, $t0, 4      # move offset to next location (5b)
		addi $t4, $t4, -1
		bnez  $t4, loop2      #if wid is finish with 10 go to new hgt (5b)		
		j loop1               # While loop (5b)		
		
###############################################		
loop1:  #my Outter loop
	add $t4, $zero, $t3  #Reset Row
	addi $t2, $t2, -1
	bne $t0, 4680, loop2 # if there still are arrays left keep writing (6)
	bne $t2, 0  loop2    # if col not equal to 0 go back to loop2		
##############################################	
	lw $ra, 0($sp)        #Restore the return address (7)
	addiu $sp, $sp, 4     #Restore the return address (7)
	jr $ra                #Return    
	
########################################################################
# Function Name: addWalls
########################################################################
# Functional Description:
# This routine adds extra walls in the middle of the board. The global
# numWalls indicates how many to add. Since we randomly place these,
# it is possible we will place some at the same spot, so there might
# be somewhat fewer than numWalls.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls subroutines, we save $ra on the stack, then
# -- restore it. We also save $s0 and $s1 on the stack.
# $a0, $v0 -- Subroutine parameter and return passing.
# $s0 -- Loop counter: how many walls still to place
# $s1 -- The x-coordinate of the wall
# $t0 -- Pointer where to store the wall in the board
# $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address and S registers on the stack
# 2. Loop based on the number of walls to place:
# 2a. Get a random X coordinate (into $s0) and random Y coordinate.
# 2b. Compute Y * linelen + X
# 2c. Compute the final pointer by adding the 2b value to the address
# of the board.
# 2d. Store a wall character at that pointer.
# 5. Restore the return address and S registers
#
########################################################################
addWalls:
	addiu $sp, $sp, -4 #Save the return address on the stack
	sw $ra, 0($sp)	   #Save the return address on the stack
	lw $s0, numwalls   #load 50 into loop counter (2)
	
addLoop:		
	jal randX  	#Get a int for x Ths number is in v0 (2a)
	move $s1, $v0   #Move v0 to S0 (X into s1) (2a)			
	jal randY  	#Get a int for y(2a) The numbe is in V0 (2b)
	lw $t1, linelen #move linelen into t5 (2b)
	mult $t1, $v0	#Multiply Y to linelen (2b)
	mflo $t1        #Result of Y * linelen  (2b)
	
	add $t1, $t1, $s1 #Result of (Y * linelen + X) (2b)	
	#Row major
	lw $s1, byte 	#(byte = 4) (2c)
	mult $t1, $s1	#Multiply Y to linelen (2c)
	mflo $t1	
       ##################################
       #  Add wall to that location (2d)#    
       ##################################
	addiu $s1, $zero, 35  #Number 35 in ASCII is # I will add it to the board (2d)
	sw $s1, myArray($t1)  #Store $s1 into pointer location at $t1
		addi $s0, $s0, -1     # -1 to my loop counter
	bnez  $s0, addLoop    #If t4 is not 0 go back to addWalls
	lw $ra, 0($sp)        #Restore the return address (5)
	addiu $sp, $sp, 4     #Restore the return address (5)
	jr $ra                #Return    (5)
########################################################################
# Function Name: placeobj(idx, type)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. $a1 is the type for
# this object. Create a new object, then find a place for it on the
# board.
#
########################################################################
# Register Usage in the Function:
# $s1 -- Index of object in question
# $t9 -- pointer to the object's structure.
# $t5, $t6 -- general calculations.
# $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save space on the stack for the return address and $s0
# 2. Set $s0 to the pointer to this object
# 3. Store the type of the object
# 4. Compute a random X and random Y for the object, storing these.
# 5. Compute the pointer to this location on the board.
# 6. See if the location is empty ('.'). If not, loop back to 4.
#
########################################################################
placeObj:
	addiu $sp, $sp, -4 		#Save the return address on the stack
	sw $ra, 0($sp)	   		#Save the return address on the stack
GetNewPlayer:	
	sw $s1, PlayerObjects($t9)       #We will save a zero to index 0 first 
	jal randX  			 #(4)Get a int from randX for this object
	move $s1, $v0  			 #Move v0 to S1 (X into s1)
		addi $t9, $t9, 4		
	sw $s1, PlayerObjects($t9)       #Store X Value
	jal randY 			 #(4)Get a int from randY for this object
	move $s1, $v0   #Move v0 to S1 (X into s1)
		addi $t9, $t9, 4
	sw $s1, PlayerObjects($t9)      #Store Y Value
		addi $t9, $t9, 4
	sw $s2, PlayerObjects($t9)      #Store player type
	#We finish saving player X Y values
	#Calculate player location in array	
		addi $t9, $t9, -4  	#Now we will load Y value to calculate	
	lw $t5, PlayerObjects($t9) 	#Load Y into t5	
		addi $t9, $t9, -4
	lw $t6, PlayerObjects($t9) 	#Load X into t6																								
	lw $s1, linelen 		#Move linelen into s1
	mult $t5, $s1			#Multiply Y to linelen
	mflo $t5        		#Result of Y * linelen
		add $t5, $t5, $t6 	#Result of (Y * linelen + X)
	#Row major
	lw $s1, byte			#Times 4 byte 	
	mult $t5, $s1			#Multiply Y to linelen
	mflo $t5			#Final result
	#Save this to index 0
		addi $t9, $t9, -4 	#Set index to 0
	sw $t5, PlayerObjects($t9)	#Now I save the object location to index 0		
	#We need to see if that location is safe to add object there
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		add $t0, $zero, $t5 	#use player location as myArray offset
	lw $t6, myArray($t0) 		#Load that location nubmer into t6
		beq $t6, 35, GetNewPlayer	#if that loaction is a wall we get another location
		beq $t6, 36, GetNewPlayer
		beq $t6, 88, GetNewPlayer
Quit:		
	lw $ra, 0($sp)        #Restore the return address
	addiu $sp, $sp, 4     #Restore the return address
	jr $ra 

########################################################################
# Function Name: drawobj(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Draw the object's character
# at that point on the board.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object in question
# $t6, $t5, $s0 general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Determine the character for this type of object
# 3. Place that character in the board at the object's location.
#
########################################################################	        
drawobj:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		addi $t9, $t9, 12     	#Check object tpye
	lw $t6, PlayerObjects($t9) 	#Load player type into t6
	beq $t6, 1, Player
	beq $t6, 2, Robot
	bne $t6, 2, Nothing	
	jr $ra
Player:
		addi $t9, $t9, -12      #Back to player location 
		#move $t0, $t5		
	addiu $s0, $zero, 88      	# number 88 will be my player icon
	sw $s0, myArray($t5)		
	jr $ra
Robot:
		addi $t9, $t9, -12
	addiu $s0, $zero, 36      	# number 36 will be Robot icon
	sw $s0, myArray($t5)
Nothing:			
	jr $ra		 	

########################################################################
# Function Name: eraseobj(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Find the location of
# that object on the board, then store floor ('.') at that spot.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object in question
# $t5, $s0 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Store a '.' at that point of the board
#
########################################################################
eraseobj:		
	lw $t5, PlayerObjects($t9) 	#Load object location into t5
	addiu $s0, $zero, 46      	#Cheange that location to .
	sw $s0, myArray($t5)		
	jr $ra 	

########################################################################
# Function Name: char whatthere(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Find the location of
# that object on the board, then return the character at that location
# on the map.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object in question
# $t0, $t1 -- general calculations.
# $v0 -- return value
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Fetch the value at that point of the board.
#
########################################################################
whatthere:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
	lw $t6, myArray($t5)		#Load that location value to make sure it is not wall
		beq $t6, 35, Exit	#If it is wall player die
		beq $t6, 64, Exit	#If it is wall player die
		beq $t6, 36, Exit2
	jr $ra

########################################################################
# Function Name: moveN(idx)
########################################################################
# Functional Description:
# This routine moves one object north on the board (up the page).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object to move
# $t5, $t6 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Decrement the Y value
# 3. Decrement the pointer by the line length
#
########################################################################
moveN:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		addi $t5, $t5 -156 	#Decrenebt the pointer by the line length
	sw $t5, PlayerObjects($t9) 	#Save new player location value
		addi $t9, $t9, 8	#Set index to 8
	lw $t6, PlayerObjects($t9) 	#Load player Y value into t6	
		addi $t6, $t6 -1 
	sw $t6, PlayerObjects($t9) 	#Save new player location value
	jr $ra
	
########################################################################
# Function Name: moves(idx)
########################################################################
# Functional Description:
# This routine moves one object south on the board (down the page).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object to move
# $t5, $t6 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Increment the Y value
# 3. Increment the pointer by the line length
#
########################################################################
moveS:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		addi $t5, $t5 156 	#Decrenebt the pointer by the line length
	sw $t5, PlayerObjects($t9) 	#Save new player location value
		addi $t9, $t9, 8	#Set index to 8
	lw $t6, PlayerObjects($t9) 	#Load player Y value into t6	
		addi $t6, $t6 1 
	sw $t6, PlayerObjects($t9) 	#Save new player location value
	jr $ra
	
########################################################################
# Function Name: movew(idx)
########################################################################
# Functional Description:
# This routine moves one object west on the board (to the left).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object to move
# $t5, $t6 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Decrement the X value
# 3. Decrement the pointer
#
########################################################################
moveW:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		addi $t5, $t5 -4 	#Decrenebt the pointer value
	sw $t5, PlayerObjects($t9) 	#Save new player location value
		addi $t9, $t9, 4	#Set index to 4
	lw $t6, PlayerObjects($t9) 	#Load player X value into t6	
		addi $t6, $t6 -1 
	sw $t6, PlayerObjects($t9) 	#Save new player location value
	jr $ra
	
########################################################################
# Function Name: movee(idx)
########################################################################
# Functional Description:
# This routine moves one object east on the board (to the right).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object to move
# $t5, $t6 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Increment the X value
# 3. Increment the pointer
#
########################################################################
moveE:
	lw $t5, PlayerObjects($t9) 	#Load player location into t5
		addi $t5, $t5 4 	#Decrenebt the pointer value
	sw $t5, PlayerObjects($t9) 	#Save new player location value
		addi $t9, $t9, 4	#Set index to 8
	lw $t6, PlayerObjects($t9) 	#Load player X value into t6	
		addi $t6, $t6 1 
	sw $t6, PlayerObjects($t9) 	#Save new player location value
	jr $ra
	
########################################################################
# Function Name: movej(idx)
########################################################################
# Functional Description:
# This routine moves one object to a random spot on the board.
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# We save the $ra and $s0 registers on the stack
# $t9 -- Index of object to move
# $t5, $t6, $s1, $s2 -- general calculations.
# $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save $ra and $s0 on the stack
# 2. Set $t9 to be the pointer to the object
# 3. Get new random X and Y coordinates for the object
# 4. Compute the object's new board pointer
# 5. Check is the location is safe. If not get another location
# 6. Restore $ra and $s0
#
########################################################################
moveJ:
	addiu $sp, $sp, -4 #Save the return address on the stack
	sw $ra, 0($sp)	   #Save the return address on the stack
GetNewPlayer2:
		move $t9, $zero	
	sw $s1, PlayerObjects($t9)       #We will save a zero to index 0 first 
	jal randX  			 #Get a int from randX for this object (3)
	move $s1, $v0  			 #Move v0 to S1 (X into s1)(3)
		addi $t9, $t9, 4
	sw $s1, PlayerObjects($t9)       #Store X Value
	
	jal randY 	#(4)Get a int from randX for this object (3)
	move $s1, $v0   #Move v0 to S1 (X into s1)
		addi $t9, $t9, 4
	sw $s1, PlayerObjects($t9)      #Store Y Valye (3)
		addi $t9, $t9, 4
		addi $s2  $zero, 1 #Save 1 for player type (3)	
	sw $s2, PlayerObjects($t9)      #Store player type (3)
	#We finish saving player X Y values
	#Calculate player location in array	
		addi $t9, $zero, 8  	#Now we will load Y value to calculate (3)	
	lw $t5, PlayerObjects($t9) 	#Load Y into t5	(3)
		addi $t9, $zero, 0
		addi $t9, $t9, 4
	lw $t6, PlayerObjects($t9) 	#Load X into t6	(3)																							
	lw $s1, linelen 		#Move linelen into s1 (3)
	mult $t5, $s1			#Multiply Y to linelen (3)
	mflo $t5        		#Result of Y * linelen (3)
		add $t5, $t5, $t6 	#Result of (Y * linelen + X) (3)
	#Row major
	lw $s1, byte			#Times 4 byte (3)	
	mult $t5, $s1			#Multiply Y to linelen (3)
	mflo $t5			#Final result (3)
	#Save this to index 0
		addi $t9, $zero, 0 	#Set index to 0
	sw $t5, PlayerObjects($t9)	#Now I save the player location to index 0
		
	#We need to see if that location is safe to add player there (5)
	lw $t5, PlayerObjects($t9) 	#Load player location into t5 (5)
		add $t9, $zero, $t5 	#use player location as myArray offset (5)
	lw $t6, myArray($t9) 		#Load that location nubmer into t6 (5)
		beq $t6, 35, GetNewPlayer2	#if that loaction is a wall we get another location (5)	
	lw $ra, 0($sp)        #Restore the return address (6)
	addiu $sp, $sp, 4     #Restore the return address (6)
	jr $ra 	

########################################################################
# Function Name: bool moveRobot(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object (a robot or rubble).
# This computes and moves the robot to take one step closer to the
# person. If the robot crashes, it becomes rubble. This routine returns
# 1 if the person was killed by a robot; 0 otherwise.
#
########################################################################
# Register Usage in the Function:
# $t9 -- Index of object in question
# $s0 -- saved index of object in question.
# $s1 -- pointer to the object's structure.
# $s2 -- pointer to the player's structure.
# $t0, $t1 -- general calculations.
# $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save registers on stack
# 2. Compute pointers to object's struct and player's struct
# 3. If object is a robot:
# 3a. See what is in map at robot's location. Normally it would be
# the robot symbol. But if another robot had crashed into
# this one, it would be rubble. If it is rubble, turn this
# robot object into a rubble object.
# 3b. Erase the robot from the map
# 3c. Move the robot one step vertically closer to player
# 3d. Move the robot one step horizontally closer to player
# 3e. See if there is a collision at this location
# 3f. Draw robot back into map
# 4. Restore registers
#
########################################################################
moveRobot:
	addiu $sp, $sp, -4 # Save the return address on the stack (1)
	sw $ra, 0($sp)	   # Save the return address on the stack (10
	
	lw $s1, PlayerObjects($t9)	# Store Object's pointer to $s0
	lw $s2, PlayerObjects($zero)	# Save player pointer to $s2
		

		addi $t0, $zero, 4	# move to player x value pointer	
		addi $t9, $t9, 4	# Move to robot x value pointer
	lw $t4, PlayerObjects($t0)	# Load player x value to $t4
	lw $s4, PlayerObjects($t9)	# load robot x value to $s4
	addi $t0, $t0, 4		# move to player y value pointer
		addi $t9, $t9, 4	# Move to robot y value pointer
	lw $t2, PlayerObjects($t0)	# Load player y value to $t4
	lw $s6, PlayerObjects($t9)	# load robot y value to $s4	

#***Check Type
	addi $t9, $t9, 4		#Move index to object's type (3)
	lw $s7, PlayerObjects($t9) 	#Save type to $s3 (3)
	bne $s7, 2, Return		#If it is rubble exit moveRobot (3)
		addi $t9, $t9, -12 	#set index back to pinter to erase (3)
	jal eraseobj 
		
		beq $t4, $s4, GoUpDown 		# if both robot and player have same x value go vertically  
		beq $t2, $s6, GoLeftRight	# if both robot and player have same y value go horizontally  
		
		 	
		subu $s7, $t4, $s4	# X value calculation (Player x value minus robot x value) unsigned	
		subu $s3, $t2, $s6	# Y value calculation (Player y value minus robot y value) unsigned	
		
		bgt $s7, $s3, GoUpDown		# if y value is closer to player go vertically 					
		bgt $s3, $s7, GoLeftRight	# if x value is closer to player go horizontally 	
		
GoUpDown:
	sub $s3, $t2, $s6	# Y value calculation (Player y value minus robot y value) signed
	blt $s3, $zero	goUp	# If the value is negative go up
	bgt $s3, $zero 	goDown	# If the value is postive go down

GoLeftRight:
	sub $s7, $t4, $s4	# X value calculation (Player x value minus robot x value) signed
	blt $s7, $zero	goLeft	# If the value is negative go left
	bgt $s7, $zero 	goRight	# If the value is postive go right		
		
goUp:	
		addi $s1, $s1 -156 	# Decrenebt the pointer by the line length
	jal CheckLoaction 		# Check location before robot move (3a)	
	jal moveN			# Move the robot one step vertically closer to player 
		addi $t9, $t9, -8	# Move pointer back 
	jal drawobj			# Erase the robot from the map (3b)
	j Return	
goDown:
		addi $s1, $s1 156 	#Decrenebt the pointer by the line length
	jal CheckLoaction 		#Check location before robot move (3a)	
	jal moveS			# Move the robot one step vertically closer to player 
		addi $t9, $t9, -8	# Move pointer back 
	jal drawobj			# Erase the robot from the map (3b)
	j Return
					
goLeft:
		addi $s1, $s1 -4 	# Decrenebt the pointer value
	jal CheckLoaction 		# Check location before robot move (3a)	
	jal moveW			# Move the robot one step horizontally closer to player
		addi $t9, $t9, -4	# Move pointer back 
	jal drawobj			# Erase the robot from the map (3b)
	j Return
goRight:
		addi $s1, $s1 4 	#Decrenebt the pointer value
	jal CheckLoaction 		#Check location before robot move (3a)		 
	jal moveE			# Move the robot one step horizontally closer to player
		addi $t9, $t9, -4	# Move pointer back 
	jal drawobj			# Erase the robot from the map (3b)
	j Return								
					
CheckLoaction:
	addiu $sp, $sp, -4 #Save the return address on the stack (3a)
	sw $ra, 0($sp)	   #Save the return address on the stack (3a)

	lw $t6, myArray($s1)		#Load that location value to make sure it is not wall (3a)
		beq $t6, 35, RobotDie	#If it is wall robot die (3a)
		beq $t6, 36, RobotDie	#If it is a robot,then robot die (3a)
		beq $t6, 64, RobotDie	#If it is a rubble,then robot die (3a)
		beq $t6, 88, PlayerDie	#Robot killed player
	lw $ra, 0($sp)	   #Restore the return address	
	addiu $sp, $sp, 4  #Restore the return address
	jr $ra 		   #Return
RobotDie:
		addi $s5, $s5, -1	#Robot counter
		beqz $s5, Win		#If all robot die player win
	lw $t5, PlayerObjects($t9) 		# Load player location into t5
		addiu $s0, $zero, 64      	# 64 Will Be  Rubble
		addi $t4, $zero, 3		# Change robot type to 3
		addi $t9, $t9, 12		# Move pointer to type
	sw $t4, PlayerObjects($t9)		# Change robot to rubble
	sw $s0, myArray($t5)			# Change robot icon
	addi $t9, $t9, -12			# Move index back
	add $v0, $zero, 0 # return 0	 
Return:		
	lw $ra, 0($sp)	   #Restore the return address	
	addiu $sp, $sp, 4  #Restore the return address
	jr $ra 		   #Return	
	
PlayerDie:
	add $v0, $zero, 1 # return 1
	j Return					
									
########################################################################
# Function Name: int randX
########################################################################
# Functional Description:
# This routine gets a random number for the X coordinate, so the value
# will be between 1 and wid - 1.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls rand, we save $ra on the stack, then restore it.
# $a0 -- the value wid - 2 passed to rand
# $v0 -- the return value from rand
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address on the stack
# 2. Get the value wid - 2
# 3. Pass this to rand, so we get a number between 0 and wid - 2
# 4. Add 1 to the result, so the number is between 1 and wid - 1
# 5. Restore the return address
#
########################################################################
randX:
	addiu $sp, $sp, -4 #Save the return address on the stack (1)
	sw $ra, 0($sp)	   #Save the return address on the stack (1)
	lw $a0, wid  	   # Get wid (2)
	addi $a0, $a0, -2  # 2. Get the value wid - 2 (2)_
	jal rand	   # Jump to rand (3)
	addi $v0, $v0, 1   # Add 1 to the result, so the number is between 1 and wid - 1 (4)
	lw $ra, 0($sp)	   #Restore the return address	(5)
	addiu $sp, $sp, 4  #Restore the return address  (5)
	jr $ra 		   #Return (5)

########################################################################
# Function Name: int randY
########################################################################
# Functional Description:
# This routine gets a random number for the Y coordinate, so the value
# will be between 1 and hgt - 1.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls rand, we save $ra on the stack, then restore it.
# $a0 -- the value hgt - 2 passed to rand
# $v0 -- the return value from rand
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address on the stack
# 2. Get the value hgt - 2
# 3. Pass this to rand, so we get a number between 0 and hgt - 2
# 4. Add 1 to the result, so the number is between 1 and hgt - 1
# 5. Restore the return address
#
########################################################################
randY:
	addiu $sp, $sp, -4 #Save the return address on the stack (1)
	sw $ra, 0($sp)	   #Save the return address on the stack (1)	
	lw $a0, hgt  	   # Get hgt (2)
	addi $a0, $a0, -2  # 2. Get the value hgt - 2 (2)
	jal rand	   # Jump to rand (3)
	addi $v0, $v0, 1   # Add 1 to the result, so the number is between 1 and wid - 1 (4)
	lw $ra, 0($sp)     #Restore the return address (5)
	addiu $sp, $sp, 4  #Restore the return address (5)
	jr $ra             #Return
	 

########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
# This routine generates a pseudorandom number using the xorsum
# algorithm. It depends on a non-zero value being in the 'seed'
# location, which can be set by a prior call to seedrand. For this
# version, pass in a number N in $a0. The return value will be a
# number between 0 and N-1.
#
########################################################################
# Register Usage in the Function:
# $t0 -- a temporary register used in the calculations
# $v0 -- the register used to hold the return value
# $a0 -- the input value, N
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Fetch the current seed value into $v0
# 2. Perform these calculations:
# $v0 ^= $v0 << 13
# $v0 ^= $v0 >> 17
# $v0 ^= $v0 << 5
# 3. Save the resulting value back into the seed.
# 4. Mask the number, then get the modulus (remainder) dividing by $a0.
#
########################################################################
	.data
	seed: .word 31415 # An initial value, in case seedrand wasn't called
	.text
rand:
	lw $v0, seed 		# Fetch the seed value
	sll $t0, $v0, 13 	# Compute $v0 ^= $v0 << 13
	xor $v0, $v0, $t0
	srl $t0, $v0, 17	# Compute $v0 ^= $v0 >> 17
	xor $v0, $v0, $t0
	sll $t0, $v0, 5 	# Compute $v0 ^= $v0 << 5
	xor $v0, $v0, $t0
	sw  $v0, seed	        # Save result as next seed
	andi $v0, $v0, 0xFFFF	# Mask the number (so we know its positive)
	div $v0, $a0	        # divide by N. The reminder will be 
	mfhi $v0 	        # in the special register, HI. Move to $v0.
	jr $ra 	                # Return the number in $v0

########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
# This routine sets the seed for the random number generator. The
# seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
# $a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
	sw $a0, seed
	jr $ra
