.data 
    ## size in bytes 
    # 4dict: .space 34800  # words
    # 5dict: .space  8300  # words
    # 6dict: .space 10600  # words
    # 7dict: .space        # words 
    # 8dict: .space        # words 
    # 9dict: .space  9100  # words 

    ## file names 
    # 4dict_name: .asciiz "4dict.txt" 
    # 5dict_name: .asciiz "5dict.txt" 
    # 6dict_name: .asciiz "6dict.txt" 
    # 7dict_name: .asciiz "7dict.txt"  
    # 8dict_name: .asciiz "8dict.txt"  
    # 9dict_name: .asciiz "9dict.txt" 

    ## Buffer sizes
    4dict: .space 27012 # 6753   words
    5dict: .space  5528 # 1382   words
    6dict: .space  6036 # 1509   words
    7dict: .space       #        words 
    8dict: .space       #        words 
    9dict: .space  3636 #  909   words 

    ## refArray to buffers 
    nDict: .space 20

.text

## example call:
 #      Load_nDict("4dict.txt", 4dict, 4)
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
        
        ## Read
        move $a0, $v0               # prep file descriptor for read
        la   $a1, buffer            # allocate space for the bytes loaded
        li   $a2, n             # number of bytes to be read         
        li   $v0, 14                # syscall 14 == read from file
        syscall  
        
        ## Print 
        la   $a0, buffer          # address of string to be printed
        li   $v0, 4               # print string
        syscall


        ## Close the file 
        li   $v0, 16       # system call for close file
        move $a0, $s6      # file descriptor to close
        syscall            # close file

    .end_macro

## store_reference(address, index)
.macro store_reference(%address, %index)
    .data
        address: .word %address
        index:   .byte %index
    .text

    .end_macro 

## open_file(filename) -- file descriptor placed in $v0
.macro open_file(%filename)
    .data
        filename:  .word %filename

    .text
        li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
        la   $a0, filename        # load file name
        li   $a1, 0               # Open for Reading (flags are 0: read, 1: write)
        li   $a2, 0               # mode is ignored
        syscall
    .end_macro

## read_file(fileDescriptor, buffer, n)
.macro read_file(%fdesc, %buffer, %n)
    .data
        fdesc:  .word %fdesc
        buffer: .word %buffer
        n:      .byte %n
    .text
        move   $a0, fdesc             # prep file descriptor for read
        move   $a1, buffer            # allocate space for the bytes loaded
        li     $a2, 57888             # number of bytes to be read
        li     $v0, 14                # syscall 14 == read from file
        syscall 
    .end_macro

## print(bufferName)
.macro print(%str)
    .data
        str: .asciiz %str
    .text
        li $v0, 4
        la $a0, str
        syscall
    .end_macro 

## Print_File(filename) -- not sure about buffersizing. I know buffer can overflow, nothing to stop it. 
.macro Print_File(%filename)
    .data
        filename:  .asciiz %filename     # file name
        buffer:    .space  1000
    .text
        main:
            li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
            la   $a0, filename        # load file name
            li   $a1, 0               # Open for writing (flags are 0: read, 1: write)
            li   $a2, 0               # mode is ignored
            syscall
            move $s6, $v0             # save the file descriptor
            
            li   $v0, 14              # syscall 14 == read from file
            move $a0, $s6             # prep file descriptor for read
            la   $a1, buffer          # allocate space for the bytes loaded
            li   $a2, 57888           # number of bytes to be read
            syscall  

            ## print the buffer 
            la   $a0, buffer          # address of string to be printed
            li   $v0, 4               # print string
            syscall

            # Close the file 
            li   $v0, 16       # system call for close file
            move $a0, $s6      # file descriptor to close
            syscall            # close file
    .end_macro  

Print_File("\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/test.txt")
#Print_File("C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\fourtonineletters_6432.txt")