# Program demonstrates implementation of common sort algorithms 


.data # data derc allocate our memory on the static poriton of DRAM 
array:		.word 1,4,6,8,9,2 
arraySize:	.word 6 	
fwdBrace: 	.asciiz	"["
bckBrace:		.asciiz	"]"
selMess:		.asciiz	"\nCalling SelectionSort\n"
insMess:		.asciiz	"\nCalling InsertSort\n"
bubMess:		.asciiz	"\nCalling BubbleSort\n"
Prompt:		.asciiz	"\nSelect an option\n1)Print Array\n2)Insert Sort\n3)Bubble Sort\n4)Selection Sort\n5)Terminate\n"
error:		.asciiz	"\nInvalid input input an integer between 1 - 5 \n"
printMess:	.asciiz	"\nPrint Array\n"
switchAddress:		.word	default,case1,case2,case3,case4,case5	#size of an address is word size
endMess:		.asciiz "\nTerminate Program\n"
.text # Define our instructions on the text segement of memory 

# printf macro takes in a parameter of an address of type string 
.macro printf(%x)
addi	$sp,$sp,-8 #allocate stack
sw	$a0,0($sp)
sw	$v0,4($sp)
la	$a0,%x
li	$v0,4 #print string 
syscall 
lw	$a0,0($sp)
lw	$v0,4($sp)
addi	$sp,$sp,8	#deallocate stack
.end_macro


.globl main # main can be used in any file 
main: 

# get addres of the array and put it in out argument 

switch:
	printf(Prompt) 
	la	$a0,switchAddress
	jal	getAddress 
	# Get array 
	la	$a0,array # get first byte address form array 
	lw 	$a1,arraySize# gets the array size of the array
	# return address and jump to it
	jr	$v0 # unconditional jump 28  bit distance 
	
case1: 	# prints our array 
	printf(printMess)	#print array
	jal	printArray #jump and link to printArray function 
	j switch 
case2:	# InsertSort
	printf(insMess) 
	jal	insertionSort
	j switch
case3: 	#bubbleSort
	printf(bubMess)
	jal	bubbleSort
	j switch
case4:	#selectionSort
	printf(selMess)
	jal	selectionSort
	j	switch
case5: 	# terminate program 
	printf(endMess) 
	j end
default: 
	# print error return to switch
printf(error)
j	switch 

end: 
# Terminate program
li $v0,10
syscall

# Recieve array address, and return address to be derefenced
.globl	getAddress
getAddress: 
addi	$sp,$sp,-4 #allocate on the stack copy the address 
sw	$a0,0($sp) # store address on stack
# get the number
li	$v0,5 #get user input return to $v0
syscall
move	$t0,$v0

# check if valid 
blez $t0,noCal   # if( t0 <= 0) goto noCal
bgt  $t0,5,noCal # if(to > 4) goto noCal

sll  $t0,$t0,2   # input is word addressable 
add  $t1,$t0,$a0 # calculate the address
lw   $v0,0($t1)  # derfence now get the address 
j yesCal	# jump to return 
noCal: 
lw   $v0,0($a0)  # get default address 
yesCal:
lw	$a0,0($sp) # restore the address 
addi	$sp,$sp,4 #deallocate the stack
jr	$ra #return to calling function

# Pass address of array to $a0 and size to $a1 to the callee function 
.globl insertionSort 
insertionSort: 
# allocate the stack
addi	$sp,$sp,-8 
sw	$a0,0($sp)
sw	$a1,4($sp)
move	$t0,$a0 	# get a copy of the beg address   
sll	$t1,$a1,2 # make size word addressable 
add	$t1,$a0,$t1 # get end address of the array 
addi	$a0,$a0,4 # &A[i+1]
outterInSortLoop:

move	$t2,$a0	#position
innerInSortLoop: 
## while (address > begAddress && A[p] < Arr[p-1])

# Compound condition 
bge	$t0,$t2,noLoop 
lw	$t3,0($t2) # A[p]
lw	$t4,-4($t2) # A[p - 1]
bge	$t3,$t4,noLoop 

# Other wise loop and swap
sw	$t3,-4($t2) # A[p-1] = A[p]
sw	$t4,0($t2) # A[p] = A[p-1]
# dec and loop
addi	$t2,$t2,-4     # dec poistion by 1 word 
j	innerInSortLoop # unconditional jump to loop
noLoop: 
# inc outter pointer
addi	$a0,$a0,4 

bgt $t1,$a0,outterInSortLoop

# deallocate the stack 
lw	$a0,0($sp)
lw	$a1,4($sp)
addi	$sp,$sp,8
jr $ra	# return to calling function

