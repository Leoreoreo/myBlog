# db8 environment set-up
```
$ ssh student_machine
$ ssh db8.cse.nd.edu
$ cd /var/www/html/tutorial/lli27/
$ python3 -m venv venv
$ source ./venv/bin/activate
(venv) $ pip install --upgrade pip
(venv) $ pip install flask-mysqldb
(venv) $ mysql -p (pwd: 1r1sh)
```

# Model a Universe
## Entity Relation (ER) Diagrams
flowchart that illustrates how “entities” such as people, objects or concepts relate to each other within a system
- (designed on hand)
### Components
Take Amazon products as an example
- Entities
  - => products
  - => persons
  - => companies
- Relationships
  - **cardinality**
    - one-to-one
    - many-to-one
    - many-to-many
  - => relationships between entities
    - companies make products (one to many)
    - persons buy products (many to many)
    - companies employ persons (one to many)
- Attributes
  - => products have name, category, price, etc.
  - => persons have name, address, ssn, etc.
  - => **UPC**: the **key** to each product
    - note: key can be a group of attributes
- Constraints
  - => **UPC needs to be unique**
  - => relationships cardinality

#### Weak Entity Sets
Entity sets are weak when their key attributes come from other classes to which they are related. 

This happens in **“part-of”** relationships.

Weak entity sets:
1. must have a many-to-one relationship
2. referential integrity on the relationship
3. **supporting entity set** supplies the key to weak entity set
4. double box around weak entity set, double diamond around supporting relationship
5. weak entity set takes the key from the supporting relationship (weak entity set usually needs a key, but not always – sometimes in a connecting weak entity set where the key is made from lots of connecting entity sets, e.g., Contract connects Actor, Studio, Movie so contract doesn’t need a key)

## Relational Model
- relations

product: (table name)
| name    | price | category |
| -------- | ------- | ------- |
| A  | $250    | gadget |
| B | $80     | gadget |

tuples(rows)

### The Schema of a Relation
Relation name plus attribute names 
`E.g. Product(Name, Price, Category, Manufacturer)`

**Avoid Changing Schema** because this requires the db to shut down.

## SQL

### create table

column types
- `char(bytes)`: sizes of column data are consistant
- `varchar(max_bytes)`: sizes of column data vary greatly
- `date`: long (8 bytes)

```sql
create table person(
  ssn         char(9)     primary key,
  first_name  varchar(50) not null,
  last_name   varchar(50) not null,
  dob         date,
  networth    char(10)
);
```
view table description
```sql
desc products;
```

### update
```sql
insert into persons values (...)
```
view
```sql
select * from persons
```

#### size of a row:

| ssn    | first_name | last_name | dob | networth |
| -------- | ------- | ------- | ------- | ------- |
| 012345678  | Tim | Weninger | NULL | 25543251 |

size: 9 + (1+3) + (1+8) + 8 + 10 = 40
- `varchar` takes an additional byte on the front indicating its length
  - so maxlen(varchar) = 255
  - **painful to update varchar**
  

## Translate from ER to Relational Model
1. every entity set is a relation
2. every relationship is a relation
3. merge relationship into many-side of **many-to-one relation**
4. merge relationship into any-side of **one-to-one relation**

ER diagram:
```
entity: products (attributes: name, category, price)
          |
        make (attributes: year)
          |
          v
entity: companies (attributes: name, stock)
```

Relational Model:
```
Products(*name, category, price)
Companies (*name, stock)
Makes (*product_name, *company_name, year)
```
can **merge makes** (b/c many-to-one relation)
```
Products(*name, category, price, company_name_fk, year)
Companies (*name, stock)
```
**cannot merge in many-to-many relation** b/c of **Redundancy**

### Weak Entity Set
```
entity:       University (attr: *name)
                  |1
                  affiliation (weak relation)
                  |
weak entity:  Team (attr: *sport, attendance)
```

```
University(*name)
Team (*university_name, sport(partial key: dot underline), attendances)
```

### Subclasses
```
entity: music_players (attr: *name, manf)
          |
        is a
          |
entity: ipods (attr: color)
```

E/R model
```
music_players(*name, manf)
ipods (*name, color)
```

