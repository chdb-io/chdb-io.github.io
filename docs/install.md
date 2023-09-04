<img src="logo.png" width=100>

# Installation

<!-- tabs:start -->

### **Python**

#### Installation
```bash
pip install chdb
```

#### Usage

##### Run in command line

| `python3 -m chdb [SQL] [OutputFormat]` 

```bash
python3 -m chdb "SELECT 1,'abc'" Pretty
```

You can use any [format](https://clickhouse.com/docs/en/interfaces/formats) supported by ClickHouse


##### Run in Python

```python
chdb.query('select * from file("data.parquet", Parquet)', 'Dataframe')
```
Queries can return data using any supported [clickhouse format](https://clickhouse.com/docs/en/interfaces/formats) as well as `Dataframe` format


##### Data Input
The following methods are available to access on-disk and in-memory data formats:

##### 🗂️ Query on Files _(Parquet, CSV, JSON, Arrow, ORC and 60+)_

You can execute SQL against any supported type and return desired format.

```python
import chdb
res = chdb.query('select version()', 'Pretty'); print(res)
```

###### 🗂️ Work with Parquet or CSV
```python
# See more data type format in tests/format_output.py
res = chdb.query('select * from file("data.parquet", Parquet)', 'JSON'); print(res)
res = chdb.query('select * from file("data.csv", CSV)', 'CSV');  print(res)
print(f"SQL read {res.rows_read()} rows, {res.bytes_read()} bytes, elapsed {res.elapsed()} seconds")
```

##### 🗂️ Query On Pandas DataFrame
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

##### 🗂️ Query with Stateful Session<
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

##### 🗂️ Query with Python DB-API 2.0

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

##### 🗂️ Query with UDF (User Defined Functions)

```python
from chdb.udf import chdb_udf
from chdb import query

@chdb_udf()
def sum_udf(lhs, rhs):
    return int(lhs) + int(rhs)

print(query("select sum_udf(12,22)"))
```

For more examples, see [examples](examples) and [tests](tests).

<br>



### **NodeJS**

#### Requuirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **DEB**
```bash
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.deb.sh | os=any dist=any bash'
sudo apt install libchdb
```
##### **RPM**
```bash
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.rpm.sh | os=rpm_any dist=rpm_any bash'
sudo yum install -y libchdb
```
<!-- tabs:end -->


#### Installation
```bash
npm install node-chdb
```

#### Usage

##### 🗂️ Query Constructor
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

##### 🗂️ Query _(query, format)_
```javascript
const chdb = require("chdb-node").chdb;
var result = chdb.Execute("SELECT version()", "CSV");
console.log(result) // 23.6.1.1
```

##### 🗂️ Session _(query, *format, *path)_
```javascript
const chdb = require("chdb-node").chdb;
chdb.Session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'")
var result =  = chdb.Session("SELECT hello();")
console.log(result) // chDB
```

> ⚠️ Sessions persist table data to disk. You can specify `path` to implement auto-cleanup strategies:
```javascript
const temperment = require("temperment");
const tmp = temperment.directory();
chdb.Session("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'chDB'", "CSV", tmp)
var result =  = chdb.Session("SELECT hello();")
console.log(result) // chDB
tmp.cleanup.sync();
```

### **Go**

#### Requuirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/metrico/libchdb) on your amd64/arm64 system before proceeding
##### **DEB**
```bash
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.deb.sh | os=any dist=any bash'
sudo apt install libchdb
```
##### **RPM**
```bash
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.rpm.sh | os=rpm_any dist=rpm_any bash'
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
    result := chdb.Query("SELECT version()", "CSV")
    fmt.Println(result)
}
```

### **Rust**

Coming soon

### **Bun**

Coming soon

<!-- tabs:end -->
