@echo on
chcp 60001 >nul

rem поскольку forfiles не работает с сетевыми путями приходится 
rem делать костыль ввиде ссылки на сетевой ресурс. mklink 
rem нужно для автоочистки сетевого ресурса (под forfiles), сейчас сделал костыль на PS 
rem так же 7-zip и postgres не дружат с переменными cmd. поэтому такой вырвиглаз 
rem добавил возможност забора кластера целиком

mklink /d "d:\Public" "\\192.168.1.9\Public"

MD "d:\Public\backup_db\georgievskiy\%date:~-10%"

rem set backup_1c=\\192.168.1.9\Public\BackUp1c\Alco
rem set backup_psql=\\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%
rem set 7-zip=C:\Program Files (x86)\7-Zip

"C:\Program Files (x86)\7-Zip\7z.exe" a -tzip "\\192.168.1.9\Public\BackUp1c\Alco\Base1c-%date%.zip" -mx3 "D:\Trade\1Cv8.1CD" -r -ssw>\\192.168.1.9\Public\BackUp1c\Alco\log-%date%.txt
"C:\Program Files (x86)\7-Zip\7z.exe" a -tzip "\\192.168.1.9\Public\BackUp1c\Garchu\Base1c-%date%.zip" -mx3 "\\192.168.1.10\Trade\1Cv8.1CD" -r -ssw>\\192.168.1.9\Public\BackUp1c\Garchu\log-%date%.txt

"C:\Program Files (x86)\7-Zip\7z.exe" a -tzip "d:\Public\backup_db\georgievskiy\%date:~-10%\cluster.zip" -mx3 "c:\Program Files\PostgreSQL\9.4\data\*.*" -r -ssw
SET PGPASSWORD=postgres

"%set_postgres_bin%\pg_dumpall.exe" -U postgres > %backup_psql%\backup_all.txt
"%set_postgres_bin%\pg_dump.exe" -U postgres -Fc -b set > \\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%\backup_set.sql
"%set_postgres_bin%\pg_dump.exe" -U postgres -Fc -b set_loyal >\\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%\backup_set_loyal.sql
"%set_postgres_bin%\pg_dump.exe" -U postgres -Fc -b set_operday > \\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%\backup_set_operday.sql

"%set_postgres_bin%/pg_dump.exe" -U postgres -Fc -a -b set > z:/backup_db/georgievskiy/%date:~-10%/data_backup_set.sql
"%set_postgres_bin%/pg_dump.exe" -U postgres -Fc -a -b set_loyal >z:/backup_db/georgievskiy/%date:~-10%/data_backup_set_loyal.sql
"%set_postgres_bin%/pg_dump.exe" -U postgres -Fc -a -b set_operday > z:/backup_db/georgievskiy/%date:~-10%/data_backup_set_operday.sql



"C:\Program Files (x86)\7-Zip\7z.exe" a -tzip "\\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%\BaseSQL-%date%.zip" -mx3 "\\192.168.1.9\Public\backup_db\georgievskiy\%date:~-10%\*.sql" -r -ssw>\\192.168.1.9\Public\BackUp1c\Alco\log-%date%.txt

rem автоочистка файлов старше 20 и 45 дней. с последующей очисткой ненужных файлов. 
rem с помощью gci фильтруем файлы - после чего устанавливаем счетчик дат - удаляем 
powershell.exe gci "d:\public\backup_db\georgievskiy\" -Filter "*" -Recurse | ? LastWriteTime -LT (Get-Date).AddDays(-20) | remove-item -Recurse
powershell.exe gci "d:\Public\BackUp1c\Alco" -Filter "*" -Recurse | ? LastWriteTime -LT (Get-Date).AddDays(-45) | remove-item

powershell.exe gci "d:\public\backup_db\georgievskiy\%date:~-10%\" -Filter *.sql -Recurse | remove-item

exit