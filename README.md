# progTester
 progTester je testovací skript pro ProgTest. Dá se ale využít i jinde.

## Použití
 `progtester.sh -s <source-code> [-t <testdata-dir>]`, kde `<source-code>` je zdrojový kód vašeho programu a `<testdata-dir>` složka s testovacími daty (defaultně se předpokládá jméno testdata). Testovací data musí být ve formátu `something_in.txt` `something_out.txt`, kde `something` by nemělo obsahovat substring `_in`.

## Doporučení
 Dobrým nápadem je přidat do PATH nějakou složku, kde si uděláte softlink na původní skript, který budete mít uložený v repozitáři, který si naklonujete.

## Přepínače
 | přepínač | dlouhá verze | význam |
 |---|---|---|
 | `-h` | `--help` | zobrazí help screen |
 | `-s <source-code>` | `--source <source-code>` | specifikuje zdrojový kód (povinný) |
 | `-t <testdata-dir>` | `--testdata <testdata-dir>` | specifikuje složku s testovacími daty (defaultně předpokládá jméno `testdata`) |
 | `-v` | `--verbose` | vypíše všechno (default) |
 | `-q` | `--quiet` | vypíše pouze errory/varování u kopilace a výsledek programu |
 | `-w <wrongouts-dir>` | `--wrongouts <wrongouts-dir>` | specifikuje složku, kam se uloží chybné výstupy programu (defaultně chybné výstupy neukládá) |
 | `-k <seconds>` | `--killafter <seconds>` | čas (ve vteřinách), po kterém se jednotlivý běh ukončí (defaultně 0, tj. běh není časově omezen) |
 | `-o <output>` | `--output <output>` | soubor, kam se má uložit zkompilovaný program (defaultně se neukládá) |
 | `-u` | `--unsorted-output` | výstupy mohou být v libovolném pořadí (defaultně vypnuto) |
 | `-c` | `--clock` | vypíše čas běhu programu pro jednotlivé vstupy (defaultně vypnuto) |

## Exit codes
 | exit code | význam |
 |---|---|
 | 0 | program proběhl úspěšně |
 | 1 | chyba při kompilaci |
 | 2 | výstup se neshoduje s referenčním nebo došlo k timeoutu |
 | 3 | zdrojový kód programu nebyl specifikovaný nebo neexistuje |
 | 4 | testovací data nejsou složka |
 | 5 | chybějící dependencies |
 | 6 | `-k` nedostal platné číslo |
 | 7 | neznámý přepínač |
