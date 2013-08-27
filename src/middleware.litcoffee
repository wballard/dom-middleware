
    mw = require('middlewarify')
    jsdom = require('jsdom')
    buffer = require('buffer')
    util = require('util')

This is the DOM injecting middleware. The important points:

* Hook `setHeader`, and if we see `text/html` it is time to go into action
* Action means intercepting `write` and `end`, buffering
* Create a queryable dom when the stream is ended
* Hand off to the client side style middleware
* Stream out the resulting HTML of the DOM

## middleware

    module.exports = ->

      middleware = (req, res, next) ->
        intercepting = false
        contentTypeSet = false
        mw.make res, 'setHeader', res.setHeader
        res.setHeader.use (key, value, next) ->
          if key.toLowerCase() is 'content-type' and not contentTypeSet
            contentTypeSet = true
            if value.toLowerCase().indexOf('text/html') >= 0
              intercepting = true
          next()
        body = ''
        write = res.write
        end = res.end
        res.write = (chunk, encoding) ->
          if not res.headerSent
            res._implicitHeader()
          if intercepting
            if chunk instanceof buffer.Buffer
              body += chunk.toString(encoding or 'utf8')
            else
              body += chunk
          else
            write.call res, chunk, encoding
        res.end = (chunk, encoding) ->
          if chunk
            res.write chunk, encoding
          if intercepting
            document = jsdom.env
              url: req.protocol + '://' + req.headers.host + req.url
              html: body
              done: (error, window) ->
                if error
                  console.error 'horror shock', error
                finish = ->
                  middleware.domEnd(window).done (err) ->
                    if err
                      res.emit 'error', err
                    else
                      end.call res, window.document.outerHTML
                if middleware.jquery
                  jsdom.jQueryify window, finish
                else
                  finish()
          else
            end.call res, null
        next()

      middleware.domEnd = (window, next) ->
        next()
      mw.make middleware, 'domEnd', middleware.domEnd

      middleware.use = middleware.domEnd.use
      middleware
