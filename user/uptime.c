#include "../kernel/types.h"
#include "user.h"


int main(){
    
    int ticks = uptime();
    printf("%d clock ticks\n",ticks);
    exit(0);

}
