
# Example
I have written a short program that lists all integers between two numbers and I would like to test it.

## Code
The program takes two integers as input and prints all numbers between them (in ascending order), both boundaries included. If fewer than 2 integers are provided or the first one is larger than the second one, the input is invalid.

The code looks like this:
```c
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
```

## Test Data
Being too lazy to do it myself, I tasked my 7-year-old cousin Timmy with creating test data for my program in exchange for a lollipop. Being a child, Timmy made my test data in descending order, like this:
### `0000_in.txt`
```
10 20
```
### `0000_out.txt`
```
Input range in the format FROM TO:
20
19
18
17
16
15
14
13
12
11
10
```

However, my code prints them in ascending order:
```
Input range in the format FROM TO:
10
11
12
13
14
15
16
17
18
19
20
```
And on top of that, he named the test data directory `i_like_lollipops`.

## Testing
As I surely need not remind you, my laziness knows no bounds. Therefore, I am not willing to change my test data in any way or rename my test data directory. This is where progTester comes in handy. I am going to call the following command:
```bash
$ progtester -s list_numbers.c -t i_like_lollipops -w no_lollipops_for_timmy -cu
```
I use `-s` to specify the location of my source code, `-t` to specify my test data directory, and `-w` to specify a directory to save wrong output data in, in case some inputs yield unsuccessful runs.

I also toggle `-c`, as I am interested in the runtime for each input. And, very importantly, I run the command with `-u`, telling it that the output lines can be in any order, solving my problem with Timmy's test data in descending order. The output will look something like this:
```
$ progtester -s list_numbers.c -t i_like_lollipops -w no_lollipops_for_timmy -cu
  Compiling using g++-11...
  Testing...
  OK: i_like_lollipops/0000_in.txt
      > time elapsed: 0.091s
  OK: i_like_lollipops/0001_in.txt
      > time elapsed: 0.010s
  OK: i_like_lollipops/0002_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0003_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0004_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0005_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0006_in.txt
      > time elapsed: 0.009s
  7/7 (7 successes and 0 failures)
```
Consider the following command, omitting the `-u` flag:
```bash
$ progtester -s list_numbers.c -t i_like_lollipops -w no_lollipops_for_timmy -c
```
Output:
```
$ progtester -s list_numbers.c -t i_like_lollipops -w no_lollipops_for_timmy -c
  Compiling using g++-11...
  Testing...
  FAIL: i_like_lollipops/0000_in.txt
      > see no_lollipops_for_timmy/0000_out.txt
      > time elapsed: 0.079s
  FAIL: i_like_lollipops/0001_in.txt
      > see no_lollipops_for_timmy/0001_out.txt
      > time elapsed: 0.009s
  FAIL: i_like_lollipops/0002_in.txt
      > see no_lollipops_for_timmy/0002_out.txt
      > time elapsed: 0.009s
  OK: i_like_lollipops/0003_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0004_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0005_in.txt
      > time elapsed: 0.008s
  OK: i_like_lollipops/0006_in.txt
      > time elapsed: 0.008s
  4/7 (4 successes and 3 failures)
```
Further usage instructions can be found [here](https://github.com/ProkopHanzl/progTester#Usage).
