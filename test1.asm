.data
    # filename: .asciiz "\/Users\/tefferon\/Documents\/workspace\/MIPS-Lexathon\/test.txt"
    # filename: .asciiz "/Users/tefferon/Documents/workspace/MIPS-Lexathon/test.txt"
    filename: .asciiz "./test.txt"
    
.text
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
.macro read_file(%filename, %buffer, %n)
    .data
        #filename: .word %filename
        buffer:   .word %buffer
        n:        .word %n
    .text
        move   $a0, %filename             # prep file descriptor for read
        la   $a1, buffer            # allocate space for the bytes loaded
        li   $a2, %n             # number of bytes to be read
        li   $v0, 14                # syscall 14 == read from file
        syscall 
    .end_macro

## print(bufferName)
.macro print(%str)
    .data
        str: .word %str
    .text
        li $v0, 4
        la $a0, str
        syscall
    .end_macro

## Print_File(filename) -- not sure about buffersizing. I know buffer can overflow, nothing to stop it. 
.macro Print_File(%filename)
    .data
        filename:  .word  %filename     #file name
        buffer:    .space 1000     
    .text
        open_file(filename)
        
        read_file( $v0, buffer, 1000)
        print(buffer)
         
            # Close the file 
            li   $v0, 16       # system call for close file
            move $a0, $s6      # file descriptor to close
            syscall            # close file
    .end_macro  

Print_File(filename)