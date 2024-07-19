## Database 

### Create Database

```sql
CREATE DATABASE [db_name];

```
```sql
USE [db_name];
```

## Table 

### Create Table
```sql
CREATE TABLE [table_name] (
    [column01] INT AUTO_INCREMENT PRIMARY KEY,
    [column02] VARCHAR([string_len]) NOT NULL,
    [column03] DATE NULL 
);
```

### Insert

```sql
INSERT INTO [db_name].[table_name] ([column01], [column02], [column03])
VALUES ([val_1], [val_2], [val_3]);
/* ([column01], [column02], [column03]) are optional */
```
- `INT` format: `3`
- `VARCHAR` format: `'a string'`
- `DATE` format: `'2020-01-01'`
- `AUTO_INCREMENT`: `DEFAULT` 

### Add Columns
```sql
ALTER TABLE [db_name].[table_name]
ADD [new_column_name] [type];
```
### Update Value
```sql
UPDATE [db_name].[table_name]
SET [target_column_name] = [new_value]
WHERE [id_column] = [target_id];
```
### Delete Row
```sql
DELETE FROM [db_name].[table_name]
WHERE [id_column] = [target_id]; 
```
### Delete Database & Table
```sql
DROP DATABASE [db_name];
```
```sql
DROP TABLE [db_name].[table_name];
```

### View Data
```sql
USE [db_name];
```
```sql
-- view the entire table
SELECT * FROM [table_name];
-- view certain column values
SELECT [column_1], [column_2], [column_3] FROM [table_name];
-- view all different values of a column
SELECT DISTINCT [target_column] FROM [table_name];
-- view in sorted order
SELECT * 
FROM [table_name] 
WHERE [condition]
ORDER BY [target_column] /* ASC(default) DESC */;
```

#### Operators
```
AND, OR, NOT / !
```
```
equal       =
unequal     !=, <>
compare     >, <, >=, <=
between     BETWEEN [start_val] AND [end_val] 
in          IN ([val1], [val2], ...)
like        LIKE [regex ('%' for '$', '_' for '.')]
```

### Join tables

#### Intersect
```sql
SELECT *
FROM [table_1]
INNER JOIN [table_2]
ON [table_1].[shared_column] = [table_2].[shared_column]; 
```
#### Union
```sql
SELECT [shared_column1], ...
FROM [table_1]
UNION   /* Unique. add 'ALL' to allow repetition */
SELECT [shared_column1], ...
FROM [table_2];
```
#### Left Join & Right Join
- Left Join: keep all values of the left, add values of the right that meet requirements
- Right Join: vice versa
```sql
SELECT *
FROM [table_1]
LEFT JOIN [table_2] /* RIGHT JOIN [table_2] */
ON [table_1].[shared_column] = [table_2].[shared_column];
```

### Brief
```sql
SELECT ...
FROM [table_1] AS [brief_1] /* can use [brief_1] instead of [table_1] */
...
```


