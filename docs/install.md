<img src="logo.png" width=100>

# Installation

<!-- tabs:start -->

### **Python**

#### Requirements
* Python 3.8+ on macOS and Linux (x86_64 and ARM64)

#### Installation
```bash
pip install chdb
```

#### Usage

| `python3 -m chdb [SQL] [OutputFormat]` 

```bash
python3 -m chdb "SELECT 1,'abc'" Pretty
```
Queries can return data using any [supported format](https://clickhouse.com/docs/en/interfaces/formats) as well as `Dataframe` and `Debug`


##### Eamples
The following methods are available to access on-disk and in-memory data formats

<!-- tabs:start -->

###### **🗂️ Parquet/CSV**

Use chdb to query any local or remote [file format](https://clickhouse.com/docs/en/interfaces/formats)

```python
# See more data type format in tests/format_output.py
res = chdb.query('select * from file("data.parquet", Parquet)', 'JSON'); print(res)
res = chdb.query('select * from file("data.csv", CSV)', 'CSV');  print(res)
print(f"SQL read {res.rows_read()} rows, {res.bytes_read()} bytes, elapsed {res.elapsed()} seconds")
```

##### **🗂️ Pandas DataFrame**

Use chdb to interact with the Pandas `Dataframe` format

```python
import chdb.dataframe as cdf
import pandas as pd
# Join 2 DataFrames
df1 = pd.DataFrame({'a': [1, 2, 3], 'b': ["one", "two", "three"]})
df2 = pd.DataFrame({'c': [1, 2, 3], 'd': ["①", "②", "③"]})
ret_tbl = cdf.query(sql="select * from __tbl1__ t1 join __tbl2__ t2 on t1.a = t2.c",
                  tbl1=df1, tbl2=df2)
print(ret_tbl)
# Query on the DataFrame Table
print(ret_tbl.query('select b, sum(a) from __table__ group by b'))
```

##### **🗂️ Stateful Sessions**

Use chdb stateful sessions to persist data between queries in temporary or dedicated folders

```python
from chdb import session as chs

## Create DB, Table, View in temp session, auto cleanup when session is deleted.
sess = chs.Session()
sess.query("CREATE DATABASE IF NOT EXISTS db_xxx ENGINE = Atomic")
sess.query("CREATE TABLE IF NOT EXISTS db_xxx.log_table_xxx (x String, y Int) ENGINE = Log;")
sess.query("INSERT INTO db_xxx.log_table_xxx VALUES ('a', 1), ('b', 3), ('c', 2), ('d', 5);")
sess.query(
    "CREATE VIEW db_xxx.view_xxx AS SELECT * FROM db_xxx.log_table_xxx LIMIT 4;"
)
print("Select from view:\n")
print(sess.query("SELECT * FROM db_xxx.view_xxx", "Pretty"))
```

##### **🗂️ Python DB-API 2.0**

Use chdb in your scripts through the Python DB-API 2.0

```python
import chdb.dbapi as dbapi
print("chdb driver version: {0}".format(dbapi.get_client_info()))

conn1 = dbapi.connect()
cur1 = conn1.cursor()
cur1.execute('select version()')
print("description: ", cur1.description)
print("data: ", cur1.fetchone())
cur1.close()
conn1.close()
```

##### **🗂️ UDF**

Easily implement and execute user defined functions in your chdb scripts and queries

```python
from chdb.udf import chdb_udf
from chdb import query

@chdb_udf(return_type="Int32")
def sum_udf(lhs, rhs):
    return int(lhs) + int(rhs)

print(query("select sum_udf(12,22)"))
```


##### Decorator for chDB Python UDF(User Defined Function)

1. The function should be stateless. So, only UDFs are supported, not UDAFs(User Defined Aggregation Function).
2. Default return type is String. If you want to change the return type, you can pass in the return type as an argument.
    The return type should be one of the following: https://clickhouse.com/docs/en/sql-reference/data-types
3. The function should take in arguments of type String. As the input is TabSeparated, all arguments are strings.
4. The function will be called for each line of input. Something like this:
    ```python
    def sum_udf(lhs, rhs):
        return int(lhs) + int(rhs)

    for line in sys.stdin:
        args = line.strip().split('\t')
        lhs = args[0]
        rhs = args[1]
        print(sum_udf(lhs, rhs))
        sys.stdout.flush()
    ```
5. The function should be pure python function. You SHOULD import all python modules used IN THE FUNCTION.
    ```python
    def func_use_json(arg):
        import json
        ...
    ```
6. Python interpertor used is the same as the one used to run the script. Get from `sys.executable`

##### **🗂️ Query Format**

You can execute SQL against any supported type and return any available [format](https://clickhouse.com/docs/en/interfaces/formats) _(Parquet, CSV, JSON, Arrow, ORC and 60+)_

```python
import chdb
res = chdb.query('select version()', 'Pretty');
print(res)
```

<!-- tabs:end -->

For more examples, see [https://github.com/chdb-io/chdb/tree/main/examples](examples) and [tests]([tests](https://github.com/chdb-io/chdb/tree/main/tests)).

<br>



### **NodeJS**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **Manual**
<!-- tabs:start -->
#### **AMD64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so
```
#### **ARM64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
unzip libchdb_arm64.zip
mv libchdb.so /usr/lib/libchdb.so
```
<!-- tabs:end -->
##### **DEB**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo apt install libchdb
```
##### **RPM**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo yum install -y libchdb
```
<!-- tabs:end -->


#### Installation
```bash
npm install node-chdb
```

#### Usage

<!-- tabs:start -->

##### **🗂️ Query Constructor**

You can leverage the power of chdb in your NodeJS applications by importing and using the `chdb-node` module

```javascript
const chdb = require("chdb-node");

// Query (ephemeral)
const db = new chdb.db("CSV") // format
var result = db.query("SELECT version()");
console.log(result) // 23.6.1.1

// Query Session (persistent)
const dbdisk = new chdb.db("CSV", "/tmp/mysession") // format, storage path
dbdisk.session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'");
var result = dbdisk.session("SELECT hello()", "TabSeparated"); // optional format override
console.log(result) // chDB
```

#####  **🗂️ Stateless Query**
Run stateless chdb queries using the `Execute` function with parameters _(query, format)_
```javascript
const chdb = require("chdb-node").chdb;
var result = chdb.Execute("SELECT version()", "CSV");
console.log(result) // 23.6.1.1
```

##### **🗂️ Stateful Sessions**
Run stateful chdb sessions using the `Session` function with parameters _(query, *format, *path)_
```javascript
const chdb = require("chdb-node").chdb;
chdb.Session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'")
var result =  = chdb.Session("SELECT hello();")
console.log(result) // chDB
```

> ⚠️ Sessions persist table data to disk. You can specify `path` to implement auto-cleanup strategies
> 
```javascript
const temperment = require("temperment");
const tmp = temperment.directory();
chdb.Session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'", "CSV", tmp)
var result =  = chdb.Session("SELECT hello();")
console.log(result) // chDB
tmp.cleanup.sync();
```
<!-- tabs:end -->

### **Go**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **Manual**
<!-- tabs:start -->
#### **AMD64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so
```
#### **ARM64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
unzip libchdb_arm64.zip
mv libchdb.so /usr/lib/libchdb.so
```
<!-- tabs:end -->
##### **DEB**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo apt install libchdb
```
##### **RPM**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo yum install -y libchdb
```
<!-- tabs:end -->

#### Installation
```bash
go get github.com/chdb-io/chdb-go/chdb
```

#### Usage
```go
package main

import (
    "fmt"
    "github.com/chdb-io/chdb-go/chdb"
)

func main() {
    // Stateless Query
    result := chdb.Query("SELECT version()", "CSV")
    fmt.Println(result)

    // Stateful Query (persistent)
    chdb.Session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'", "CSV", "/tmp")
    hello := chdb.Session("SELECT hello()", "CSV", "/tmp")
    fmt.Println(hello)
}
```

### **Rust**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **Manual**
<!-- tabs:start -->
#### **AMD64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so
```
#### **ARM64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
unzip libchdb_arm64.zip
mv libchdb.so /usr/lib/libchdb.so
```
<!-- tabs:end -->
##### **DEB**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo apt install libchdb
```
##### **RPM**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo yum install -y libchdb
```
<!-- tabs:end -->

#### Usage

This binding is a work in progress. Follow the instructions at [chdb-rust](https://github.com/chdb-io/chdb-rust) to get started.

### **Bun**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **Manual**
<!-- tabs:start -->
#### **AMD64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so
```
#### **ARM64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
unzip libchdb_arm64.zip
mv libchdb.so /usr/lib/libchdb.so
```
<!-- tabs:end -->
##### **DEB**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo apt install libchdb
```
##### **RPM**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo yum install -y libchdb
```
<!-- tabs:end -->

#### Installation
```bash
bun install chdb-bun
```

#### Usage
```javascript
import { Execute } from 'chdb-bun';
console.log(Execute("SELECT version()", "CSV"));
```

### **C/C++**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **Manual**
<!-- tabs:start -->
#### **AMD64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb.zip
unzip libchdb.zip
mv libchdb.so /usr/lib/libchdb.so
```
#### **ARM64**
```bash
wget https://github.com/metrico/libchdb/releases/latest/download/libchdb_arm64.zip
unzip libchdb_arm64.zip
mv libchdb.so /usr/lib/libchdb.so
```
<!-- tabs:end -->
##### **DEB**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo apt install libchdb
```
##### **RPM**
```bash
wget -q -O - https://github.com/metrico/metrico.github.io/raw/main/libchdb_installer.sh | sudo bash
sudo yum install -y libchdb
```
<!-- tabs:end -->

#### Usage

Follow the instructions for [libchdb](https://github.com/metrico/libchdb) to get started.

##### chdb.h
```c
#pragma once
#include <cstdint>
#include <stddef.h>

extern "C" {
struct local_result
{
    char * buf;
    size_t len;
    void * _vec; // std::vector<char> *, for freeing
    double elapsed;
    uint64_t rows_read;
    uint64_t bytes_read;
};

local_result * query_stable(int argc, char ** argv);
void free_result(local_result * result);
}
```

### **Custom**
#### Next Binding?
Bootstrapping a new **chdb binding**? Follow the instructions for [libchdb](https://github.com/metrico/libchdb) to get started.



<!-- tabs:end -->
