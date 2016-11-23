## state of affairs 
# Learned some stuff regarding macros that might make them possible again. 
# fucking literals v. labels make everything complicated. 
# once I have these niche things down, I'll be able to rocket throught the rest of this I think. 
# When I get home I'll make an outline / status report. 


.data 
    ## Buffer sizes
    4dict: .space 27012 # 6753   words
    5dict: .space  5528 # 1382   words
    6dict: .space  6036 # 1509   words
    7dict: .space       #        words 
    8dict: .space       #        words 
    9dict: .space  3636 #  909   words 

    ## refArray to buffers 
    nDict: .space 20

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

############## MACROS ###################

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

## read_file(fileDescriptor, buffer, n)
.macro read_file(%fdesc, %buffer, %n)
    .text
        move   $a0, %fdesc         # prep file descriptor for read
        la     $a1, %buffer        # allocate space for the bytes loaded
        move   $a2, %n             # number of bytes to be read
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
        la $a0, str
        li $v0, 4
        syscall
    .end_macro 

## print_file(filename) -- not sure about buffersizing. I know buffer can overflow, nothing to stop it. 
## written to print file from literal context. Not needed / depricated
.macro print_file(%filename)
    .data
        filename:  .asciiz %filename     # file name
        buffer:    .space  1000
    .text
        ## Open
        li   $v0, 13              # syscall 13 == open a file; returns file descriptor to v0
        la   $a0, filename        # load file name
        li   $a1, 0               # Open for writing (flags are 0: read, 1: write)
        li   $a2, 0               # mode is ignored
        syscall
        
        ## Read
        move $a0, $v0             # prep file descriptor for read
        la   $a1, buffer          # allocate space for the bytes loaded
        li   $a2, 57888           # number of bytes to be read
        li   $v0, 14              # syscall 14 == read from file
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

#############

Print_File("\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/test.txt")
#Print_File("C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\fourtonineletters_6432.txt")