OO model
```
music_players(*name, manf)
ipods (*name, color, manf)
```

## Better Database Design

### Normal Forms

There are several important normal forms: 1NF, 2NF, 3NF, BCNF, 4NF etc.

If `R*` is in one of these forms, then `R*` is guaranteed to achieve certain good properties, 

e.g., if `R*` is in Boyce Codd NF then it is guaranteed to not have certain type of redundancy.

There exist algorithms to transform `R` into `R*`, where `R*` is in one of the normal forms.

Each type of normal form is different, there are trade offs. NFs are all based on the idea of functional dependencies.

### Functional Dependencies
#### Definition:
If two tuples agree on the attributes `a1,a2,...,an`, then they must also agree on the attributes `b1,b2,...,bm`.

Formally: `a1,a2,...an -> b1,b2,...,bm`, pronounced `X` determines `Y`.

#### Closure of FD Sets

Armstrongs Axioms
1. Reflexivity
   - X &rarr; subset of X
2. Augmentation
   - X &rarr; Y 
   - => XZ &rarr; YZ
3. Transitivity
   - X &rarr; Y, Y &rarr; Z 
   - => X &rarr; Z
4. Union
   - X &rarr; Y, Y &rarr; Z 
   - => X &rarr; YZ
5. Decomposition
   - X &rarr; YZ
   - => X &rarr; Y, X &rarr; Z
6. Pseudo-Transitivity
   - X &rarr; Y, YZ &rarr; U
   - => XZ &rarr; U

### Keys
#### key
Key of a relation `R` is a set of attributes that:
- Functionally determines all attributes of `R`.
- None of its subsets determines all attributes of `R`.
#### Superkey
A set of attributes that contains a key.
#### Candidate Key
Minimal superkey. 


### Normal Forms
Determines whether the schema is good.
- no anomalies (BCNF)
- perserve dependencies (3NF)
- query performance


#### 1NF
All attributes must be atomic. (No lists of things in a cell.)

#### 2NF
No partial dependencies. 
- Prime attributes: attributes in a candidate key.
- Non-prime attributes: attributes not in a candidate key
- Partial dependency: a non-prime attribute depends on **part of** a candidate key (part_ck -> n_p)
```
i.e.: {ab->c, b->d}
ab->c : Non-Partial dependency
b->d  : Partial dependency (FAIL)
```

solution: Decomposition
- for dependencies X&rarr;Y that violates:
  - create R(X, Y)
- Then create R(X, all other entities)
```
i.e.: {ab->c, b->d}
R1(abc) S1 = {ab->c}
R2(bd)  S2 = {b->d}
```

#### 3NF
In 2NF and 
"for all FD X&rarr;Y: X is SK or Y is prime"

#### BCNF
Boyce and Codd’s Normal Form

"for all FD X&rarr;Y: X is SK"
- ensures no anomalics
- doesn't perserve dependencies

# Query

## Relational Algebra

- operators: union, set_difference, selection, projection, cartesian_product
- operands: relations

R: 
| a | b |
|---|---|
| 1 | 4 |
| 3 | 6 |

S: 
| x | y |
|---|---|
| 1 | 4 |
| 5 | 7 |

- R `theta join` S
  - = select from RXS where theta
- R `Equi join` S
  - = select from RXS where R_attrA = S_attrB
  - a kind of `theta join`
- R `Natural join` S
  - = select from RXS where R_attr = S_attr
  - `Equi join` on the same name(s) of columns

- {a, a, b, c, c} `intersect` {a, a, c, d}
  - = {a, a, c}
- {a, a, b, c, c} `substract` {a, a, c, d}
  - = {b, c}


## [Relational Calculus](https://timweninger.com/teaching/database-systems-concepts/relational-calculus/)

## SQL (Structural English Query Language)
```sql
SELECT  attr1, attr2  as ...
FROM    relation      as ...
WHERE   condition
;
```
note: can do partial match
- `WHERE prod_desc like 'sweater%'` => `sweater024, sweater12fdg3, ...`
- `WHERE prod_desc like 'sweater_'` => `sweatere, sweater1, ...`

note: can do `(select * from ... ) S` as a relation

