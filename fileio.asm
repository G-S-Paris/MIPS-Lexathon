.data 
    ## Buffer sizes
    dict4: .space 27012   # file content - bytes #  6753 word count
    dict5: .space  5528   # file content - bytes #  1382 word count
    dict6: .space  6036   # file content - bytes #  1509 word count
    dict7: .space 11727   # file content - bytes #  1466 word count 
    dict8: .space 10493   # file content - bytes #  1166 word count 
    dict9: .space  3636   # file content - bytes #   909 word count 

    ## refArray to buffers 
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


    ##     store_reference(address, index)
    #      Incomplete -- also currently set up to work with literals 
    .macro store_reference(%address, %index)
        .data
            address: .word %address
            index:   .byte %index
        .text

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

    ## close_file(%fdesc)
    .macro close_file(%fdesc)
        .text
            li   $v0, 16              # system call for close file
            move $a0, %fdesc             # file descriptor to close
            syscall                   # close file
        .end_macro

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
        
    ## For reference
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


    ## print file composed fully of macros 
    .macro print_file(%filename, %buffer, %n)
        .text
            ## open the file 
            open_file(%filename)
            move $t9, $v0               ## preserve the file decriptor for closing later 

            ## read the file into the buffer 
            read_line($t9,%buffer,%n) 

            ## print the buffer 
            print(%buffer)
  
            # Close the file 
            close_file($t9)
        .end_macro

.text
    #############   TEXT SEGMENT    #########################

    addiu $t0, $zero,  9                     # preload register - arbitrary 
    print_file(dict9_fn, dict9, $t0)   # pass n by register