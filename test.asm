
        li   $v0, 42              # syscall 14 == read from file
        li   $a0, 0           # prep file descriptor for read
        li   $a1, 10       # allocate space for the bytes loaded
        #li   $a2, 1050            # number of bytes to be read
        syscall
        
        #la   $a0, textSpace       # address of string to be printed
        li   $v0, 1               # print string
        syscall
        
        li   $v0, 10               # print string
        syscall