```sql
SELECT  salpers_name
FROM    salesperson as S, (
  SELECT  comm 
  FROM    salesperson 
  WHERE   salpers_name 
  LIKE    'Goro%'
) C 
WHERE   S.comm = C.comm;
```
```sql
SELECT  *
FROM    sale, customer, (
  SELECT  prod_id
  FROM    product.manufacturer
  WHERE   manufacturer.country = 'Nigeria' 
    AND   product_manufacturer_id = manufactr_id
) N
WHERE   sale.cust_id = customer.cust_id 
  AND   sale.prod_id = N.prod_id 
  AND   customer.country = 'Chile';
```

### IN (intersact) operation
```sql
SELECT  *
FROM    sale
WHERE   salpers_id
IN      (
  SELECT  salpers_id
  FROM    salesperson
  WHERE   office = 'Chicago'
);
```

### EXISTS operation
```sql
SELECT  salpers_name
FROM    Salesperson S1
WHERE EXISTS (
  SELECT  *
  FROM    sale S
  WHERE   S.salpers_id = S1.salpers_id
);
```

### ANY and ALL
x >= ANY(R): x >= one or more of the of tuples in R

x >= ALL(R): x >= all of the of tuples in R

```sql
SELECT  prod_desc
FROM    Product
WHERE   price >= ALL(
  SELECT  price
  FROM    Product
);
```

```sql
SELECT  salpers_id
FROM    salesperson
WHERE   office = 'Chicago'
  AND   salpers_id in (
  SELECT  salpers_id
  FROM    sale, Product
  WHERE   sale.prod_id = product.prod_id
    AND   prod_desc = 'Table Lamp'
);
```

### UNION and UNION ALL

### Functions

- sum()
- count()
- avg()
- stdev()
- min()
- max()

number of manager
```sql
SELECT  COUNT(DISTINCT manager_id)
FROM    salesperson
WHERE   manager_id IS NOT null;
```

### GROUP BY and HAVING
```sql
SELECT  a, COUNT(a)
FROM    R
WHERE   ...
GROUP BY  a;
```
**the grouped by column(s) and func(col) must appear in select**

average `comm` per `office`
```sql
SELECT  office, avg(comm)
FROM    salesperson
GROUP BY  office;
```

gross revenue for each product
```sql
SELECT  product.prod_id, sum(qty*price)
FROM    product, sale
WHERE   product.prod_id = sale.prod_id
GROUP BY  prod_desc;
```

total revenue of offices that made at least 3 sales
```sql
SELECT  office, sum(price*qty)
FROM    sale, salesperson, product
WHERE   sale.salpers_id = salesperson.salpers_id AND sale.prod_id = product.prod_id
GROUP BY  office_id
HAVING    count(*) >= 3;
```

top 2 salespersons making the most sales
```sql
SELECT  salesperson.name, count(*) AS cnt
FROM    sale, salesperson
WHERE   sale.salpers_id = salesperson.salpers_id
GROUP BY  salesperson.salpers_id
ORDER BY  cnt DESC
LIMIT 2
```

### Insertion, Update, Delete

```sql
INSERT INTO table1(col1, col2, ...)
VALUES  (val1, val2, ...);
```

```sql
DELETE FROM table1
WHERE  ...;
```

```sql
UPDATE table1
SET   a = x
WHERE  ...;
```

### Load data

```sql
LOAD DATA ...
LOCAL ...
```

### Views
virtual tables that basically store queries
```sql
CREATE VIEW name AS query
```
- does not create a table


### Joins

1. outa join
```sql
R1 OUTA JOIN R2
ON R1.B = R2.B
```
   1. left outa join
      - only keep rows on the left
   2. right outa join
      - only keep rows on the left

### References
```sql
FOREIGN KEY ( <list of attributes> )
REFERENCES <relation> ( <attributes> )
```


# Memory

## Memory Hierarchy

### volatile
Dissapates as power goes off
- cache (2-10 MB)
- main memory (4-16 GB)
### nonvolatile
- Disk, File System, Programs (200 GB -)
- Tertiary Storage

## HDD (Hard Disk Drives)
- cheap, large storage

