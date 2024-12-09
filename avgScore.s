.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4			# Create a stack pointer with a reserve of 4
	sw $ra, 0($sp)				# store the return address at the top of the stack
	li $v0, 4 					# load immediate 4 into $v0 which triggers a system call in MIPS whcih prints a string
	la $a0, str0 				# Load the address of the string into $a0
	syscall 					# Print the string (ststem call) it is trigged Since we set $v0 = 4
	li $v0, 5					# Read the number of scores from user
	syscall						# Perform the system Call (read integer)
	move $s0, $v0				# $s0 = numScores
	move $t0, $0				# Initialize index to 0
	la $s1, orig				# $s1 = orig   Lodaing the address of the original array into $s1
	la $s2, sorted				# $s2 = sorted Loading the address of the sorted array into $s2

loop_in:
	li $v0, 4 					
	la $a0, str1 				# Printing the str1 which ask the user to enter there score 
	syscall 
	sll $t1, $t0, 2				# Multiply the index $t0 by 4 which shifts it left by 2, we do this because in MIPS, each integer is 4 bytes, so to access the correct memory loaction in an array we do this
	add $t1, $t1, $s1			# Add the base address of the of original to get the correct position
	li $v0, 5					# Read elements from user
	syscall

	sw $v0, 0($t1)				# Store the score in the original array at the position determined by $t1
	addi $t0, $t0, 1			# Increament the index counter $t0
	bne $t0, $s0, loop_in		# If $t0 is not equal to $s0 (numScores) loop again
	
	move $a0, $s0				# Move the number of scores $s0 into an argument register $a0
	jal selSort					# Call selSort to perform selection sort in original array
	
	li $v0, 4 					# Print the str2
	la $a0, str2 
	syscall
	move $a0, $s1				# More efficient than la $a0, orig:  Move the address of the orig array to $a0
	move $a1, $s0				# Move the number of scores to $a1 (size of the array)
	jal printArray				# Print original scores
	li $v0, 4 					
	la $a0, str3 				# Print str3
	syscall 
	move $a0, $s2				# More efficient than la $a0, sorted: Move the address of the sorted array to $a0
	jal printArray				# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5					# Read the number of (lowest) scores to drop
	syscall

	move $a1, $v0
	sub $a1, $s0, $a1			# numScores - drop: Calculate the number of scores remaining after dropping
	move $a0, $s2				# Move the address of the sorted array to $a0
	jal calcSum					# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped

	# Your code here to compute average and print it
						
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here

	# $a0 is the array
	# $a1 is the length

	move $t0, $0				# Intialize the index
	move $t1, $a0				# Copy the array address to $t1

print_array:
	sll $t2, $t0, 2				# Get the byte offset
	add $t2, $t2, $t1			# Add the byte offset to the base address of the array
	lw $a0, 0($t2)				# Load the value from the calculated memory address into $a0

	li $v0, 1					# Print the integer
	syscall

	li $v0, 4					# Print the space after the value
	la $a0, space
	syscall
	
	addi $t0, $t0, 1			# Increament the index
	bne $t0, $a1, print_array	# If the index is not euqual to the array size, continue the loop

	li $v0, 4					# Print a newline
	la $a0, nextLine
	syscall

	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here

	move $t0, $0				# Intialize the index i = 0

copy_array:
	sll $t1, $t0, 2				# Get the byte offset for orig
	add $t1, $t1, $s1			# Add the byte offset to the base address of orig to get the memory address
	lw $v0, 0($t1)				# Load the value from orig[i] into $v0

	sll $t2, $t0, 2				# Get the byte offset for sorted 
	add $t2, $t2, $s2			# Add the byte offset to the base address of sorted to get the memory address
	sw $v0, 0($t2)				# Store the value into sorted[i]

	addi $t0, $t0, 1			# Increament index i += 1
	bne $t0, $a0, copy_array	# If our i != the len, continue copying 
	
	jr $ra
	
selection_sort1:
	

# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	
	jr $ra
	
