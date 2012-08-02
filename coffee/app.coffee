# check if there's canvas support
canvasSupport = ->
  Modernizr.canvas

# set a function to control the scope
canvasApp = ->

  class User
    constructor: (@id) ->
      @color = generateRandomColor()

  # method to draw a clean canvas
  clean = (context, canvas) ->
    context.fillStyle = "green"
    context.fillRect 0, 0, canvas.width, canvas.height

  # method to set the color of the stroke
  setLineColor = (context, color) ->
    context.strokeStyle = color;

  # method to set the width of the stroke
  setLineWidth = (context, width) ->
    context.lineWidth = width

  # generate random color
  # http://paulirish.com/2009/random-hex-color-code-snippets/
  # It's based on the equality of 16777215 == ffffff in decimal
  generateRandomColor = ->
    "#" + Math.floor(Math.random()*16777215).toString(16)

  # method to init a line at some coords
  startLine = (context, canvas, color, e) ->
    context.beginPath()
    setLineColor context, color
    context.lineCap = "round"
    setLineWidth context, 5
    context.moveTo e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop
  
  # methd to end the line
  closeLine = (context) ->
    context.closePath()

  # method to draw the line
  draw = (context, canvas, e) ->
    context.lineTo e.clientX - canvas.offsetLeft, e.clientY - canvas.offsetTop
    context.stroke()

  # clear the canvas, connect, set the listeners and the socket methods
  init = ->
    clean context, canvas
    click = false
    block = false

    # connect with the server using socket.io
    socket.on "connect", ->

      user = new User this.socket.sessionid
      socket.color = user.color

      # clean the board
      buttonClean.addEventListener "click", (->
        socket.emit "clean", true unless block
      ), false

      # catch when someone is clicking in the board
      canvas.addEventListener "mousedown", ((e) ->
        unless block
          socket.emit "startLine",
            clientX: e.clientX
            clientY: e.clientY

          click = true
          startLine context, canvas, user.color, e
      ), false

      # catch when someone is releasing the click in the board
      window.addEventListener "mouseup", ((e) ->
        unless block
          socket.emit "closeLine",
            clientX: e.clientX
            clientY: e.clientY

          click = false
          closeLine context, e
      ), false

      # catch the movement of the mouse
      canvas.addEventListener "mousemove", ((e) ->
        if click
          unless block
            socket.emit "draw",
              clientX: e.clientX
              clientY: e.clientY

            draw context, canvas, e
      ), false

      # receive through websockets the draw commands
      socket.on "down", (e) ->
        unless click
          block = true
          startLine context, canvas, this.color, e

      socket.on "up", (e) ->
        unless click
          block = false
          closeLine context, e

      socket.on "move", (e) ->
        draw context, canvas, e  if block

      socket.on "clean", ->
        clean context, canvas

  # if there's canvas support, init the app
  if canvasSupport()
    canvas = document.getElementById("canvas")
    context = canvas.getContext("2d")
    buttonClean = document.getElementById("clean")
    socket = io.connect("/")
    init()

# when the page is loaded, launch canvasApp
window.onload = ->
  canvasApp()