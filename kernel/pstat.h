
struct rusage{
    uint cputime;
};

struct pstat{

    int priority;
    int pid;
    enum procstate state;
    uint64 size;
    int ppid;
    char name[16];
    uint readytime;
    uint cputime;



};