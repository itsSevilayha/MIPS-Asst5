#  CS 218, MIPS Assignment #5
#  Provided template


#####################################################################
#  data segment

.data

# -----
#  Constants

TRUE = 1
FALSE = 0
STEP_MAX = 45

# -----
#  Variables for main

hdr:		.ascii	"\n**********************************************\n"
		.ascii	"\nMIPS Assignment #5\n"
		.asciiz	"Count Ways Program\n"

endMsg:		.ascii	"\nYou have reached recursive nirvana.\n"
		.asciiz	"Program Terminated.\n"

stairCount:	.word	0
waysCount:	.word	0


# -----
#  Local variables for prtResults() function.

cntMsg1:	.asciiz	"\nFor a stairway with "
cntMsg2:	.asciiz	" steps, there are "
cntMsg3:	.asciiz	" ways to climb the stairway.\n"


# -----
#  Local variables for readSteps() function.

cntPmt:		.asciiz	"  Enter Stair Count (1-45): "

err1:		.ascii	"\nError, stair count out of range. \n"
		.asciiz	"Please re-enter data.\n"

spc:		.asciiz	"   "


# -----
#  Local variables for prtNewline function.

newLine:	.asciiz	"\n"


# -----
#  Local variables for countWays function.



# -----
#  Local variables for continue.

qPmt:		.asciiz	"\nTry another stair count (y/n)? "
ansErr:		.asciiz	"Error, must answer with (y/n)."

ans:		.space	3

#####################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Function to read and return step count (1-STEP_MAX).

doAnother:

	jal	readSteps
	sw	$v0, stairCount

# -----
#  call countWays to determine possible ways to climb stairway.
#	HLL Call:  waysCount = countWays(stairCount)

	lw	$a0, stairCount
	jal	countWays

	lw	$t0, stairCount
	ble 	$t0, 10, dontDisturb		# special cases
	subu	$t0, $t0, 1
	subu	$v0, $v0, $t0

dontDisturb:
	sw	$v0, waysCount

# ----
#  Display results (formatted).

	lw	$a0, stairCount
	lw	$a1, waysCount
	jal	prtResult

# -----
#  See if user wants to do another.

	jal	continue
	beq	$v0, TRUE, doAnother

	li	$v0, 4
	la	$a0, endMsg
	syscall

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall					# all done...
.end main

# =================================================================
#  Very simple function to print a new line.
#	Note, this routine is optional.

.globl	prtNewline
.ent	prtNewline
prtNewline:
	subu	$sp, $sp, 4
	sw		$ra, ($sp)

	la 	$a0, newLine
	li 	$v0, 4
	syscall

	lw		$ra, ($sp)
	addu	$sp, $sp, 4
	jr	$ra

.end	prtNewline

# =================================================================
#  Function to print final result (formatted).
#	Refer to assignment for example output.

# -----
#  Arguments
#	$a0 - stair count
#	$a1 - ways to climb stairs

.globl	prtResult
.ent	prtResult
prtResult:
	subu	$sp, $sp, 4
	sw 	$ra, ($sp)

	la 	$a0, newLine
	li 	$v0, 4
	syscall

	la 	$a0, cntMsg1
	li 	$v0, 4
	syscall

	lw 	$a0, stairCount
	li 	$v0, 1
	syscall

	la 	$a0, cntMsg2
	li 	$v0, 4
	syscall

	lw 	$a0, waysCount
	li 	$v0, 1
	syscall

	la 	$a0, cntMsg3
	li 	$v0, 4
	syscall

	lw	$ra, ($sp)
	addu	$sp, $sp, 4
	jr	$ra

.end	prtResult

# =================================================================
#  Prompt for and read number of steps.
#	Ensure that count is between 1 and STEP_MAX.

# -----
#    Arguments:
#	n/a
#    Returns:
#	$v0 - n value

.globl	readSteps
.ent	readSteps
readSteps:
	subu	$sp, $sp, 8
	sw	$ra, ($sp)
	sw	$s0, 4($sp)

	la	$a0, cntPmt
	li	$v0, 4
	syscall

checkSteps:
	li	$v0, 5
	syscall
	move	$s0, $v0

	blt	$s0, 1, printError
	bgt	$s0, STEP_MAX, printError
	j	Done

printError:
	la  	$a0, err1
	li	$v0, 4
	syscall

	la  	$a0, spc
	li	$v0, 4
	syscall

	la  	$a0, cntPmt
	li	$v0, 4
	syscall

	j checkSteps

Done:
	move	$v0, $s0			# save value of stairs into v0

	lw	$ra, ($sp)
	lw	$s0, 4($sp)
	addu	$sp, $sp, 8
	jr	$ra

.end	readSteps

#####################################################################
#  function to recursivly determine how many ways
#  a staircase can be climbed using a combination of
#  short strides (one step) and/or long strides (two steps).

# -----
#  Arguments:
#	$a0 - stair count
#  Returns:
#	$v0 - ways count

.globl	countWays
.ent	countWays
countWays:
	subu	$sp, $sp, 8
	sw 	$ra, ($sp)
	sw 	$s0, 4($sp)
				
	ble 	$a0, 1, countDone		

	move	$s0, $a0				# countWays(n-1)
	sub 	$a0, $a0, 1
	jal		countWays

	move 	$a0, $s0				# countWays(n-2)
	sub 	$a0, $a0, 2
	move 	$s0, $v0
	jal 	countWays

	addu	$v0, $v0, 1

countDone:
	lw 	$ra, ($sp)
	lw 	$s0, 4($sp)
	addu	$sp, $sp, 8
	jr	$ra

.end countWays


#####################################################################
#  Function to ask user if they want to continue.

#  Basic flow:
#	prompt user
#	read user answer (as character)
#		if y -> return TRUE
#		if n -> return FALSE
#	otherwise, display error and loop to re-prompt

# -----
#  Arguments:
#	none
#  Returns:
#	$v0 - TRUE/FALSE

.globl	continue
.ent	continue
continue:
	subu	$sp, $sp, 4
	sw	$ra, ($sp)

	la 	$a0, qPmt
	li 	$v0, 4
	syscall

inputAns:
	li 	$v0, 12
	syscall

	beq $v0, 110, ansNo
	beq	$v0, 121, ansYes

printErr:
	la 	$a0, newLine
	li 	$v0, 4
	syscall

	la 	$a0, ansErr
	li 	$v0, 4
	syscall

	la 	$a0, qPmt
	li 	$v0, 4
	syscall

	j 	inputAns

ansYes:
	la 	$a0, newLine
	li 	$v0, 4
	syscall

	la 	$a0, newLine
	li 	$v0, 4
	syscall

	la	$v0, TRUE
	j	done

ansNo:
	la 	$a0, newLine
	li 	$v0, 4
	syscall

	la	$v0, FALSE
	j 	done

done:
	lw	$ra, ($sp)
	addu	$sp, $sp, 4
	jr	$ra

.end	continue

#####################################################################
