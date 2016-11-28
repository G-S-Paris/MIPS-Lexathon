.data 
    ## Constants
    .eqv FOUR   5
    .eqv FIVE   6
    .eqv SIX    7
    .eqv SEVEN  8
    .eqv EIGHT  9
    .eqv NINE   10 

    .eqv dict4_wc 6753 # word count
    .eqv dict5_wc 1382 # word count
    .eqv dict6_wc 1509 # word count
    .eqv dict7_wc 1466 # word count 
    .eqv dict8_wc 1166 # word count 
    .eqv dict9_wc  909 # word count 

    ## refArray to buffers 
    .align 2
        dictN: .space 24      # word per dictionary 

    ## Buffer sizes
    .align 0
        dict4: .space 33800   # file content - bytes #  6753 word count
        dict5: .space  8300   # file content - bytes #  1382 word count
        dict6: .space 10580   # file content - bytes #  1509 word count
        dict7: .space 11770   # file content - bytes #  1466 word count 
        dict8: .space 10500   # file content - bytes #  1166 word count 
        dict9: .space  9100   # file content - bytes #   909 word count 

    ## Filepath for dev reference... will change with your machine 
    # mac_filepath :    .asciiz    "\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 
    # windows_filepath: .asciiz    "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\9dict.txt")

    ## file names 
    test:     .ascii  "test\n"
    dict4_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/4dict.txt" 
    dict5_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/5dict.txt" 
    dict6_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/6dict.txt" 
    dict7_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/7dict.txt" 
    dict8_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/8dict.txt" 
    dict9_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 

    ## windows file names 
    #dict4_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\4dict.txt" 
    #dict5_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\5dict.txt" 
    #dict6_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\6dict.txt" 
    #dict7_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\7dict.txt" 
    #dict8_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\8dict.txt" 
    #dict9_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\9dict.txt" 

    ############## MACROS ###################

    ##### Primitives #####

        ## print_literal("string") --- takes literal "strings"
        .macro print_literal(%literal)
            .data
                string: .asciiz %literal
            .text
                la $a0, string
                li $v0, 4
                syscall
            .end_macro 

        ## print_label(bufferName) --- takes literal "strings"
        .macro print(%string)
            .text
                la $a0, %string
                li $v0, 4
                syscall
            .end_macro 

        .macro print_len(%stringAddr, %n)
            ## print by character a0, 11
            move $a2, %stringAddr      ## probably not needed
            li   $a1, 0                  ## our accumulator
            lb   $a0, ($a2)
            li   $v0, 11               ## our syscall code 

            loop:
                syscall                ## print character
                addi $a1, $a1, 1       ## increment counter
                beq  $a1, %n, exit 
                add  $a3, $a2, $a1
                lb   $a0, ($a3)        ## increment byte address
                j loop
            
            exit:
            .end_macro

        ## open_file(filename) -- file descriptor placed in $v0
        .macro open_file(%filename)     
            .text    
                la   $a0, %filename        # load file name
                li   $a1, 0               # Open for Reading (flags are 0: read, 1: write)
                li   $a2, 0               # mode is ignored
                li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
                syscall
            .end_macro

       
        ## Loads buffer with dictionary, updates dictN -- given file descriptor, buffer, length of read 
        .macro load_buffer(%fdesc, %buffer, %n)
            .text
                    move   $a0, %fdesc              # prep file descriptor for read 
                    move   $a2, %n                  # number of bytes to be read
                    li     $t8, 0
                
            loop:  
                    la     $a1, %buffer($t8)        # allocate space for the bytes loaded
                    li     $v0, 14                  # syscall 14 == read from file
                    syscall 

                    blt $v0, 1, exit                ## exit if there's nothing left to read 
                    add $t8, $t8, %n
                    j loop

            exit:   la   $a0, %buffer               ## store the initial address of buffer into dictN
                    addi $a2, $a2, -5
                    sll  $a2, $a2, 2
                    sw   $a0, dictN($a2) 

            .end_macro

        ## Closes file given file descriptor 
        .macro close_file(%fdesc)
            .text
                li   $v0, 16              # system call for close file
                move $a0, %fdesc             # file descriptor to close
                syscall                   # close file
            .end_macro

    ##### Composistions #####

        ## loads dictionaries into memory, adds dictionary reference to dictN
        .macro load_dict(%filename, %buffer, %n)
            .text
                # open the file 
                open_file(%filename)
                
                # preserve the file decriptor for closing later 
                move $t9, $v0

                # read the file into the buffer 
                load_buffer($t9, %buffer, %n)

                #print(%buffer)
      
                # close the file 
                close_file($t9)
            .end_macro

        ## composite load_dict - no params required
        .macro initialize()
            .text
                addiu $t0, $zero,  FOUR                 # preload register - arbitrary 
                load_dict(dict4_fn, dict4, $t0)         # pass n by register

                addiu $t0, $zero,  FIVE                 # preload register - arbitrary 
                load_dict(dict5_fn, dict5, $t0)         # pass n by register

                addiu $t0, $zero,  SIX                  # preload register - arbitrary 
                load_dict(dict6_fn, dict6, $t0)         # pass n by register

                addiu $t0, $zero,  SEVEN                # preload register - arbitrary 
                load_dict(dict7_fn, dict7, $t0)         # pass n by register

                addiu $t0, $zero,  EIGHT                # preload register - arbitrary 
                load_dict(dict8_fn, dict8, $t0)         # pass n by register

                addiu $t0, $zero,  NINE                 # preload register - arbitrary 
                load_dict(dict9_fn, dict9, $t0)         # pass n by register
            .end_macro

        ## return 0 (==), 1(>), or -1(<) --- candidate __ current 
        #  compare_strings(%candidate, $t0, %word_length)
        .macro compare_strings(%candidate, %current, %word_length)
            .text
                la   $t0, %candidate
                move $t1, %current      
                li   $t2, 0             # accumulator
             
                
                lb      $t3, ($t0) 
                lb      $t4, (%current)
                
                compare:
                    bne      $t3, $t4, not_equal     ## words are not the same 
                    beq      $t2, %word_length, equal          ## words are the same 

                    addi     $t2, $t2, 1             ## increment the counter     

                    addi     $t0, $t0, 1             ## increment the byte address
                    lb       $t3, ($t0)              ## load the next byte 

                    addi     $t1, $t1, 1        
                    lb       $t1, ($t1)

                    j       compare                 ## compare next bytes 

                
                not_equal:                          ## determine which one is bigger
                    slt $t5, $t3, $t1               ## is t0 smaller? yes: 1 no: 0
                    beq $t5, $zero, kgt
                    b klt
                kgt:
                    li $t0, 1
                    j exit
                klt:
                    li $t0, -1
                    j exit
                equal:
                    li $t0, 0
                    j exit 
                exit:
                    
            .end_macro

        .macro binary_search(%buffer, %word_count, %candidate, %word_length)
            la   $a0, 0              ## LO - 0 index
            li   $a1, %word_count    ## HI - number of total words 
            li   $a3, %word_length


            #mult $a1, $a3
            #mflo $a1 

            middle: 
                
                add $a2, $a0, $a1    ## MID = HI + LO / 2
                srl $a2, $a2, 1      ## / 2 

                beq  $a2, $a0, failure 
                beq  $a2, $a1, failure 
                
                multu $a2, $a3       ## Middle word * word_length for offest
                mflo  $t8             ## store it somewhere else... 

                la $t8, %buffer($t8)    ## the address of the word at a2

                compare_strings(%candidate, $t8, %word_length)
            
                beqz $t0, success        ## if compare returns $zero, we've found our match -> score 
                beq  $a2, $a0, failure   ## if lo == mid.... the word probably can't be scored. to be tested. 
                                      ## else, figure out if we should go hi or lo 
                slt  $t0, $t0, $zero  ## 
                beq  $t0, $zero, cgt  ##
                #b clt 
            clt:                      ## Candidate is less than mid
                                      ## if 1, move lo to mid, make new mid 
                subu $a1, $a2, -1
                j middle

            cgt:                      ## Candidate is greater than mid 
                                      ## if -1, move hi to mid, make new mid 
                addi $a0, $a2, 1
                j middle
            
            success:
                        li $a0, 1
            failure: 
                        li $a0, 1 
            exit: 

            .end_macro

        .macro validate_word(%candidate)
                ## calculate number of characters
                    # choose which buffer, "n" value to call binary search with.

                ## perform binary search
                #binary_search(candidate,)

                ## compare strings 
            .end_macro 

        .macro get_word(%buffer, %index, %n)
            .text
                # la $a0, %buffer
                # word = ( [N modifier] * [word index] ) + [buffer base address]
                #      = mx + b
                li    $a0, %n            ## modifier for adjusting address 
                move  $a1, %index        ## 
                multu $a0, $a1             
                mflo  $a0                ## offset

                la $a3, %buffer($a0)

                #print_len($a3, %n)
            .end_macro

        .macro get_9letter()
            .text
                # word = modifier * index + dictionary 
                #      = mx + b
                li    $v0, 42              ## code for random int within range 
                li    $a1, 909             ## upper bound for range 
                syscall                    ## places random number in $a0 -- 

                li    $a2, NINE            ## length of 9letter word in bytes 
                multu $a0, $a2          
                mflo  $a3
                la    $a1, dict9($a3)        ## the return 
            
                ## printing the word for now -- can be changed to 
                print_len($a1, NINE)

            .end_macro

.text
    #############   TEXT SEGMENT    #########################

    # initialize()
    # binary_search(%buff_start, %buff_end, %candidate, %word_length)
    addiu $t0, $zero,  FOUR                 # preload register - arbitrary 
    load_dict(dict4_fn, dict4, $t0)         # pass n by register
    binary_search(dict4, dict4_wc, test, FOUR)


    # la $a1, dict9
    # print_len($a1, NINE)

    # get_9letter()
    
     #addiu $t0, $zero,  100 
     #get_word( dict4, $t0, FOUR)
     #move $t1, $a3
#
     #addiu $t0, $zero,  101
     #get_word( dict4, $t0, FOUR)
     #move $t2, $a3
#
     #compare_strings($t1, $t2, FOUR) ## outputs to a0 
     #li $v0, 1
     #syscall 
