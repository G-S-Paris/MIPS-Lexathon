## Greyson Paris -- November 22 2016 -- Computer Architecture 3340
## macros I probably won't need 


#################### date - 11/27/2016
    ## ****************************
            ## useful for testing, also learning about macro compositions 
            .macro read_line(%fdesc, %buffer, %n)
                .text
                    move   $a0, %fdesc         # prep file descriptor for read
                    la     $a1, %buffer        # allocate space for the bytes loaded
                    move   $a2, %n             # number of bytes to be read
                    li     $v0, 14             # syscall 14 == read from file
                    syscall 
                .end_macro

            ##******************************
            ## Useful for testing
            .macro read_file(%fdesc, %buffer, %filelength)
                .text
                    move   $a0, %fdesc         # prep file descriptor for read
                    la     $a1, %buffer        # allocate space for the bytes loaded
                    move   $a2, %filelength             # number of bytes to be read
                    li     $v0, 1000000             # syscall 14 == read from file
                    syscall 
                .end_macro

     #*****************************
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

            #******************************
            ## print a file (composed of macros); useful for testing and learning about macro composition 
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


########################  older, date == last commit time 

    ##     Load_nDict("4dict.txt", 4dict, 4)
    #      Depricated at this time - only works with literals. 
    .macro Load_nDict(%filename, %buffer, %n)
        .data
            filename:  .word %filename
            buffer:    .space  %buffer 
            n:         .byte   %n 

        .text
            ## Open
            li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
            la   $a0, filename        # load file name
            li   $a1, 0               # Open for Reading (flags are 0: read, 1: write)
            li   $a2, 0               # mode is ignored
            syscall
            #open_file()


            ## Read
            move $a0, $v0               # prep file descriptor for read
            la   $a1, buffer            # allocate space for the bytes loaded
            li   $a2, n             # number of bytes to be read         
            li   $v0, 14                # syscall 14 == read from file
            syscall  
            #read_file()

            ## Print 
            la   $a0, buffer          # address of string to be printed
            li   $v0, 4               # print string
            syscall
            #print()

            ## Close the file 
            li   $v0, 16       # system call for close file
            move $a0, $s6      # file descriptor to close
            syscall            # close file
            #close() 
        .end_macro

    ##     store_reference(address, index)
    #      Incomplete -- also currently set up to work with literals 
    .macro store_reference(%address, %index)
        .data
            address: .word %address
            index:   .byte %index
        .text

        .end_macro 

    ##     open_file(filename) -- file descriptor placed in $v0
    #      Depricated: Literals 
    .macro open_file_literal(%filename)
        .data
            filename:  .word %filename
        .text
            li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
            la   $a0, filename        # load file name
            li   $a1, 0               # Open for Reading (flags are 0: read, 1: write)
            li   $a2, 0               # mode is ignored
            syscall
        .end_macro

    ## open_file(filename) -- file descriptor placed in $v0
    .macro open_file_label(%filename)     
        .text    
            la   $a0, filename        # load file name
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

    ##
    .macro read_file(%fdesc, %buffer, %filelength)
        .text
            move   $a0, %fdesc         # prep file descriptor for read
            la     $a1, %buffer        # allocate space for the bytes loaded
            move   $a2, %filelength             # number of bytes to be read
            li     $v0, 14             # syscall 14 == read from file
            syscall 
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
    .macro print_label(%str)
        .text
            la $a0, %str
            li $v0, 4
            syscall
        .end_macro 

    ## 
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

    ## close_file(%fdesc)
    .macro close_file(%fdesc)
        .text
            li   $v0, 16              # system call for close file
            move $a0, %fdesc             # file descriptor to close
            syscall                   # close file
        .end_macro

    ## print file composed fully of macros 
    .macro print_file_macro(%filename, %buffer, %n)
        .text
                ## open the file 
                open_file_label(%filename)
                move $t9, $v0               ## preserve the file decriptor for closing later 

                ## read the file into the buffer 
                read_line($t9,%buffer,%n) 

                ## print the buffer 
                print_label(%buffer)
      
                # Close the file 
                close_file($t9)

        .end_macro