## Data on Disk
```sql
-- Pointer to the record schema:  8 bytes
-- length of record:              8 bytes
-- timestamp of record creation:  8 bytes 
create table customer (
 	cust_id INTEGER PRIMARY KEY, -- 4
 	cust_name CHAR(25), -- 25
 	city CHAR(25),      -- 25
 	country CHAR(25),   -- 25
 	beg_bal INTEGER,    -- 4
 	cur_bal INTEGER     -- 4
); -- TOTAL: 111 bytes
```
each sector (4KB) stores `4096 // 111 = 36` rows
- min number of sectors required for 10,000 rows: `roundup(10,000 // 36) = 278`


```sql
-- header: 24
create table customer (
 	cust_id INTEGER PRIMARY KEY, -- 4
 	cust_name VARCHAR(25),  -- 1 + avglen * (1 for ascii, 3 for utf)
 	city VARCHAR(25),       -- 1 + avglen
 	country VARCHAR(25),    -- 1 + avglen
 	beg_bal INTEGER,        -- 4
 	cur_bal INTEGER         -- 4
); -- TOTAL: ... bytes
```

# Indexing

## Types

### clustered / unclustered
- clustered: records sorted in key order
- unclustered: not sorted

### dense / sparse
- dense: each record has an entry in the index
- sparse: only some records have entries


\ | dense | sparse |
----- | ----- | ------
**clustered** | unnecessary pointers | default primary key
**unclustered** | non-pk indices | not possible


## B+ Trees
### Sargablilty (search argument ability)
1. Query:
- sargable: 
  - `where pk like 'Tim%'`
  - `where ssn > 10`
- nonsargable: 
  - `where pk like '%othy'`
  - `where ssn != 10`
1. data structure:
- sargable: B Tree
- nonsargable: Hashtable

### B- Tree
- root is loaded in memory
- each node is stored in a block/sector
- only leaf nodes point to records
- doesn't work for **sparse** data

### B+ Tree
- `d`: degree
- each node has `[d, 2d]` keys (except root)
  - => each node takes space `(2d+1) * sizeof(ptr) + 2d * sizeof(int)`
  - => max d: 133

## Hashtable
`h(pk) = disk_block_idx`
- each `disk_block_idx` points to a disk sector (stores multiple pointers)
  - if the disk sector is full (overflow occurs)
    - => points to another sector (linked list)
  - solution: **(linearly) Extensible Hashtable**
    - when a overflow occurs, extend the hashtable

## Query Efficiency
### Search by index
- if index consists two parts:
  - searching the second pard only doesn't help

# Query Execution
## logical / physical operators
1. logical (what they do):
   - union, selection, project, join, grouping
2. physical (how they do it):
   - nested loop join, sort-merge join, hash join, index join

## Query Execution Plans
Create a Query Plan:
- logical tree
- implementation (choice at every node)
- scheduling of operations.

* Some operators are from relational algebra, and others (e.g., scan, group) are not.
## Cost
### parameters 
- M = number of blocks that fit in main memory
- B(R) = number of blocks holding R
- T(R) = number of tuples in R
- V(R,a) = number of distinct values of the attribute a
### clustered / unclustered
- The table is clustered (I.e. blocks consists only of records from this table):
- The table is unclustered (e.g. its records are placed on blocks with other tables)
### Sorting
Two pass multi-way merge sort
1. Step 1:
   - Read M blocks at a time, sort, write
   - Result: have runs of length M on disk
2. Step 2:
   - Merge M-1 at a time, write to disk
   - Result: have runs of length M(M-1)»M2
- Cost: 3B(R),  Assumption: B(R) < M2
### Scanning Tables
1. clustered
- Table-scan: if we know where the blocks are
- Index scan: if we have index to find the blocks
- Table scan:  B(R); to sort: 3B(R)
- Index scan:  B(R); to sort: B(R) or 3B(R)

2. unclustered
- May need one read for each record
- T(R); to sort: T(R) + 2B(R)


### example:
- Given B(R) = 2000, T(R) = 100,000, V(R, a) = 20, and R is un-clustered: compute the cost of 𝜎a=v(R):
- unclustered => 100,000 / 20 = 5000

# Transaction
## ACID Properties
- Atomicity
  - either happens completely or not at all
