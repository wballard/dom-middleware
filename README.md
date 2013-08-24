# dom-middleware
Sure, you have templates and generate HTML, but sometimes you just need
one more tweak on your pages before they go out the server.
`dom-middleware` to the rescue.

# Go!

```
npm install dom-middleware
```

```javascript
var path = require('path');
var express = require('express');
var dom = require('dom-middleware');
var app = express()
    .use(dom()
      .use(function (window, next) {
        window.$('title').text('Oh yeah!');
        next();
      })
    )
    .use(express.cookieParser())
    .use(express.static()
    .listen(9999);
```

This is middleware-middleware, it creates a substream of middleware that
works on a DOM as a response instead of a raw text stream. This allows
you to do complex transformations on the server using client side
technique.

This has some overhead, you should benchmark yourself to see.

# Notes
It's about that simple, note that this is using
[jsdom](https://github.com/tmpvar/jsdom), combined with middleware. The
'trick' that makes it work is in intercepting `write` and `end` for
response objects when the content type is `text/html`. The approach is:

* detect a header set of text/html
* substitute `write` and `end` with a buffering version
* on `end`, build up a DOM and hand it to your functions

Becuase this is hooking response, you will likely need to put it high
in your middleware chain. List **first**.
