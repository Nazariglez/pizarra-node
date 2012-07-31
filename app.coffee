### require modules ###
express = require 'express'
espresso = require './espresso.coffee'
io = require 'socket.io'

# create express server
app = express.createServer()
io = io.listen app
io.set 'log level', 1

### parse args (- coffee and the filename) ###
ARGV = process.argv[2..]
rargs = /-{1,2}\w+/
rprod = /-{1,2}(p|production)/

for s in ARGV
  m = rargs.exec s
  app.env = 'production' if m and m[0] and m[0].match rprod

### express configuration ###
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.static __dirname + '/public'

### watch coffeescript sources ###
coffee = espresso.core.exec "#{espresso.core.node_modules_path}coffee -o public/js -w -c coffee"
coffee.stdout.on 'data', (data) ->
  espresso.core.minify() if app.env == 'production'

### watch stylus sources ###
espresso.core.exec "#{espresso.core.node_modules_path}stylus -w -c styl -o public/css"

### app routes ###
app.get '/', (req, res) ->
  res.render 'index', { title : 'Pizarra - Espresso Boilerplate' }

# start server
app.listen 3000, -> console.log "Express server listening on port %d, (env = %s)", app.address().port, app.env

# Socket.io
# Connection established
io.sockets.on "connection", (socket) ->

  ###
    Cuando un usuario realiza una acción en el cliente,
    recibo los datos de la acción en concreto y
    envío a todos los demás las coordenadas
  ###

  socket.on 'startLine', (e) ->
    console.log 'Dibujando...'
    io.sockets.emit 'down', e

  socket.on "closeLine", (e) ->
    console.log "Trazo Terminado"
    io.sockets.emit "up", e

  socket.on "draw", (e) ->
    io.sockets.emit "move", e

  socket.on "clean", ->
    console.log "Pizarra Limpia"
    io.sockets.emit "clean", true