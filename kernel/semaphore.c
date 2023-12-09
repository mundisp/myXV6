#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "spinlock.h"
#define NSEM 100

struct semtab semtable;

void seminit(void){
    initlock(&semtable.lock, "semtable");
    for (int i = 0; i < NSEM; i++)
    initlock(&semtable.sem[i].lock, "sem");
    };

int semalloc(void){
    acquire(&semtable.lock);
    for (int i = 0; i < NSEM; i++){
        if(!semtable.sem[i].valid){
            semtable.sem[i].valid = 1;
            release(&semtable.lock);
            return i;
        }
    }
    release(&semtable.lock);
    return -1;
}

void sedealloc(int index){
    acquire(&semtable.sem[index].lock);
    if(index >= 0 && index < NSEM){
        semtable.sem[index].valid = 0;
    }
    release(&semtable.sem[index].lock);
}
