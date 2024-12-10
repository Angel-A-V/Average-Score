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
	addi $sp, $sp -4				# Create a stack pointer with a reserve of 4
	sw $ra, 0($sp)					# store the return address at the top of the stack
	li $v0, 4 						# load immediate 4 into $v0 which triggers a system call in MIPS whcih prints a string
	la $a0, str0 					# Load the address of the string into $a0
	syscall 						# Print the string (ststem call) it is trigged Since we set $v0 = 4
	li $v0, 5						# Read the number of scores from user
	syscall							# Perform the system Call (read integer)
	move $s0, $v0					# $s0 = numScores
	move $t0, $0					# Initialize index to 0
	la $s1, orig					# $s1 = orig   Lodaing the address of the original array into $s1
	la $s2, sorted					# $s2 = sorted Loading the address of the sorted array into $s2

loop_in:
	li $v0, 4 					
	la $a0, str1 					# Printing the str1 which ask the user to enter there score 
	syscall 
	sll $t1, $t0, 2					# Multiply the index $t0 by 4 which shifts it left by 2, we do this because in MIPS, each integer is 4 bytes, so to access the correct memory loaction in an array we do this
	add $t1, $t1, $s1				# Add the base address of the of original to get the correct position
	li $v0, 5						# Read elements from user
	syscall

	sw $v0, 0($t1)					# Store the score in the original array at the position determined by $t1
	addi $t0, $t0, 1				# Increament the index counter $t0
	bne $t0, $s0, loop_in			# If $t0 is not equal to $s0 (numScores) loop again
	
	move $a0, $s0					# Move the number of scores $s0 into an argument register $a0
	jal selSort						# Call selSort to perform selection sort in original array
	
	li $v0, 4 						# Print the str2
	la $a0, str2 
	syscall
	move $a0, $s1					# More efficient than la $a0, orig:  Move the address of the orig array to $a0
	move $a1, $s0					# Move the number of scores to $a1 (size of the array)
	jal printArray					# Print original scores
	li $v0, 4 					
	la $a0, str3 					# Print str3
	syscall 
	move $a0, $s2					# More efficient than la $a0, sorted: Move the address of the sorted array to $a0
	jal printArray					# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5						# Read the number of (lowest) scores to drop
	syscall

	move $a1, $v0
	sub $a1, $s0, $a1				# numScores - drop: Calculate the number of scores remaining after dropping
	move $a0, $s2					# Move the address of the sorted array to $a0
	jal calcSum						# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped

	# Your code here to compute average and print it
    move $t0, $v0                  # Store sum in $t0 (v0 contains sum)
    div $t0, $a1                   # Divide sum by remaining scores
    mflo $t0                       # Store quotient in $t0 (average)
    
    li $v0, 4                      # Print average message
    la $a0, str5
    syscall

    li $v0, 1                      # Print the average
    move $a0, $t0
    syscall

    lw $ra, 0($sp)                 # Restore return address
    addi $sp, $sp, 4               # Restore stack pointer
    li $v0, 10                     # Exit syscall
    syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here

	# $a0 is the array
	# $a1 is the length

	move $t0, $0					# Intialize the index
	move $t1, $a0					# Copy the array address to $t1

print_array:
	sll $t2, $t0, 2					# Get the byte offset
	add $t2, $t2, $t1				# Add the byte offset to the base address of the array
	lw $a0, 0($t2)					# Load the value from the calculated memory address into $a0

	li $v0, 1						# Print the integer
	syscall

	li $v0, 11						# Print the space after the value
	la $a0, 32						# ASCII for space
	syscall
	
	addi $t0, $t0, 1				# Increament the index
	bne $t0, $a1, print_array		# If the index is not euqual to the array size, continue the loop

	li $v0, 11						# Print a newline
	la $a0, 10						# ASCII for newline
	syscall

	jr $ra
	
	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here

	move $t0, $0					# Intialize the index i = 0

