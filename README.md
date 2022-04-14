# progTester
| :exclamation:  This project is now discontinued and no further updates will be issued.   |
|------------------------------------------------------------------------------------------|

progTester is a C/C++ test script developed mainly for ProgTest (FIT CTU).

## Usage
`progtester.sh -s <source-code> [-t <testdata-dir>]`, where `<source-code>` is the source code and `<testdata-dir>` is the directory containing test data (the name `testdata` is assumed by default).
Test data must be in the format of `SOMETHING_in.txt` `SOMETHING_out.txt`, where `SOMETHING` is the same between the in and out files. See [Flags](#flags) for more options or [EXAMPLE.md](https://github.com/ProkopHanzl/progTester/blob/master/example/EXAMPLE.md) for example usage.

## Setup recommendation
Clone this repository to a directory on your computer. Add a folder to your PATH and make a link to `progtester.sh` in it (and call it `progtester`).

## Changing default settings
You can change defaults for most flags. Save `progtester.config` into a directory called `.progtester` in your home directory and follow the instructions in it.

## Flags
| flag | name | meaning |
|---|---|---|
| `-h` | `help` | display help screen |
| `-s <source-code>` | `source` | specify source code (required) |
| `-t <testdata-dir>` | `testdata` | specify test data directory (`testdata` assumed by default) |
| `-v` | `verbose` | print all output (default) |
| `-q` | `quiet` | suppress all output except compilation errors/warnings and script output |
| `-w <wrongouts-dir>` | `wrongouts` | specify directory to save wrong output data in (none by default) |
| `-k <seconds>` | `kill-after` | time (in seconds) after which each run will be killed (off by default) |
| `-o <output>` | `output` | where the compiled binary should be saved (discarded by default) |
| `-u` | `unsorted-output` | output lines can be in any order (off by default) |
| `-c` | `clock` | list runtimes for each input (off by default) |

## Exit codes
| exit code | meaning |
|---|---|
| 0 | sucessful run (or help/usage called) |
| 1 | error compiling |
| 2 | wrong output(s) and/or timeout(s) |
| 3 | source code wasn't specified or doesn't exist |
| 4 | test data is not a directory |
| 5 | missing dependencies |
| 6 | `-k` received invalid number |
| 7 | unknown flag used |

## Contribute
Do you enjoy progTester and know bash? Help by contributing! Feel free to submit pull requests with new features you create, or work on one of the [issues](https://github.com/ProkopHanzl/progTester/issues).

## Acknowledgements
[Vidar Holen](https://github.com/koalaman) for [shellcheck](https://shellcheck.net), a great tool that helps me immensely when developing the script.

[Jakub Charvat](https://github.com/jakcharvat) for the initial idea of a [more featured test script for ProgTest](https://gist.github.com/jakcharvat/c8ab918d3927361ae6d5d977587752d2).
