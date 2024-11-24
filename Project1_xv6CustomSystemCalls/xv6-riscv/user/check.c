#include "../kernel/types.h"
#include "user/user.h"
int main()
{
	printf("Replaced content of this child process through exec!!\n");
	printf("Hello World\n");
	return 0;
}
