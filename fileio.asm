#.macro
#.end_macro


.macro Print_File1(%str)
    .data
        #filename:  .asciiz "C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\fourtonineletters_6432.txt" #file name
        filename:  .asciiz %str #file name
        textSpace: .space 1050     #space to store strings to be read 57888
        ftnl_size: .space 57888
        dict_end:  .word  6432

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
            # la   $a1, textSpace       # allocate space for the bytes loaded
            la   $a1, ftnl_size       # allocate space for the bytes loaded
            li   $a2, 57888            # number of bytes to be read
            syscall  

            #la   $a0, textSpace       # address of string to be printed
            la   $a0, ftnl_size       # address of string to be printed
            li   $v0, 4               # print string
            syscall

            # Close the file 
            li   $v0, 16       # system call for close file
            move $a0, $s6      # file descriptor to close
            syscall            # close file
.end_macro  

.macro Print_File(%str)
    .data
        filename:  .asciiz %str     #file name
        textSpace: .space 4      #space to store strings to be read 57888
        ftnl_size: .space 4
        dict_end:  .word  6432

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
            la   $a1, textSpace       # allocate space for the bytes loaded
            la   $a3, ftnl_size       # allocate space for the bytes loaded
            li   $a2, 57888            # number of bytes to be read
            syscall  

            la   $a0, textSpace       # address of string to be printed
            li   $v0, 4               # print string
            syscall

            # Close the file 
            li   $v0, 16       # system call for close file
            move $a0, $s6      # file descriptor to close
            syscall            # close file
.end_macro  

Print_File("C:\\Users\\gsp15\\Documents\\GitHub\\MIPS-Lexathon\\fourtonineletters_6432.txt")