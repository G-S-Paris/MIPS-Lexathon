.data 
    ## Constants
    .eqv FOUR   5
    .eqv FIVE   6
    .eqv SIX    7
    .eqv SEVEN  8
    .eqv EIGHT  9
    .eqv NINE   10 

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
    # mac_filepath : .asciiz    "\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 
    # windows_filepath: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\9dict.txt")

    ## file names 
    #dict4_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/4dict.txt" 
    #dict5_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/5dict.txt" 
    #dict6_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/6dict.txt" 
    #dict7_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/7dict.txt" 
    #dict8_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/8dict.txt" 
    #dict9_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 

    ## windows file names 
    dict4_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\4dict.txt" 
    dict5_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\5dict.txt" 
    dict6_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\6dict.txt" 
    dict7_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\7dict.txt" 
    dict8_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\8dict.txt" 
    dict9_fn: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\Dictionaries\\9dict.txt" 

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
            li $a1, 0                  ## our accumulator
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
                    move   $a2, %n                  # number of bytes to be read --- this too 
                    li     $t8, 0
                
            loop:   #move   $a0, %fdesc             # prep file descriptor for read --- shouldnt this be out of loop? 
                    la     $a1, %buffer($t8)        # allocate space for the bytes loaded
                    #move   $a2, %n                 # number of bytes to be read --- this too 
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
        .macro compare_strings(%candidate, %current, %word_length)
            .text
                move $a0, %candidate
                move $a1, %current
                move $a2, %word_length # may be li, depending on how compare is called 
                lb      $t0, ($a0) 
                lb      $t1, ($a1)
                
                compare:
                    bne     $t0, $t1, not_equal     ## words are not the same 
                    beq     $a2, %n, equal          ## words are the same 

                    addi    $a2, $a2, 1             ## increment the counter 
                                            
                    addi     $a0, $a0, 1            ## increment the byte address
                    lb      $t0, ($a0)              ## load the next byte 

                    addi     $a1, $a0, 1        
                    lb      $t1, ($a1)

                    j       compare                 ## compare next bytes 

                
                not_equal:                          ## determine which one is bigger
                    slt $a3, $t0, $t1               ## is t0 smaller? yes: 1 no: 0

                    beq $a3, $zero, kgt
                    b klt
                kgt:
                    li $a0, 1
                    j exit
                klt:
                    li $a0, -1
                    j exit
                equal:
                    li $a0, 0
                    j exit 
                exit:
                    
            .end_macro

        .macro binary_search(%candidate, %word_length, %)
            # hi  buff end -> hardcoded  
            # lo  buff name  -> address 0
            # mid 
                #sum hi lo; ******************** potential for overflow? **************
                # srl 1 (floor); 

            compare_strings()
            ## $a0 now contains 0, 1, or -1  

            ## if 1, move lo to mid, make new mid 

            ## if -1, move hi to mid, make new mid 

            .end_macro

        .macro validate_word(%candidate)
                ## calculate number of characters
                    # choose which buffer, "n" value to call binary search with.

                ## perform binary search
                binary_search(candidate,)

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

                print_len($a3, %n)
                # or, 
                # la $v0, %buffer
                # add $v0, $v0, $a0 
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
                
                ## Passing the word will have to be through address. 
                ## On my mac I am able to take advantage of std_out to print to screen for testing
                ## but this doesn't work on windows. 
                # li $a0, 1               ## filedesc std_out works! 
                # la $a1, dict9($a3)      ## the return 
                # li $a2, 9               ## no reason to include \n on print
                # li $v0, 15              ## write to file syscall 
                # syscall 
                
                ## new solution
                print_len($a1, NINE)

            .end_macro

.text
    #############   TEXT SEGMENT    #########################

    initialize()
    
    la $a1, dict9
    print_len($a1, NINE)

    get_9letter()


    #addiu $t0, $zero,  NINE                 # preload register - arbitrary 
    #load_dict(dict9_fn, dict9, $t0)         # pass n by register
    
    addiu $t0, $zero,  100 
    get_word( dict4, $t0, FOUR )

    



    

