.data 
    ## Constants
    .eqv FOUR   5
    .eqv FIVE   6
    .eqv SIX    7
    .eqv SEVEN  8
    .eqv EIGHT  9
    .eqv NINE   10 

    ## Buffer sizes
    .align 0
        dict4: .space 33800   # file content - bytes #  6753 word count
        dict5: .space  8300   # file content - bytes #  1382 word count
        dict6: .space 10580   # file content - bytes #  1509 word count
        dict7: .space 11770   # file content - bytes #  1466 word count 
        dict8: .space 10500   # file content - bytes #  1166 word count 
        dict9: .space  9100   # file content - bytes #   909 word count 

    ## refArray to buffers 
    .align 2
        dictN: .space 24      # word per dictionary 

    ## Filepath for dev reference... will change with your machine 
    # mac_filepath : .asciiz    "\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 
    # windows_filepath: .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\9dict.txt")

    ## file names 
    dict4_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/4dict.txt" 
    dict5_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/5dict.txt" 
    dict6_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/6dict.txt" 
    dict7_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/7dict.txt" 
    dict8_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/8dict.txt" 
    dict9_fn: .asciiz "/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/Dictionaries\/9dict.txt" 

    ############## MACROS ###################

    ##### Primitives #####

        ## print_literal("string") --- takes literal "strings"
        .macro print_literal(%str)
            .data
                str: .asciiz %str
            .text
                la $a0, str
                li $v0, 4
                syscall
            .end_macro 

        ## print_label(bufferName) --- takes literal "strings"
        .macro print(%str)
            .text
                la $a0, %str
                li $v0, 4
                syscall
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

        ## read_line(fdesc, buffer, n)
        .macro read_line(%fdesc, %buffer, %n)
            .text
                move   $a0, %fdesc         # prep file descriptor for read
                la     $a1, %buffer        # allocate space for the bytes loaded
                move   $a2, %n             # number of bytes to be read
                li     $v0, 14             # syscall 14 == read from file
                syscall 
            .end_macro

        ## consider 
        .macro read_file(%fdesc, %buffer, %filelength)
            .text
                move   $a0, %fdesc         # prep file descriptor for read
                la     $a1, %buffer        # allocate space for the bytes loaded
                move   $a2, %filelength             # number of bytes to be read
                li     $v0, 1000000             # syscall 14 == read from file
                syscall 
            .end_macro


        ## Loads buffer with dictionary, updates 
        .macro load_buffer(%fdesc, %buffer, %n)
            .text
                    li     $t8, 0
                
            loop:   move   $a0, %fdesc              # prep file descriptor for read
                    la     $a1, %buffer($t8)        # allocate space for the bytes loaded
                    move   $a2, %n                  # number of bytes to be read
                    li     $v0, 14                  # syscall 14 == read from file
                    syscall 

                    blt $v0, 1, exit
                    add $t8, $t8, %n
                    j loop

            exit:   la   $a0, %buffer
                    addi $a2, $a2, -5
                    sll  $a2, $a2, 2
                    sw   $a0, dictN($a2) 

            .end_macro

        ## close_file(%fdesc)
        .macro close_file(%fdesc)
            .text
                li   $v0, 16              # system call for close file
                move $a0, %fdesc             # file descriptor to close
                syscall                   # close file
            .end_macro

    ##### Composistions #####

        ## For reference (technically a primitive)
        .macro print_file_nomacro(%filename, %buffer, %n)
            .text
                ## open the file 
                li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
                la   $a0, %filename       # load file name
                li   $a1, 0               # Open for writing (flags are 0: read, 1: write)
                li   $a2, 0               # mode is ignored
                syscall
                move $t0, $v0             # save the file descriptor
                
                ## read the file into the buffer 
                li   $v0, 14              # syscall 14 == read from file
                move $a0, $t0             # prep file descriptor for read
                la   $a1, %buffer         # allocate space for the bytes loaded
                move $a2, %n              # number of bytes to be read
                syscall  

                ## print the buffer 
                la   $a0, %buffer         # address of string to be printed
                li   $v0, 4               # print string
                syscall
      
                # Close the file 
                li   $v0, 16              # system call for close file
                move $a0, $t0             # file descriptor to close
                syscall                   # close file
            .end_macro

        ## print a file (composed of macros)
        .macro print_file(%filename, %buffer, %n)
            .text
                # open the file 
                open_file(%filename)
                
                # preserve the file decriptor for closing later 
                move $t9, $v0

                # read the file into the buffer 
                read_line($t9,%buffer,%n) 

                # print the buffer 
                print(%buffer)
      
                # close the file 
                close_file($t9)
            .end_macro

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

                addiu $t0, $zero,  SIX                 # preload register - arbitrary 
                load_dict(dict6_fn, dict6, $t0)         # pass n by register

                addiu $t0, $zero,  SEVEN                 # preload register - arbitrary 
                load_dict(dict7_fn, dict7, $t0)         # pass n by register

                addiu $t0, $zero,  EIGHT                 # preload register - arbitrary 
                load_dict(dict8_fn, dict8, $t0)         # pass n by register

                addiu $t0, $zero,  NINE                 # preload register - arbitrary 
                load_dict(dict9_fn, dict9, $t0)         # pass n by register
            .end_macro

        .macro validate_word(%word)
                ## calculate number of characters

                ## access appropriate dictionary

                ## perform binary search
            .end_macro 

        .macro get_word(%dictionary, %index, %n)
            .text
                # la $a0, %dictionary
                # word = modifier * index + dictionary 
                #      = mx + b
                move $a0, %n            ## modifier for adjusting address 
                move $a1, %index        ## 
                multu $a0, $a1
                mflo $a0

                la $v0, %dictionary($a0)
                # or, 
                # la $v0, %dictionary
                # add $v0, $v0, $a0 
            .end_macro

        .macro get_9letter()
            .text
                # word = modifier * index + dictionary 
                #      = mx + b
                li $v0, 42              ## code for random int within range 
                li $a1, 909             ## upper bound for range 
                syscall                 ## places random number in $a0 -- 
                li $a1, NINE          ## length of 9letter word in bytes 
                multu $a0, $a1          
                mflo $a3

        #sort of a roadblock, the only thing interfereing w/ passing the 9letter word 
                li $a0, 1       ## filedesc std_out works! 
                la $a1, dict9($a3)      ## the return 
                li $a2, 9       ## no reason to include \n on print
                li $v0, 15      ## write to file syscall 
                syscall 
                
                # or, 
                # la $v0, %dictionary
                # add $v0, $v0, $a0 
            .end_macro


.text
    #############   TEXT SEGMENT    #########################

    initialize()
    get_9letter()
    #print(($v0))
    



    

