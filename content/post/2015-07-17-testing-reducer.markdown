---
categories:
- hbase
- mrunit
- testing
- java
comments: true
date: 2015-07-17T12:34:19Z
title: Testing Reducer, which saves data to HBase, using MRUnit
slug: testing-reducer
---

Lately, I was needed to write a test for one of the reducers we have in our
project. Even though, it was pretty easy, I do confronted with a couple of
errors.

<!--more-->

I started out by looking at [this
tutorial](https://cwiki.apache.org/confluence/display/MRUNIT/MRUnit+Tutorial)
and found out it is a bit outdated. So I will post a necessary steps here.

First thing to do is, obviously, add mrunit as a dependency to your project:

```
<dependency>
  <groupId>org.apache.mrunit</groupId>
  <artifactId>mrunit</artifactId>
  <version>1.1.0</version>
  <classifier>hadoop2</classifier>
  <scope>test</scope>
</dependency>
```

*This is for Maven and Hadoop 2.*

Next step is to write a simple test case:

```java
@Test
public void returnsMaximumIntegerInValues() throws IOException,
    InterruptedException {
    new ReduceDriver<Text, IntWritable, Text, IntWritable>()
        .withReducer(new MaxTemperatureReducer())
        .withInput(new Text("1950"),
            Arrays.asList(new IntWritable(10), new IntWritable(5)))
        .withOutput(new Text("1950"), new IntWritable(10))
        .runTest();
}
```

Back to our story. So, I ended up with something like this:

{% gist e878b351daa8dd17bfae CatMaxAgesReducerTest.java %}

After running, I encountered the following error:

**No applicable class implementing Serialization in conf at io.serializations: class org.apache.hadoop.hbase.client.Put**

Because we use HBase to store our data and this reducer outputs its result to
HBase table, Hadoop is telling us that he doesn't know how to serialize our
data. That is why we need to help it. Inside `setUp` set the
`io.serializations` variable:

```java
conf.setStrings("io.serializations", new String[]{conf.get("io.serializations"), MutationSerialization.class.getName(), ResultSerialization.class.getName()});
```

Apart from tests, you will hardly see such a code, because
[TableMapReduceUtil](https://hbase.apache.org/apidocs/org/apache/hadoop/hbase/mapreduce/TableMapReduceUtil.html)
hides many details from you.

When you do this:

```java
TableMapReduceUtil.initTableReducerJob(
    Bytes.toBytes("animals"),
    CatMaxAgesReducer.class,
    job
);
```

it sets all the necessary settings required to a Reducer to work.

Useful links:

- https://cwiki.apache.org/confluence/display/MRUNIT/MRUnit+Tutorial
- http://www.ctrl-r.org/?p=291
- http://blog.cloudera.com/blog/2013/09/how-to-test-hbase-applications-using-popular-tools/

