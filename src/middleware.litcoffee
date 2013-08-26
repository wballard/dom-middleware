
    mw = require('middlewarify')
    jsdom = require('jsdom')

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
        mw.make res, 'setHeader', res.setHeader
        res.setHeader.use (key, value, next) ->
          if key.toLowerCase() is 'content-type' and value.toLowerCase().indexOf('text/html') >= 0
            intercepting = true
          next()
        body = ''
        write = res.write
        end = res.end
        res.write = (chunk, encoding) ->
          if not res.headerSent
            res._implicitHeader()
          if intercepting
            body += chunk
          else
            write.call res, chunk, encoding
        res.end = (chunk, encoding) ->
          if chunk
            res.write chunk, encoding
          document = jsdom.jsdom(body)
          window = document.createWindow()
          finish = ->
            middleware.domEnd(window).done (err) ->
              if err
                res.emit 'error', err
              else
                end.call res, window.document.innerHTML
          if middleware.jquery
            jsdom.jQueryify window, finish
          else
            finish()
        next()

      middleware.domEnd = (window, next) ->
        next()
      mw.make middleware, 'domEnd', middleware.domEnd

      middleware.use = middleware.domEnd.use
      middleware
