# Program demonstrates implementation of sort algorithm


.data # data derc allocate our memory on the static poriton of DRAM 
array:		.word 1,4,6,8,9,2 
arraySize:	.word 6 	
fwdBrace: 	.asciiz	"["
bckBrace:		.asciiz	"]"
strMess:		.asciiz	"\nCalling Sort function\n"

.text # Define our instructions on the text segement of memory 
.globl main # main can be used in any file 
main: 


# get addres of the array and put it in out argument 
la	$a0,array # get first byte address form array 
lw 	$a1,arraySize# gets the array size of the array

# print array 
jal	printArray 

# Print String
move	$t2,$a0
li	$v0,4
la	$a0,strMess
syscall
move	$a0,$t2 
# Sort array with bubble sort
jal	bubbleSort
# print Array
jal	printArray	

# Terminate program
li $v0,10
syscall

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
ble $t3,$t4, noSwap
# true swap A[i] and A[i+1]
sw	$t3,4($a0) #A[i+1] = A[i]
sw	$t4,0($a0) #A[i] = A[i+1]
noSwap: 

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
