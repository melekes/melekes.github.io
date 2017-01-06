---
categories:
- erlang
- logging
comments: true
date: 2016-04-24T11:25:45Z
title: Chokecherry Or The Story About 1000000 Timeouts
slug: chokecherry
---

Chokecherry (https://github.com/funbox/chokecherry) is a wrapper around lager
logger which limits the volume of info messages irrespectively of the lager's
backend.

This article tells a story behind this library. Down below you'll find answers to the following questions:

- "Why it was created?"
- "How it works?"
- "Do I need it?"

<!--more-->

## The Story About 1000000 Timeouts

We use lager in almost all of our applications. And it works pretty well most
of the time, except the cases where it doesn't.

<img class="img-rounded" src="/images/posts/2016-04-24-chokecherry/karate.gif" alt="" width="100%" title=""/>

It all started one day when we were experiencing a **peak load** in one of the
applications (we'll call it FortKnox). So, FortKnox was processing a lot of
data and producing a lot of logs (particularly, info messages). As
shown on a picture below, we were writing logs to a file on disk.

<img class="img-rounded" src="/images/posts/2016-04-24-chokecherry/app1.png" alt="" width="100%" title=""/>

Then we started seeing **random exits** (timeouts in calls to `lager:info`)
from many places. These led to different parts (gen_servers, gen_fsms, etc.) of
FortKnox crashing. Some of them got restarted by their supervisor. But it was
clear that this won't last long. Indeed, at some point, it all came down to the
application's supervisor and **whole node stopped working**.

<img class="img-rounded" src="/images/posts/2016-04-24-chokecherry/app2.png" alt="" width="100%" title=""/>

This is what happened. **Hard disk was not able to handle so much writes** (even in
the presence of OS caches). [file:write][filewrite] became slower and lager's
message box started to grow in size. The behavior for lager, in that case, is
to switch to synchronous mode (see
https://github.com/basho/lager#overload-protection for details), what he did.
That's how we came to the random exits.

Possible solutions were ([discussion on erlang-russian](https://groups.google.com/forum/#!topic/erlang-russian/8xEeffAV8sc)):

- ~~RAM disk~~ (high cost of maintenance)
- ~~configure lager in such a way, that would fix the problem~~ (no way to do that)
- ~~use tmpfs for `/tmp`~~ (low cost of maintenance; difficult to setup syncing tmpfs to disk; some logs still could be lost)
- create a thin wrapper around lager (low cost of maintenance; easy to setup; some logs may be dropped)

### On lager settings

lager has many settings and we could play with them. For example, we could turn
off synchronous mode.

<img class="img-rounded" src="/images/posts/2016-04-24-chokecherry/app3.png" alt="" width="100%" title=""/>

What will happen then is lager's mailbox start growing and, eventually, when
there will be no more free memory, node will crash.

{% blockquote %}
For performance, the file backend does delayed writes, although it will sync at
specific log levels, configured via the `sync_on' option. By default the error
level or above will trigger a sync.
{% endblockquote %}

Keep in mind that there were an exessive amount of info messages, so no `fsync`
calls ([file:datasync][filedatasync]) were made (we didn't change the default).

So **there was no simple solution** for this problem. **That's why we created
chokecherry**. What follows is how it works.

## Chokecherry

<img class="img-rounded" src="/images/posts/2016-04-24-chokecherry/app4.png" alt="" width="100%" title=""/>

**shaper** accumulates incoming messages in the queue. If the queue size
exceeds `log_queue_capacity` within a certain time period (1 second), it sends
an error_report "chokecherry dropped N messages in the last second", and drops
messages from the end of the queue, while receiving new ones and maintaining
the maximum size of the queue.

**writer** pulls messages from **shaper** and transmits them to lager.

Default settings are as follows:

```
[
    {chokecherry, [
        {shaper, [
            {timeout, 1000},
            {log_queue_capacity, 10000}
        ]}
    ]}
].
```

## Do you need it

If your application produces a lot of logs and you can afford to lose some
(i.e. stable work of an application is more important to you) - **yes**.

In the above story, we were writing logs to a file using `lager_file_backend`.
This doesn't mean that a similar story could not happen to you if you're using
a different backend. So it may be applicable to other backends likewise.

## Source code

Currently, we are only "shaping" info messages. If you think we should do it
for warning and error, or make it optional, let us know.

Source code: https://github.com/funbox/chokecherry

[filewrite]: https://github.com/basho/lager/blob/ec43800bd5bf0286c5d591fbda0b2d22fccf4d7b/src/lager_file_backend.erl#L257
[filedatasync]: https://github.com/basho/lager/blob/1159f9262fb589ce2ec310eb7dec5ac03b1fee16/src/lager_file_backend.erl#L262
