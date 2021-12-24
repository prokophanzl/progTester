# progTester
 progTester je testovací skript pro ProgTest. Dá se ale využít i jinde.

## Použití
 `progtester.sh <source-code> <testdata-dir>`, kde `<source-code>` je zdrojový kód vašeho programu a `<testdata-dir>` složka s testovacími daty. Ta musí být ve formátu `xxxx_in.txt` `xxxx_out.txt`, kde `xxxx` je čtyřciferné číslo od 0000.

## Doporučení
 Dobrým nápadem je přidat do PATH nějakou složku, kde si uděláte softlink na původní skript, který budete mít uložený v repozitáři, který si naklonujete.

## Exit codes
 | exit code | význam |
 |---|---|
 | 0 | program proběhl úspěšně |
 | 1 | chyba při kompilaci |
 | 2 | výstup se neshoduje s referenčním |
 | 3 | zdrojový kód programu nebyl specifikovaný nebo neexistuje |
 | 4 | testovací data nejsou složka |
