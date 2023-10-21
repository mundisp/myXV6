#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"
#include "kernel/pstat.h"

int
main(int argCount, char **arg){
    if(argCount < 2){
        printf("Missing arguments\n");
        exit(1);

    }
    uint start = uptime();
    int pid = fork();

    if (pid == 0){
        exec(arg[1], arg + 1);
        printf("Executing child process\n");
        exit(1);

    }
    else if (pid == -1){
        printf("ERROR: no process created\n");
        exit(1);

    }

    struct rusage ru;
    int wait_pid = wait2(0, &ru);
    uint end = uptime();

    if(wait_pid < 0){
        printf("Child process didn't return\n");
        exit(1);
    }
    fprintf(1,"elapsed time: %d ticks, cpu time: %d ticks, %d%% CPU\n", end - start, ru.cputime,
     (ru.cputime * 100) / (end - start));

     exit(0);


}