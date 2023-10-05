#include "kernel/types.h"
#include "user.h"
#include "kernel/stat.h"
#include "kernel/pstat.h"

main(int argCount, char **arg){
    
    if (argCount < 2){
        printf("Missing arguments\n");
        exit(1);
    }
    
    uint start = uptime();
    int pid = fork();

    if (pid == 0){
        exec(arg[1], arg+1);
        printf("Child process executing\n");       
        exit(1);
        
    }
    else if (pid == -1){
        printf("Error: no child process created\n");
        exit(1);
    }

    int status;
    wait(&status);

    uint end = uptime();

    if(status == 0){
    printf("Time elapsed: %d ticks\n", end - start);
    }else{
        printf("Error: invalid arguments\n");
    }
    exit(0);
}