# Pass address of arrray tp $a0 and size tpo $a1 to the callee functin 
.globl selectionSort
selectionSort: 
# two arguments push onto the stack 
addi	$sp,$sp,-8 
sw	$a0,0($sp) # put address on stack
sw	$a1,4($sp) # put size on stack 

move	$t0,$a0	 # Store copy of address on register
# $to used inner loop
sll	$t1,$a1,2  # make size word addressable
add	$t1,$a0,$t1# get array end address 

# get min value 

# Outter loop, selection first index value and is poistion to swap  
secOutterLoop: 
lw	$t2,0($a0) # int min = A[0]
move	$t3,$a0	 # get position  of &A[i] 

# inner loop, looks for smallest value 
move	$t0,$a0 
secInnerLoop: 
lw	$t4,0($a0) # get A[i]
lw	$t5,0($t0) # get A[j]
bgt	$t5,$t4,noSwap
move	$t2,$t5 # get min data
move	$t3,$t0 # get position to swap with

noSwap: 

# inc by 4 bytes
addi	$t0,$t0,4
bgt	$t1,$t0,secInnerLoop
#Exit inner loop 

# Now swap data 
lw	$t6,0($a0) # A[i]
sw	$t6,0($t3) # A[index] = A[i]
sw	$t2,0($a0) # A[i] = min

# inc by 4 byte outterloop pointer
addi	$a0,$a0,4
bgt	$t1,$a0,secOutterLoop

# Exit outterloop
# Restore agruements
lw	$a0,0($sp) # get address back
lw	$a1,4($sp) # get size back
addi	$sp,$sp,8	 # deallocate the stack

# return to calling functin 
jr	$ra 


# Pass address of array to $a0 and size to $a1 to the callee function
.globl bubbleSort 
bubbleSort: 
# Allocate arguments to the stack
addi	$sp,$sp,-8 
sw	$a0,0($sp) # address on stack
sw	$a1,4($sp) # size on stack 

addi	$a1,$a1,-1
move	$t1,$a0	# copy of beg address
move	$t0,$a1 	# get size
sll	$t0,$a1,2 # make word addressable
add	$t0,$a0,$t0 # get ending address 
# Outter loop holds poistion to store our element
outterLoop: 

# Inner loop will swap data to end of array 
innerLoop:  
# get derefenced data 
lw	$t3,0($a0) #A[i]
lw	$t4,4($a0) #A[i + 1]
#Branch check if (n) > (n + 1)
ble $t3,$t4, noSwapSec
# true swap A[i] and A[i+1]
sw	$t3,4($a0) #A[i+1] = A[i]
sw	$t4,0($a0) #A[i] = A[i+1]
noSwapSec: 

# inc pointer
addi	$a0,$a0,4 # inc by 4 bytes 
bgt	$t0,$a0,innerLoop 
move	$a0,$t1	#get the address
# end of inner loop 

# decrement ending address by word size
addi	$t0,$t0,-4
bge	$t0,$a0,outterLoop #if(t0 > a0) goto outterloop 
# end of outter loop

# Restore arguements
lw	$a0,0($sp) # get address back
lw	$a1,4($sp) # get size back
addi	$sp,$sp,8  # deallocate the stack

jr $ra # jump back to the calling function


# Pint array declaration
.globl printArray
# Pass address of array to $a0 and size to $a1 to the callee function  
printArray: 
# 2 arguments of type word allocate on stack 
addi	$sp,$sp,-8 # store 3 words of data
sw	$a0,0($sp) # store a copy of the address on stack
sw	$a1,4($sp) # store a copy of the size of array

# get end address
sll $t0,$a1,2 	# word addressable (size * 4)
add $t1,$t0,$a0 	# get ending address  (&a + 6) = endOfAddress  

# do while 
loop: 

#print element 
move	$t2,$a0 #get address move to temp
#print string
li	$v0,4
la	$a0,fwdBrace
syscall

#print integers 
li	$v0,1 #print word data 
lw	$a0,0($t2) #get 4 bytes of from address stored in $t2 
syscall

#print string
li	$v0,4
la	$a0,bckBrace
syscall 

# restore address
move	$a0,$t2  

# end of print # 
 
# pointer addressing move 1 word at a time
addi	$a0,$a0,4
bgt 	$t1,$a0,loop #if(t1 > $a0) goto loop

# restore stack, and deallocate the stack
lw	$a0,0($sp) #restore original address
lw	$a1,4($sp) # restore size
addi	$sp,$sp,8  # deallocate the stack 

jr	$ra # jump back to calling function 
