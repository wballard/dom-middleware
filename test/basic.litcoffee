The most basic works at all tests.

    should = require('chai').should()
    request = require('request')
    http = require('http')
    connect = require('connect')
    dom = require('../index')
    path = require('path')

    describe 'Middleware', ->
      app = null
      server =  null
      middleware = null
      before (done) ->
        app = connect()
        middleware = dom()
        app
          .use(middleware)
          .use(connect.static(path.join(__dirname, 'pages')))
        server = http.createServer(app)
          .listen 9999, done
      after (done) ->
        server.close ->
            done()
      it "gets you a document", (done) ->
        gotWindow = null
        middleware.use (window, next) ->
          gotWindow = window
          next()
        request 'http://localhost:9999/index.html', (error, response, body) ->
          gotWindow.document.should.exist
          done()
      it "lets you dom modify server side", (done) ->
        middleware.use (window, next) ->
          window.document.getElementsByTagName('body')[0].innerHTML = 'Yo!'
          next()
        request 'http://localhost:9999/index.html', (error, response, body) ->
          body.should.include 'Yo!'
          done()
      it "lets you get jquery if you want it", (done) ->
        middleware.jquery = true
        middleware.use (window, next) ->
          window.$('title').text('Hello jQuery')
          next()
        middleware.use (window, next) ->
          window.$('body').text('check that')
          next()
        request 'http://localhost:9999/index.html', (error, response, body) ->
          body.should.include 'Hello jQuery'
          body.should.include 'check that'
          done()


