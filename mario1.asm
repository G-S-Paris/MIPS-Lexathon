#s0 :: address of the 9 letter word
#s1 :: copy of the 9 letter graph word
#s2 :: time_variable
#s3 :: s
#s4 :: t
#s5 :: e
#s6 ::
#s7 :: shuffle_counter
.data
startGame: 		.asciiz "To begin, enter a '0' \n\n"
commands:		.asciiz "\nTo shuffle the board, enter a 's' \nTo see remaining time, enter a 't' \nTo end the game, enter a 'e'\n"
tryAgain:		.asciiz "Try again!"
invalidWord:		.asciiz "That is not a word! Try again: "
validWord:		.asciiz "Word found! Keep going: "
gameOver:		.asciiz "Game over!"
gameRulesOne:		.asciiz "!Lexathon! \n\nHow to play: You will be given a 3x3 graph of nine letters. \nYour goal is to create a four to nine letter word using the \nletters provided. The letter in the middle must be used \nfor the word to count! Good luck! \n\nThe following commands may be called at any time:\n"
output: 		.asciiz "Enter word:  "
space: 			.asciiz " "
newline: 		.asciiz "\n"
prompt:  		.asciiz "Enter a word:  "
null: 			.asciiz "\n"
time:			.asciiz "t"
shuffle:		.asciiz "s"
end:			.asciiz "e"
sec: 			.asciiz " seconds remaining"
w1: 			.asciiz "dictatr"
w2:			.asciiz "predi"
w3: 			.asciiz "crate"
w4:			.asciiz "catei"
w5:			.asciiz "cater"
w6:			.asciiz "dictate"
sorry_statement:	.asciiz "Sorry, you ran out of time!"
buffer:			.space 20
UserEntry: 		.space 20

addrs:
  .word w1
  .word w2
  .word w3
  .word w4
  .word w5
  .word w6


################## MACROS ###############################

