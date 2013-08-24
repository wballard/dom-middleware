This is the DOM injecting middleware. The important points:

* Hook `setHeader`, and if we see `text/html` it is time to go into action
* Action means intercepting `write` and `end`, buffering
* Create a queryable dom when the stream is ended
* Hand off to the client side style middleware
* Stream out the resulting HTML of the DOM

    module.exports = ->
      middleware = (req, res, next) ->
        console.log 'i live'
        next()
      middleware.use = (clientStyleMiddleware) ->

      middleware
