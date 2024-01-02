<img src="logo.png" width=100>

# Installation

<!-- tabs:start -->

### **Python**

#### Requirements
* Python 3.8+ on macOS and Linux _(x86_64 and ARM64)_

#### Installation
```bash
pip install chdb
```

#### Usage

<img src="https://codapi.org/assets/logos/codapi.svg" height=15> The interactive examples on this page are powered by [codapi](https://codapi.org)

<!-- tabs:start -->

#### ** Basics **

| `python3 -m chdb [SQL] [OutputFormat]` 

```bash
python3 -m chdb "SELECT 1, 'abc'" Pretty
```

Or:

```python
import chdb

res = chdb.query("SELECT 1, 'abc'", "CSV")
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic">
</codapi-snippet>

Queries can return data using any [supported format](https://clickhouse.com/docs/en/interfaces/formats) as well as `Dataframe` and `Debug`.

<script id="main.py" type="text/plain">
import chdb

##CODE##
</script>

<!-- tabs:end -->
<!-- tabs:start -->

#### ** SQL dialect **

chDB is a wrapper around ClickHouse, so it supports exactly the same [SQL syntax](https://clickhouse.com/docs/en/sql-reference/syntax), including joins, CTEs, set operations, aggregations and window functions.

For example, let's create a sampled table of 10000 random numbers and calculate the mean and 95th percentile:

```python
from chdb.session import Session

db = Session()
db.query("CREATE DATABASE db")
db.query("USE db")

db.query("""
CREATE TABLE data (id UInt32, x UInt32)
ENGINE MergeTree ORDER BY id SAMPLE BY id
AS
SELECT number+1 AS id, randUniform(1, 100) AS x
FROM numbers(10000);
""")

query_sql = """
SELECT
  avg(x) as "avg",
  round(quantile(0.95)(x), 2) AS p95
FROM data
SAMPLE 0.1;
"""

res = db.query(query_sql, "PrettyCompactNoEscapes")
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic">
</codapi-snippet>

Note a couple of things here:

- `Session` provides a stateful database connection (the data is stored in the temporary folder and discarded when the connection is closed).
- The second argument to the `query` method specifies the output format. There are many [supported formats](/formats) such as `CSV`, `SQLInsert`, `JSON` and `XML` (try changing the format in the above example and re-running the code). The default one is `CSV`.

<!-- tabs:end -->
<!-- tabs:start -->

#### **Reading data**

As with output formats, chDB supports any input format supported by ClickHouse.

For example, we can read a dataset from CSV:

```python
query_sql = "SELECT * FROM 'employees.csv'"
res = chdb.query(query_sql, "PrettyCompactNoEscapes")
print(
    f"{res.rows_read()} rows | "
    f"{res.bytes_read()} bytes | "
    f"{res.elapsed()} seconds"
)
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py" files="data/employees.csv">
</codapi-snippet>

Or work with an external dataset as if it were a database table:

```python
query_sql = """
SELECT DISTINCT city
FROM 'employees.csv'
"""

res = chdb.query(query_sql, "CSV")
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py" files="data/employees.csv">
</codapi-snippet>

We can even query Pandas dataframes as if they were tables:

```python
import chdb.dataframe as cdf
import pandas as pd

employees = pd.read_csv("employees.csv")
departments = pd.read_csv("departments.csv")

query_sql = """
select
  emp_id, first_name,
  dep.name as dep_name,
  salary
from __emp__ as emp
    join __dep__ as dep using(dep_id)
order by salary desc;
"""

res = cdf.query(sql=query_sql, emp=employees, dep=departments)
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" files="data/employees.csv data/departments.csv">
</codapi-snippet>

<!-- tabs:end -->
<!-- tabs:start -->

#### **Writing data**

The easiest way to export data is to use the output format (the second parameter in the `query` method), and then write the data to disk:

```python
from pathlib import Path

query_sql = "SEELECT * FROM 'employees.csv'"
res = chdb.query(query_sql, "Parquet")

# export to Parquet
path = Path("/tmp/employees.parquet")
path.write_bytes(res.bytes())

# import from Parquet
query_sql = "SELECT * FROM '/tmp/employees.parquet' LIMIT 5"
res = chdb.query(query_sql, "PrettyCompactNoEscapes")
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py" files="data/employees.csv">
</codapi-snippet>

We can also easily convert the chDB result object into a PyArrow table:

```python
query_sql = "SELECT * FROM 'employees.csv'"
res = chdb.query(query_sql, "Arrow")

table = chdb.to_arrowTable(res)
print(table.schema)
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py" files="data/employees.csv">
</codapi-snippet>

Or Pandas dataframe:

```python
query_sql = "SELECT * FROM 'employees.csv'"
res = chdb.query(query_sql, "Arrow")

frame = chdb.to_df(res)
frame.info()
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py" files="data/employees.csv">
</codapi-snippet>

<!-- tabs:end -->
<!-- tabs:start -->

#### **Persistent Sessions**

To persist a chDB persistent session to a specific folder on disk, use the `path` constructor parameter. This way you can restore the session later:

```python
from chdb.session import Session

# create a persistent session
db = Session(path="/tmp/employees")

# create a database and a table
db.query("CREATE DATABASE db")
db.query("""
CREATE TABLE db.employees (
  emp_id UInt32 primary key,
  first_name String, last_name String,
  birth_dt Date, hire_dt Date,
  dep_id String, city String,
  salary UInt32,
) ENGINE MergeTree;
""")

# load data into the table
db.query("""
INSERT INTO db.employees
SELECT * FROM 'employees.csv'
""")

# ...
# restore the session later
db = Session(path="/tmp/employees")

# query the data
res = db.query("SELECT count(*) FROM db.employees")
print(res, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" files="data/employees.csv">
</codapi-snippet>

<!-- tabs:end -->
<!-- tabs:start -->

#### **User-defined functions**

We can define a function in Python and use it in chDB SQL queries.

Here is a `split_part` function that splits a string on the given separator and returns the resulting field with the given index (counting from one):

```python
from chdb.udf import chdb_udf

@chdb_udf()
def split_part(s, sep, idx):
    idx = int(idx)-1
    return s.split(sep)[idx]


second = chdb.query("SELECT split_part('a;b;c', ';', 2)")
print(second, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py">
</codapi-snippet>

And here is a `sumn` function that calculates a sum from 1 to N:

```python
from chdb.udf import chdb_udf

@chdb_udf(return_type="Int32")
def sumn(n):
    n = int(n)
    return n*(n+1)//2


sum20 = chdb.query("SELECT sumn(20)")
print(sum20, end="")
```

<codapi-snippet sandbox="chdb-python" editor="basic" template="#main.py">
</codapi-snippet>

chDB Python UDF requirements:

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

<br>

#### Python DB API

The chDB Python package adheres to the Python DB API ([PEP 249](https://peps.python.org/pep-0249/)), so you can use it just like you'd use stdlib's `sqlite3` module:

```python
from contextlib import closing
from chdb import dbapi

print(f"chdb version: {dbapi.get_client_info()}")

with closing(dbapi.connect()) as conn:
    with closing(conn.cursor()) as cur:
        cur.execute("SELECT version()")
        print("description:", cur.description)
        print("data:", cur.fetchone())
```

<codapi-snippet sandbox="chdb-python" editor="basic">
</codapi-snippet>

For more examples, see [examples](https://github.com/chdb-io/chdb/tree/main/examples) and [tests](https://github.com/chdb-io/chdb/tree/main/tests).

<!-- tabs:end -->

<br>

### **NodeJS**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/chdb-io/chdb) on your amd64/arm64 system before proceeding

```bash
curl -sL https://lib.chdb.io | sudo bash
```

<!-- tabs:end -->


#### Installation

See: [chdb-node](https://github.com/chdb-io/chdb-node)

#### Usage

<!-- tabs:start -->

##### **🗂️ Query Constructor**

You can leverage the power of chdb in your NodeJS applications by importing and using the `chdb-node` module

```javascript
const { query, Session } = require(".");

var ret;

// Test standalone query
ret = query("SELECT version(), 'Hello chDB', chdb()", "CSV");
console.log("Standalone Query Result:", ret);

// Test session query
// Create a new session instance
const session = new Session("./chdb-node-tmp");
ret = session.query("SELECT 123", "CSV")
console.log("Session Query Result:", ret);
ret = session.query("CREATE DATABASE IF NOT EXISTS testdb;" +
    "CREATE TABLE IF NOT EXISTS testdb.testtable (id UInt32) ENGINE = MergeTree() ORDER BY id;");

session.query("USE testdb; INSERT INTO testtable VALUES (1), (2), (3);")

ret = session.query("SELECT * FROM testtable;")
console.log("Session Query Result:", ret);

// Clean up the session
session.cleanup();
```
<!-- tabs:end -->

### **Go**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/chdb-io/chdb/releases/latest) on your amd64/arm64 system before proceeding

```bash
curl -sL https://lib.chdb.io | sudo bash
```

<!-- tabs:end -->

#### Installation

Install and Examples, see: [chdb-go](https://github.com/chdb-io/chdb-go)

### **Rust**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/chdb-io/chdb/releases/latest) on your amd64/arm64 system before proceeding

```bash
curl -sL https://lib.chdb.io | sudo bash
```

<!-- tabs:end -->

#### Usage

This binding is a work in progress. Follow the instructions at [chdb-rust](https://github.com/chdb-io/chdb-rust) to get started.

### **Bun**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/chdb-io/chdb/releases/latest) on your amd64/arm64 system before proceeding

```bash
curl -sL https://lib.chdb.io | sudo bash
```

<!-- tabs:end -->

#### Installation

Install and Examples, see: [chdb-bun](https://github.com/chdb-io/chdb-bun)

#### Usage

<!-- tabs:start -->

#### Query(query, *format) (ephemeral)
```javascript
import { query } from 'chdb-bun';

// Query (ephemeral)
var result = query("SELECT version()", "CSV");
console.log(result); // 23.10.1.1
```

#### Session.Query(query, *format)
```javascript
import { Session } from 'chdb-bun';
const sess = new Session('./chdb-bun-tmp');

// Query Session (persistent)
sess.query("CREATE FUNCTION IF NOT EXISTS hello AS () -> 'Hello chDB'", "CSV");
var result = sess.query("SELECT hello()", "CSV");
console.log(result);

// Before cleanup, you can find the database files in `./chdb-bun-tmp`

sess.cleanup(); // cleanup session, this will delete the database
```

<!-- tabs:end -->


### **C/C++**

#### Requirements

<!-- tabs:start -->
📦 Install [libchdb](https://github.com/chdb-io/chdb/releases/latest) on your amd64/arm64 system before proceeding

```bash
curl -sL https://lib.chdb.io | sudo bash
```

<!-- tabs:end -->

#### Usage

Follow the instructions for [libchdb](https://github.com/chdb-io/chdb/blob/main/bindings.md) to get started.

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
Bootstrapping a new **chdb binding**? Follow the instructions for [libchdb](https://github.com/chdb-io/chdb) to get started.



<!-- tabs:end -->