.macro mac_PrintInt(%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro mac_getLength
	li $t2, 0
	j loop

loop:
	lb $t7, ($t0)   #load the character at the index into t7
	beq $t7, $zero, getCountOfChars
	addi $t2, $t2, 1  # increment number of chars in string
	addi $t0, $t0, 1  #increment address, so that the lb function accesses the next char
	j loop

getCountOfChars:
	addi $t3, $t2, -1	#t3 holds the length of the string; I had to put a -1, otherwise it was showing the wrong length
	#mac_PrintInt($t3)	#check to see if the length is right

.end_macro

.macro mac_getLength_history
	#move $t4, $zero
	add $t4, $s3, $zero
	li $t2, 0
	j loop

loop:
	lb $t8, ($t4)   #load the character at the index into t7
	beq $t8, $zero, getCountOfChars
	addi $t2, $t2, 1  # increment number of chars in string
	addi $t4, $t4, 1  #increment address, so that the lb function accesses the next char
	j loop

getCountOfChars:
	addi $t9, $t2, 0	#t3 holds the length of the string; I
	#mac_PrintInt($t9)	#check to see if the length is right

.end_macro


.macro mac_PrintString(%str)
.data
printstr: .asciiz %str
.text
	li $v0, 4
	la $a0, printstr
	syscall
.end_macro

#.macro mac_PrintCentralLetter
#text
#	li $v0, 11
#	la $a0, ($s1)
#	syscall
#.end_macro

#.macro mac_PrintLetter
#.text
#	li $v0, 11
#	la $a0, ($t7)
#	syscall
#end_macro

.macro mac_PrintChar9LetterWord
.text
	li $v0, 11
	la $a0, ($t5)
	syscall
.end_macro

.macro mac_getUserString
	li $v0,8	#get word, store in UserEntry
	la $a0,UserEntry
	addi $a1,$zero,20   # read max of 20 characters
	syscall
	la $t0, UserEntry	#store address of USerEntry into $t0
.end_macro

.macro mac_getCentralLetter
	addi $s0, $s1, 0
	lb $t8, 4($s0)	#s1 holds central letter, letter that has to be in any word inputted by user; hardcoded to be 2nd letter
.end_macro

.macro mac_initCountAndIndex
	la $t0, UserEntry
	li $t2, 0
	#la $s0, word
	li $t4, 8	# used before in validateLength function; now used to hold length of 9-letter word
	li $t6, 0	# used to keep track of index in 9-letter word
.end_macro

################## END_MACROS ###############################

.text

	lb $s3, shuffle
	lb $s4, time
	lb $s5, end

printRules:
	la $a0, gameRulesOne	# Printing the rules
	li $v0, 4
	syscall

	la $a0, commands	# Showing game commands
	li $v0, 4
	syscall

	la $a0, startGame	# Showing command to begin
	li $v0, 4
	syscall

reed:

	li $t1, 0		#shuffle counter
	li $v0, 4
	la $a0, output 		#prints output
	syscall

	li $v0, 8		#8 is read string call number
	la $a0, buffer		#string is stored in $t0
	li $a1, 11		#string size
	move $s0, $a0
	syscall

start:
	li $v0, 30
	syscall

	move $s2, $a0

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	b loop

middle:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2 	# decrements the address of string
	li $v0, 4
	la $a0, space		#prints a space after char
	syscall
loop:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 1, loop
	beq $s7, 4, new_line
	beq $s7, 5, reset
	beq $s7, 7, middle
	beq $s7, 9, new_line
	beq $s7, 12, reset
	beq $s7, 14, done
	b print



print:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space		#prints a space after char
	syscall
	b loop

reset:

	addi $s0, $s0, -11	#decrements index by 9
	b loop

new_line:

	li $v0, 4
	la $a0, newline		#prints a new line after third char in line
	syscall

	addi $s0, $s0, -2	#decrements address of string before increment
	b loop

done:

	add $s0, $zero, $s1	#resets s0 to s1
	li $v0, 4
	la $a0, newline		#prints a new line after third char in line
	syscall

	la $a0, commands	# Showing game commands
	li $v0, 4
	syscall

	#li $v0, 12
	#syscall			#holds what user enters

	#move $s7, $v0

	b validation

shuffle_1:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, -2
	b loop1

middle1:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2

	li $v0, 4
	la $a0, space
	syscall

loop1:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 2, loop1
	beq $s7, 4, new_line1
	beq $s7, 6, reset1
	beq $s7, 7, middle1
	beq $s7, 9, new_line1
	beq $s7, 13, done
	b print1

print1:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall
	b loop1

reset1:
	addi $s0, $s0, -11	#decrements index by 9
	b loop1
new_line1:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop1

shuffle_2:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, -1
	b loop2

middle2:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop2:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 10, loop2
	beq $s7, 3, new_line2
	beq $s7, 6, reset2
	beq $s7, 5, middle2
	beq $s7, 8, new_line2
	beq $s7, 13, done
	b print2

print2:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall
	b loop2

reset2:

	addi $s0, $s0, -11	#decrements index by 9
	b loop2

new_line2:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop2

shuffle_3:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, 1
	b loop3

middle3:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop3:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 9, loop3
	beq $s7, 3, new_line3
	beq $s7, 4, reset3
	beq $s7, 6, middle3
	beq $s7, 8, new_line3
	beq $s7, 12, reset3
	beq $s7, 14, done
	b print3

print3:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall
	b loop3

reset3:

	addi $s0, $s0, -11	#decrements index by 11
	b loop3

new_line3:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop3

shuffle_4:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, 3
	b loop4

middle4:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop4:
	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 7, loop4
	beq $s7, 4, new_line4
	beq $s7, 2, reset4
	beq $s7, 6, middle4
	beq $s7, 9, new_line4
	beq $s7, 11, reset4
	beq $s7, 14, done
	b print4

print4:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall
	b loop4

reset4:
	addi $s0, $s0, -11	#decrements index by 11
	b loop4

new_line4:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop4

shuffle_5:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, 4
	b loop5

middle5:

	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop5:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 4, new_line5
	beq $s7, 2, reset5
	beq $s7, 6, middle5
	beq $s7, 8, new_line5
	beq $s7, 10, reset5
	beq $s7, 13, done
	b print5

print5:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall
	b loop5

reset5:

	addi $s0, $s0, -11	#decrements index by 11
	b loop5

new_line5:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop5

shuffle_6:

	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, 5
	b loop6

middle6:
	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop6:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 5, loop6
	beq $s7, 4, new_line6
	beq $s7, 1, reset6
	beq $s7, 7, middle6
	beq $s7, 9, new_line6
	beq $s7, 10, reset6
	beq $s7, 14, done
	b print6

print6:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall

	b loop6

reset6:
	addi $s0, $s0, -11	#decrements index by 11
	b loop6

new_line6:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop6

shuffle_7:
	addi $s1, $s0, 0	#creates copy of address for string points at p
	addi $s7, $zero, -1	#iteration count
	addi $s0, $s0, 6
	b loop7

middle7:
	li $v0, 11
	lb $a0, 4($s1)		#prints out specific char in middle
	syscall

	addi $s0, $s0, -2
	li $v0, 4
	la $a0, space
	syscall

loop7:

	addi $s0, $s0, 2	# increment index by 2
	addi $s7, $s7, 1
	beq $s7, 11, loop7
	beq $s7, 4, new_line7
	beq $s7, 1, reset7
	beq $s7, 6, middle7
	beq $s7, 8, new_line7
	beq $s7, 9, reset7
	beq $s7, 14, done7
	b print7

print7:

	li $v0, 11
	lb $a0, 0($s0)		#print out character
	syscall

	li $v0, 4
	la $a0, space
	syscall

	b loop7

reset7:
	addi $s0, $s0, -11	#decrements index by 11
	b loop7

new_line7:

	li $v0, 4
	la $a0, newline
	syscall

	addi $s0, $s0, -2
	b loop7

done7:
	add $s0, $zero, $s1	#resets s0 to s1

	li $v0, 4
	la $a0, newline		#prints a new line after third char in line
	syscall

	la $a0, commands	# Showing game commands
	li $v0, 4
	syscall

	#li $v0, 5
	#syscall			#holds what user enters
	#move $s7, $v0

	addi $t1, $zero, -1
	addi $s7, $zero, -1
	#beq $s7, $s3, shuffle_counter	#if s7 is 1, shuffle
	#beq $s7, $s4, show_time
	#beq $s7, $s5, exit
	b shuffle_counter

shuffle_counter:

	addi $t1, $t1, 1
	beq $t1, 1, shuffle_1
	beq $t1, 2, shuffle_2
	beq $t1, 3, shuffle_3
	beq $t1, 4, shuffle_4
	beq $t1, 5, shuffle_5
	beq $t1, 6, shuffle_6
	beq $t1, 7, shuffle_7
	b loop
show_time:

	li $s7, -1
	li $v0, 30
	syscall

	li $t5, 1000
	li $t6, -1
	sub $a0, $a0, $s2
	div $a0, $t5
	mflo $a0
	addi $a0, $a0, -60
	mul  $a0, $a0, $t6
	mflo $a0

	li $v0, 1
	syscall

	li $v0, 4
	la $a0, sec
	syscall

	li $v0, 4
	la $a0, newline
	syscall

	li $v0, 4
	la $a0, newline
	syscall


	b shuffle_counter

time_test_shuffle:

	li $v0, 30
	syscall

	li $t5, 1000
	li $t6, -1
	sub $a0, $a0, $s2
	div $a0, $t5
	mflo $a0
	addi $a0, $a0, -60
	mul  $a0, $a0, $t6
	mflo $a0

	slt $t5, $a0, $zero
	beq $t5, 1, sorry

	b shuffle_counter

time_test_time:

	li $v0, 30
	syscall

	li $t5, 1000
	li $t6, -1
	sub $a0, $a0, $s2
	div $a0, $t5
	mflo $a0
	addi $a0, $a0, -60
	mul  $a0, $a0, $t6
	mflo $a0

	slt $t5, $a0, $zero
	beq $t5, 1, sorry
	addi $t1, $t1, -1
	b show_time

sorry:
	li $v0, 4
	la $a0, sorry_statement
	syscall
	b exit
exit:
	li $v0, 10
	syscall

validation:

.text

init:
	#li $s5, 0
	mac_getCentralLetter

mario:
	mac_initCountAndIndex
	mac_PrintString("\nEnter word:  ")    #prompt user for word

	move $t0, $zero
	mac_getUserString
	mac_getLength

	move $t6, $zero
	move $t7, $zero
	move $t8, $zero
	move $t9, $zero
	la $t0, UserEntry
	jal checkSpecChar

	mac_getLength
	move $t7, $zero
	move $s6, $zero

	#jal EndOrNah
	jal validateLength
	#jal exit_Length
	mac_initCountAndIndex
	addi $t3, $t3, -1
	jal validateCentralLetter
	mac_initCountAndIndex
	#mac_PrintString("Back in mario")
	#jal exit_CentralLetter
	li $t4, 8	# used before in validateLength function; now used to hold length of 9-letter word
	li $t6, 0	# used to keep track of index in 9-letter word
	#mac_PrintInt($t3)
	addi $t3, $t3, +1
	jal validateAllLetters
	mac_initCountAndIndex
	li $t6, 0
	#li $t4, 0
	li $s6, 0
	mac_getLength
	#la $s3, addrs

	#jal seeIfInHistory

	#addi $s5, $s5, 1
	addi $s0, $s1, 0
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

checkSpecChar:
	beq $t3, 1, checkSpecChar_cont
	j itsAllGood

checkSpecChar_cont:
	la $s3, shuffle
	la $s4, time
	la $s5, end
	lb $t6, ($s3)
	lb $t7, ($s4)
	lb $t8, ($s5)
	lb $t9, ($t0)

	beq $t9, $t7, time_test_time	#if t0 is 1, shuffle
	beq $t9, $t6, time_test_shuffle
	beq $t9, $t8, exit
	j itsAllGood

compareToDoneString:
	#mac_PrintString("Here. ")
	addi $t4, $t4, 1
	lb $s6, ($t7)
	lb $t6, ($t0)
	beq $t6, $s6, keepGoingBro
	j itsAllGood

keepGoingBro:
	#mac_PrintString("Here. ")
	addi $t7, $t7, 1
	addi $t0, $t0, 1
	beq $t4, 3, doneMario
	j compareToDoneString

doneMario:
	mac_PrintString("You entered ")
	mac_PrintInt($s5)
	mac_PrintString(" words.")

seeIfInHistory:
	li $s4, 0
	move $s3, $zero
	#addi $t6, $t6, 4
	#mac_PrintString("current word index: ")
	#mac_PrintInt($t6)
	#mac_PrintString("\n")
	#addi $t4, $t4, 4
	#addi $s6, $s6, 4

	li $t7, 12
	lw $s3, addrs($t6)
	#sw $s3, addrs($t6)

	la $t0, UserEntry
	#mac_PrintString("In array: ")
	#li $v0, 4
	#la $a0, ($s3)
	#syscall

	mac_getLength_history

	#mac_PrintInt($t9)
	#mac_PrintString("\n")
	#mac_PrintInt($t3)

	beq $t3, $t9, seeIfInHistory_cont

	#j seeIfInHistory_cont

	addi $s6, $s6, 4
	addi $t6, $t6, 4
	blt $s6, $t7, seeIfInHistory
	#mac_PrintString("not supposed to be here")
	#jr $ra
	j itsAllGood

	#seeIfInHistory_continueLoopingArray:
	#j seeIfInHistory

seeIfInHistory_cont:
	#mac_PrintString("same length")
	lb $t7, ($s3)
	lb $t2, ($t0)

	#li $v0, 11
	#la $a0, ($t7)
	#syscall
	#mac_PrintString(" ")
	#li $v0, 11
	#la $a0, ($t2)
	#syscall

	bne $t7, $t2, seeIfInHistory_cont1
	addi $s4, $s4, 1
	blt $s4, $t9, incrementIndex_Hist
	j errorAlreadyInHistory

incrementIndex_Hist:
	#mac_PrintString("")
	addi $s3, $s3, 1
	addi $t0, $t0, 1
	j seeIfInHistory_cont

seeIfInHistory_cont1:
	addi $s6, $s6, 4
	addi $t6, $t6, 4
	blt $s6, $t7, seeIfInHistory
	#move $t4, $zero
	j itsAllGood
	#j errorAlreadyInHistory

itsAllGood:
	#mac_PrintString("No worries, mate.")
	jr $ra
	#mac_PrintString("Piss off, mate.")

validateLength:
	li $t5, 4
	slt $t4, $t3, $t5	#see if the length is less than 4
	beq $t4, 1, repromptLength
	li $t5, 9
	sgt $t4, $t3, $t5	#see if the length is greater than 9
	beq $t4, 1, repromptLength
	jr $ra

repromptLength:
	mac_PrintString("Error: Word must be between 4 and 9 characters, inclusive.\n")
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

validateCentralLetter:	#sees if central letter is used in the word
	mac_getCentralLetter
	addiu $sp, $sp, -8	#allocate space for 2 words
	sw $ra, 0($sp)	#store return address
	sw $v0, 4($sp)	#store return from function
	#move $s2, $ra
	lb $t7, ($t0)   #load the character at the index into t7
	bgt $t2, $t3, errorCentralLetter
	jal validateCentralLetter_cont
	#move $ra, $s2
	lw $v0, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 8
	#mac_PrintString("Here ")
	jr $ra

validateCentralLetter_cont:
	#mac_PrintString("Current letter: ")
	#mac_PrintLetter
	#mac_PrintString("\n")
	mac_getCentralLetter
	bne $t7, $t8, validateCentralLetter_cont2
	jr $ra

validateCentralLetter_cont2:
	addi $t2, $t2, 1  # increment index
	addi $t0, $t0, 1  #increment address, so that the lb function accesses the next char
	#mac_PrintString("In second central char validation.")
	j validateCentralLetter

validateAllLetters:
	addiu $sp, $sp, -8	#allocate space for 2 words
	sw $ra, 0($sp)	#store return address
	sw $v0, 4($sp)
	lb $t7, ($t0)   #user string: load the character at the index into t7
	#mac_PrintLetter
	lb $t5, ($s0)	# 9-letter generated word: load the character at the index into t5
	#mac_PrintChar9LetterWord
	bgt $t2, $t3, errorAllLetters_1
	jal validateAllLetters_cont
	lw $v0, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 8
	blt $t2, $t3, validateAllLetters
	jr $ra

validateAllLetters_cont:
	bne $t7, $t5, increaseIndex
	addi $s0, $s1, 0
	li $t6, 0
	addi $t2, $t2, 1  # increment number of chars in string
	##beq $t2, $t3, mario
	addi $t0, $t0, 1  #increment address, so that the lb function accesses the next char
	##j validateAllLetters
	jr $ra

increaseIndex:
	#mac_PrintString("Current Letter in 9-letterWord: ")
	#mac_PrintChar9LetterWord
	#mac_PrintString("\n")
	addi $s0, $s0, 1
	addi $t6, $t6, 1
	bgt $t6, $t4, errorAllLetters_2
	j validateAllLetters

errorAllLetters_1:
	mac_PrintString("Error: Input may only contain characters in the 9-letter word.(User size exceeded).\n")
	addi $s0, $s1, 0
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

errorAllLetters_2:
	mac_PrintString("Error: Input may only contain characters in the 9-letter word.\n")
	addi $s0, $s1, 0
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

errorCentralLetter:
	mac_PrintString("Error: Word does not contain central character.\n")
	addi $s0, $s1, 0
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

exit_CentralLetter:
	mac_PrintString("Central letter constraint satisfied.\n")
	jr $ra

errorAlreadyInHistory:
	mac_PrintString("Error: This word is already in your history.\n")
	addi $s0, $s1, 0
	addi $s7, $zero, -1
	addi $t1, $t1, -1
	j shuffle_counter

exit_Length:
	#mac_PrintString("Length constraint satisfied. Word length = ")
	mac_PrintString("Length constraint satisfied.\n")
	#mac_PrintInt($t3)
	jr $ra
