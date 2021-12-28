#include <stdio.h>

int main(void) {
	int from, to;

	printf("Input range in the format FROM TO:\n");

	if (scanf("%d %d", &from, &to) != 2 || from > to) {
		printf("Invalid input.\n");
		return 1;
	}

	for (int i = from; i <= to; ++i) {
		printf("%d\n", i);
	}

	return 0;
}
