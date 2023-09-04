
## Data Formats

Just like ClickHouse, chdb can accept and return data in various formats. 

- Input formats are used to parse the data provided to `INSERT` and `SELECT` from a file-backed table such as File, URL or S3. 
- Output formats are used to arrange the results of a `SELECT`, and to perform `INSERT`s into a file-backed table.

The supported data formats are:

| Format                                                                                    | Input | Output |
|-------------------------------------------------------------------------------------------|------|-------|
| [TabSeparated](#tabseparated)                                                             | ✔    | ✔     |
| [TabSeparatedRaw](#tabseparatedraw)                                                       | ✔    | ✔     |
| [TabSeparatedWithNames](#tabseparatedwithnames)                                           | ✔    | ✔     |
| [TabSeparatedWithNamesAndTypes](#tabseparatedwithnamesandtypes)                           | ✔    | ✔     |
| [TabSeparatedRawWithNames](#tabseparatedrawwithnames)                                     | ✔    | ✔     |
| [TabSeparatedRawWithNamesAndTypes](#tabseparatedrawwithnamesandtypes)                     | ✔    | ✔     |
| [Template](#format-template)                                                              | ✔    | ✔     |
| [TemplateIgnoreSpaces](#templateignorespaces)                                             | ✔    | ✗     |
| [CSV](#csv)                                                                               | ✔    | ✔     |
| [CSVWithNames](#csvwithnames)                                                             | ✔    | ✔     |
| [CSVWithNamesAndTypes](#csvwithnamesandtypes)                                             | ✔    | ✔     |
| [CustomSeparated](#format-customseparated)                                                | ✔    | ✔     |
| [CustomSeparatedWithNames](#customseparatedwithnames)                                     | ✔    | ✔     |
| [CustomSeparatedWithNamesAndTypes](#customseparatedwithnamesandtypes)                     | ✔    | ✔     |
| [SQLInsert](#sqlinsert)                                                                   | ✗    | ✔     |
| [Values](#data-format-values)                                                             | ✔    | ✔     |
| [Vertical](#vertical)                                                                     | ✗    | ✔     |
| [JSON](#json)                                                                             | ✔    | ✔     |
| [JSONAsString](#jsonasstring)                                                             | ✔    | ✗     |
| [JSONStrings](#jsonstrings)                                                               | ✔    | ✔     |
| [JSONColumns](#jsoncolumns)                                                               | ✔    | ✔     |
| [JSONColumnsWithMetadata](#jsoncolumnsmonoblock))                                         | ✔    | ✔     |
| [JSONCompact](#jsoncompact)                                                               | ✔    | ✔     |
| [JSONCompactStrings](#jsoncompactstrings)                                                 | ✗    | ✔     |
| [JSONCompactColumns](#jsoncompactcolumns)                                                 | ✔    | ✔     |
| [JSONEachRow](#jsoneachrow)                                                               | ✔    | ✔     |
| [PrettyJSONEachRow](#prettyjsoneachrow)                                                   | ✗    | ✔     |
| [JSONEachRowWithProgress](#jsoneachrowwithprogress)                                       | ✗    | ✔     |
| [JSONStringsEachRow](#jsonstringseachrow)                                                 | ✔    | ✔     |
| [JSONStringsEachRowWithProgress](#jsonstringseachrowwithprogress)                         | ✗    | ✔     |
| [JSONCompactEachRow](#jsoncompacteachrow)                                                 | ✔    | ✔     |
| [JSONCompactEachRowWithNames](#jsoncompacteachrowwithnames)                               | ✔    | ✔     |
| [JSONCompactEachRowWithNamesAndTypes](#jsoncompacteachrowwithnamesandtypes)               | ✔    | ✔     |
| [JSONCompactStringsEachRow](#jsoncompactstringseachrow)                                   | ✔    | ✔     |
| [JSONCompactStringsEachRowWithNames](#jsoncompactstringseachrowwithnames)                 | ✔    | ✔     |
| [JSONCompactStringsEachRowWithNamesAndTypes](#jsoncompactstringseachrowwithnamesandtypes) | ✔    | ✔     |
| [JSONObjectEachRow](#jsonobjecteachrow)                                                   | ✔    | ✔     |
| [BSONEachRow](#bsoneachrow)                                                               | ✔    | ✔     |
| [TSKV](#tskv)                                                                             | ✔    | ✔     |
| [Pretty](#pretty)                                                                         | ✗    | ✔     |
| [PrettyNoEscapes](#prettynoescapes)                                                       | ✗    | ✔     |
| [PrettyMonoBlock](#prettymonoblock)                                                       | ✗    | ✔     |
| [PrettyNoEscapesMonoBlock](#prettynoescapesmonoblock)                                     | ✗    | ✔     |
| [PrettyCompact](#prettycompact)                                                           | ✗    | ✔     |
| [PrettyCompactNoEscapes](#prettycompactnoescapes)                                         | ✗    | ✔     |
| [PrettyCompactMonoBlock](#prettycompactmonoblock)                                         | ✗    | ✔     |
| [PrettyCompactNoEscapesMonoBlock](#prettycompactnoescapesmonoblock)                       | ✗    | ✔     |
| [PrettySpace](#prettyspace)                                                               | ✗    | ✔     |
| [PrettySpaceNoEscapes](#prettyspacenoescapes)                                             | ✗    | ✔     |
| [PrettySpaceMonoBlock](#prettyspacemonoblock)                                             | ✗    | ✔     |
| [PrettySpaceNoEscapesMonoBlock](#prettyspacenoescapesmonoblock)                           | ✗    | ✔     |
| [Prometheus](#prometheus)                                                                 | ✗    | ✔     |
| [Protobuf](#protobuf)                                                                     | ✔    | ✔     |
| [ProtobufSingle](#protobufsingle)                                                         | ✔    | ✔     |
| [Avro](#data-format-avro)                                                                 | ✔    | ✔     |
| [AvroConfluent](#data-format-avro-confluent)                                              | ✔    | ✗     |
| [Parquet](#data-format-parquet)                                                           | ✔    | ✔     |
| [ParquetMetadata](#data-format-parquet-metadata)                                          | ✔    | ✗     |
| [Arrow](#data-format-arrow)                                                               | ✔    | ✔     |
| [ArrowStream](#data-format-arrow-stream)                                                  | ✔    | ✔     |
| [ORC](#data-format-orc)                                                                   | ✔    | ✔     |
| [One](#data-format-one)                                                                   | ✔    | ✗     |
| [RowBinary](#rowbinary)                                                                   | ✔    | ✔     |
| [RowBinaryWithNames](#rowbinarywithnamesandtypes)                                         | ✔    | ✔     |
| [RowBinaryWithNamesAndTypes](#rowbinarywithnamesandtypes)                                 | ✔    | ✔     |
| [RowBinaryWithDefaults](#rowbinarywithdefaults)                                           | ✔    | ✔     |
| [Native](#native)                                                                         | ✔    | ✔     |
| [Null](#null)                                                                             | ✗    | ✔     |
| [XML](#xml)                                                                               | ✗    | ✔     |
| [CapnProto](#capnproto)                                                                   | ✔    | ✔     |
| [LineAsString](#lineasstring)                                                             | ✔    | ✔     |
| [Regexp](#data-format-regexp)                                                             | ✔    | ✗     |
| [RawBLOB](#rawblob)                                                                       | ✔    | ✔     |
| [MsgPack](#msgpack)                                                                       | ✔    | ✔     |
| [MySQLDump](#mysqldump)                                                                   | ✔    | ✗     |
| [Markdown](#markdown)                                                                     | ✗    | ✔     |