copy_array:
	sll $t1, $t0, 2					# Get the byte offset for orig
	add $t1, $t1, $s1				# Add the byte offset to the base address of orig to get the memory address
	lw $v0, 0($t1)					# Load the value from orig[i] into $v0

	sll $t2, $t0, 2					# Get the byte offset for sorted 
	add $t2, $t2, $s2				# Add the byte offset to the base address of sorted to get the memory address
	sw $v0, 0($t2)					# Store the value into sorted[i]

	addi $t0, $t0, 1				# Increament index i += 1
	bne $t0, $a0, copy_array		# If our i != the len, continue copying

	move $t0, $0
	beq $a0, 1, end_func			# If the array is 1, no sorting is needed
	
selection_sort1:
	add $t2, $t0, $zero				# Set largest = i ( So we can start with i as the largest)
	addi $t1, $t0, 1

selection_sort2:
	sll $t3, $t1, 2					# Get offset for sorted[j]
	add $t3, $t3, $s2 				# Add the byte offset to the base address of sorted to get the memory address
	lw $t4, 0($t3)					# Load sorted[j] into $t4

	sll $t5, $t2, 2					# Get offset for sorted 
	add $t5, $t5, $s2				# Add the byte offset to the base address of sorted to get the memory address
	lw $t6, 0($t5)					# Loard sorted[largest value] into $t6

	blt $t4, $t6, selection_sort3	# If sorted[j] < sorted[largest], continue loop

	move $t2, $t1 					# Update the largest = j if sorted[j] is greater

selection_sort3:
	addi $t1, $t1, 1				# Increment inner loop index (j)
	bne $t1, $a0, selection_sort2	# Continue inner loop until j < len

	# Swap sorted[i] and sorted[largest]
	sll $t5, $t2, 2					# Get offset for sorted[largest]
	add $t5, $t5, $s2               # Add the byte offset to the base address of sorted to get the memory address
	lw $t6, 0($t5)					# Load sorted[largest] into $t6

	sll $t3, $t0, 2					# Calculate the byte offset for sorted[i]					
	add $t3, $t3, $s2				# Add the byte offset to the base address of sorted to get the memory address of sorted[i]
	lw $t4, 0($t3)					# Load the value of the sorted[largest] into $t4

	# Store the value of sorted[i] into sorted[largest]
	sll $t5, $t2, 2,				# Calculate the byte offset for sorted[i]
	add $t5, $t5, $s2				# Add the byte offset to the base address of sorted to get the memory address of sorted[i]
	sw $t4, 0($t5)					# Store the value of sorted[i] into sorted[largest]

	# Store the value of sorted[largest] into sorted[i]
	sll $t3, $t0, 2					# Calculate the byte offset for sorted[i]
	add $t3, $t3, $s2				# Add the byte offset to the base address of sorted to get the memory address of sorted[i]
	sw $t6, 0($t3)					# Store the value of sorted[largest] into sorted[i]

	addi $t0, $t0, 1				# Increament the index
	addi $t7, $a0, -1				# Calculate len - 1 (last valid index for sorting)
	bne $t0, $t7, selection_sort1	# If i != len - 1, repeat the loop

end_func:
	jr $ra

# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
    move $t0, $a2                   # Number of lowest scores to drop
    move $t1, $a0                   # Array base address
    move $t2, $a1                   # Array size
    move $t3, $0                    # Initialize sum to 0
    move $s0, $0                    # Initialize index to 0

calcSum_loop:
    beq $s0, $t2, calcSum_fin      # Base case: if index == len, return sum

    blt $s0, $t0, calcSum_skip      # If index < lowest scores to drop, skip this element

    sll $t4, $s0, 2                 # Calculate byte offset for array[index]
    add $t4, $t4, $t1               # Add to array base address
    lw $t5, 0($t4)                  # Load array element into $t5
    add $t3, $t3, $t5               # Add element to sum

calcSum_skip:
    addi $s0, $s0, 1                # Increment index
    j calcSum_loop                  # Continue loop

calcSum_fin:
    move $v0, $t3                   # Return sum in $v0
    jr $ra       
	
