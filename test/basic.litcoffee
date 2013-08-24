The most basic works at all tests.

    should = require('chai').should()
    request = require('request')
    connect = require('connect')
    dom = require('../index')
    path = require('path')

    describe 'Middleware', ->
      app = null
      middleware = null
      before (done) ->
        app = connect()
        middleware = dom()
        app
          .use(middleware)
          .use(connect.static(path.join(__dirname, 'pages')))
          .listen 9999, done
      after (done) ->
        app.close ->
            done()
      it "gets you a queryable dom", (done) ->
        middleware.use (window, done) ->
          window.$.should.exist
          done()
        request 'http://localhost:9999/index.html', (error, response, body) ->
          console.log error