- Consistency Preservation
  - must result in a consistent DB (meets certain constraints)
- Isolation
  - cannot affect another users transaction
- Durability
  - can’t ever lose data
## Serial Schedule
1. Serial 
  - means first do all of 1 txn and then all of the other
2. Serializable
  - means the final effect is the same as serial.

## Transaction Logging

### UNDO log
1. input(A): load from disk to memory
  - log: start transaction `<start l>`
2. r1(A, t), t = t*2, W1(A, t): write t=t*2 into memory
  - log: save old value (8) `<T1, A, 8>`
3. output(A): flush from memory to disk
  - log: **after** output, `<commit T1>`

* if transaction aborted, undo the log (re-write disk with old values in log)

### Checkpointing
the database periodically
- Stop accepting new transactions
- Wait until all current transactions complete
- Flush log to disk
- Write a <CKPT> log record, flush
- Resume transactions

### REDO log
1. input(A): load from disk to memory
  - log: start transaction `<start l>`
2. r1(A, t), t = t*2, W1(A, t): write t=t*2 into memory
  - log: save **NEW** value (16) `<T1, A, 16>`
3. output(A): flush from memory to disk
  - log: **before** output, `<commit T1>`

### UNDO/REDO log
1. input(A): load from disk to memory
  - log: start transaction `<start l>`
2. r1(A, t), t = t*2, W1(A, t): write t=t*2 into memory
  - log: save **OLD & NEW** value (16) `<T1, A, 8, 16>`
3. output(A): flush from memory to disk
  - log: **doesn't matter** output, `<commit T1>`

# HDFS (Hadoop Distributed Filesystem)
## components:
- Namenode(s)
  - stores where the datas are
- Datanodes
  - each stores block of file (default 64mb)
  - blocks are replicated across datanodes
    - can set `replication = n`
    - ensure replication on different racks: `rack aware = ON`
    - ensure replication on different datacenters: `datacenter aware = ON`

## MapReduce
- Namenode sends (**maps**) SQL to all datanodes
- Datanodes than each performs the SQL and send result to namenode
- Namenode performs **shuffle and sort** (aggregrate values by keys)
- then the result is **reduced** (performs some aggregation option)


## CAP Theorem
trade-off (can only choose two) between 
- Consistency
- Availablilty
- Partionability

### example:
1. Availablilty + Consistency
   - MySQL
   - Postgres
2. Consistency + Partionability
   - Bigtable
   - MongoDB
   - HBase
3. Availablilty + Partionability
   - Cassandra
   - Dynemo
   - Voldemort
  
## HBase
- NoSQL (not only SQL)
### Column-Oriented Database
- Columns in HBase are grouped into column families
- Each **column family** can have multiple rows that are stored together on disk 
  - column family contains columns of similar entropies
  - optimized for compression and storage

## Spark
More efficient than MR
- keeps data in memory instead of storing data in disk each step
- (only read from disk once, write none)

```
$> hdfs namenode
$> source ./venv/bin/activate

(venv) $>python3
```
- use pyspark
```py
from pyspark.sql import SparkSession, SQLContext
from pyspark import SparkConf, SparkContext
spark = SparkSession.builder.getOrCreate()
```
- Open htop
- Open http://db.cse.nd.edu:4040/
```py
df = spark.read.json("hdfs://db8.cse.nd.edu:9000/reddit/RC_2010-11.bz2")
df.createTempView("comments")
df.printSchema()
df.show()
```
```py
spark.sql('select count(*) from comments').collect()
spark.sql('select * from comments order by score desc limit 2').head()
spark.sql('select * from comments order by score desc').head(5)
```

```php
$uname = $_POST['username'];
$passwd = $_POST['password'];

$sql = “SELECT id FROM users WHERE username='" . $uname . "' AND password='" . $passwd . "'";

$result = mysql_query($db, $sql)
```


# Object Relational Mapping
```
DB <-> MySQL/Postgres <-> SQL <-> ORM <-> Code (Flask)
```
- maps code to DB table
```py
cust = Customer()
cust.custid = 4
cust.cust_name = 'TIM'
cust.save()
```
```sql
insert into customer values (4, 'Tim');
```