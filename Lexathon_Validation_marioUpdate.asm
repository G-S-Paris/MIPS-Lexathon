
# by ya boi bignasty MJ, 11/19/16


.data 
UserInput:    .asciiz 
#result:  .asciiz "The number of characters is: "
prompt:  .asciiz "Enter a word:  "
word:    .asciiz "predicate"
null: .asciiz "\n"
doneString: .asciiz "999" 

UserEntry: 	.space 20

w1: .asciiz     "dictatr"
w2:  .asciiz "predi"
w3: .asciiz  "crate"

addrs: 
  .word w1
  .word w2
  .word w3

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
lb $t1, ($t0)   #load the character at the index into t1
beq $t1, $zero, getCountOfChars
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
lb $t8, ($t4)   #load the character at the index into t1
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

.macro mac_PrintCentralLetter
.text
li $v0, 11
la $a0, ($s1)
syscall
.end_macro

.macro mac_PrintLetter
.text
li $v0, 11
la $a0, ($t1)
syscall
.end_macro

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
la $s0, word
lb $s1, 1($s0)	#s1 holds central letter, letter that has to be in any word inputted by user; hardcoded to be 2nd letter
.end_macro

.macro mac_initCountAndIndex
la $t0, UserEntry
li $t2, 0
la $s0, word
li $t4, 8	# used before in validateLength function; now used to hold length of 9-letter word
li $t6, 0	# used to keep track of index in 9-letter word
.end_macro



################## END_MACROS ###############################

.text

init:
li $s5, 0
mac_getCentralLetter
mac_PrintString("The given central letter is: ")
mac_PrintCentralLetter

main:
mac_initCountAndIndex
mac_PrintString("\nEnter a word, or input 999 to exit:  ")    #prompt user for word
mac_getUserString
mac_getLength
move $t7, $zero
move $s6, $zero

jal EndOrNah
jal validateLength
#jal exit_Length
mac_initCountAndIndex
addi $t3, $t3, -1
jal validateCentralLetter
mac_initCountAndIndex 
#mac_PrintString("Back in main")
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

jal seeIfInHistory

addi $s5, $s5, 1
j main

EndOrNah:
li $t4, 0
la $t7, doneString
la $t0, UserEntry
beq $t3, 3, compareToDoneString
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
beq $t4, 3, done
j compareToDoneString




done:
mac_PrintString("You entered ")
mac_PrintInt($s5)
mac_PrintString(" words.")


exit:
li $v0, 10
syscall

seeIfInHistory:
li $s4, 0
move $s3, $zero
#addi $t6, $t6, 4
#mac_PrintString("current word index: ")
#mac_PrintInt($t6)
#mac_PrintString("\n")
#addi $t4, $t4, 4
#addi $s6, $s6, 4

li 	$t7, 12
lw 	$s3, addrs($t6)   
#sw      $s3, addrs($t6)   



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
lb $t1, ($s3)
lb $t2, ($t0)

#li $v0, 11
#la $a0, ($t1)
#syscall 
#mac_PrintString(" ")
#li $v0, 11
#la $a0, ($t2)
#syscall 

bne $t1, $t2, seeIfInHistory_cont1
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
j main

validateCentralLetter:	#sees if central letter is used in the word
addiu $sp, $sp, -8	#allocate space for 2 words
sw $ra, 0($sp)	#store return address
sw $v0, 4($sp)	#store return from function
#move $s2, $ra
lb $t1, ($t0)   #load the character at the index into t1
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
bne $t1, $s1, validateCentralLetter_cont2
jr $ra

validateCentralLetter_cont2:
addi $t2, $t2, 1  # increment index
addi $t0, $t0, 1  #increment address, so that the lb function accesses the next char
#mac_PrintString("In second central char validation.")
j validateCentralLetter

##########

##########

validateAllLetters:
addiu $sp, $sp, -8	#allocate space for 2 words
sw $ra, 0($sp)	#store return address
sw $v0, 4($sp)
lb $t1, ($t0)   #user string: load the character at the index into t1
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
bne $t1, $t5, increaseIndex
la $s0, word
li $t6, 0
addi $t2, $t2, 1  # increment number of chars in string
##beq $t2, $t3, main
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
j main

errorAllLetters_2:
mac_PrintString("Error: Input may only contain characters in the 9-letter word.\n")
j main

errorCentralLetter:
mac_PrintString("Error: Word does not contain central character.\n")
j main

exit_CentralLetter:
mac_PrintString("Central letter constraint satisfied.\n")
jr $ra

errorAlreadyInHistory:
mac_PrintString("Error: This word is already in your history.\n")
j main 

exit_Length:
#mac_PrintString("Length constraint satisfied. Word length = ")
mac_PrintString("Length constraint satisfied.\n")
#mac_PrintInt($t3)
jr $ra













