<img src="logo.png" width=100>

# Installation

<!-- tabs:start -->

### **Python**

#### Installation
```bash
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
Install [libchdb](https://github.com/metrico/libchdb) on your x86/arm64 system before proceeding
#### **DEB**
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

### **Go**

Golang

### **Rust**

Rust

### **Bun**

Bun.sh

<!-- tabs:end -->
