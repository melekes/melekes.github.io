---
categories:
- hbase
- hadoop
- apache
- map-reduce
comments: true
date: 2015-01-16T15:48:49Z
title: Writing to HBase from Hadoop Mapper
slug: writing-to-hbase-from-hadoop-mapper
---

Although Hadoop and HBase are often used together, not so many resources
devoted to interaction between them. In the book ["HBase: The Definitive
Guide"](http://shop.oreilly.com/product/0636920014348.do) there is a chapter
named "MapReduce Integration", which sheds some light on this. I would like to
give you another example of the MR task that reads and writes to the same HBase
table.

<!--more-->

_This article assumes you have a basic knowledge of Hadoop._

## Task

In our table "weather" we have 2 columns - the maximum temperature for a
month (`max`) and minimum respectively (`min`). We need to calculate the
average temperature and put it in a new column for further calculations.

## Mapper

{% gist 8ba19e1baca077d67c65 AvgTemperatureMapper.java %}

For every row we get `max` and `min` column's latest values (#13), wrap them into
ByteBuffer (#15), so we can get Integer values.

On line #7, we then construct new Put object, passing the same rowkey. After
that , we add new column `avg` into `temperatures` family and put the result of
`(max + min) / 2.0` in it (#8). In the end, we pass `rowkey` and our Put object
to `context#write` method, which modifies "weather" table and records the
results (#9).

## Driver

{% gist 8ba19e1baca077d67c65 AvgTemperatureDriver.java %}

In order to run our baby, we create new job (#5). Since we do not have Reduce
stage, we can set number of reduce tasks to 0 (#7). TableMapReduceUtil utility
saves us from routine work by setting the correct input format, mapper class,
adding dependencies jars and so on. All we need to do is to pass a few
parameters to `initTableMapperJob` method (#11).

I would like to note that if you need additional filtering, Scan object (#9)
could be tweaked more heavily (e.g. by using `#setFilter` method).

That is all for the reading. To write to a table (not necessarily the same, it
could be any other table as well) we have to:

1. Set OutputKeyClass and OutputValueClass to ImmutableBytesWritable and Put (both in mapper - #1 and driver - lines #14, #15);
2. Set OutputFormatClass (#20) and table name (#21).

Thats all folks. If I missed something, feel free to contact me or just leave a
comment.
