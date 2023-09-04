<img src="logo.png" width=100>

# Installation

<!-- tabs:start -->

### **Python**

#### Installation
```
pip install chdb
```

#### Usage
```python
import chdb

res = chdb.query('select * from file("data.parquet", Parquet)', 'JSON');
print(res)
```

### **NodeJS**

#### Requuirements

<!-- tabs:start -->
#### Libchdb DEB
```
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.deb.sh | os=any dist=any bash'
sudo apt install libchdb
```
#### Libchdb RPM
```
sudo bash -c 'curl -s https://packagecloud.io/install/repositories/auxten/chdb/script.rpm.sh | os=rpm_any dist=rpm_any bash'
sudo yum install -y libchdb
```

<!-- tabs:end -->


#### Installation
```
npm install node-chdb
```

#### Usage
```
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

### **Go**

Golang

### **Rust**

Rust

### **Bun**

Bun.sh

<!-- tabs:end -->
