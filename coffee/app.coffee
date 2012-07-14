# check if there's canvas support
canvasSupport = ->
  Modernizr.canvas

canvasApp = ->
  init = ->

  	# method to draw a clean canvas
    clean = ->
      context.fillStyle = "green"
      context.fillRect 0, 0, theCanvas.width, theCanvas.height

    # method to init a line at some coords
    startLine = (e) ->
      context.beginPath()
      context.strokeStyle = "#fff"
      context.lineCap = "round"
      context.lineWidth = 5
      context.moveTo e.clientX - theCanvas.offsetLeft, e.clientY - theCanvas.offsetTop
    
    # methd to end the line
    closeLine = (e) ->
      context.closePath()

    # method to draw the line
    draw = (e) ->
      context.lineTo e.clientX - theCanvas.offsetLeft, e.clientY - theCanvas.offsetTop
      context.stroke()

    clean()
    click = false
    block = false

    # connect with the server using socket.io
    socket.on "connect", ->

      # clean the board
      buttonClean.addEventListener "click", (->
        socket.emit "clean", true  unless block
      ), false

      # catch when someone is clicking in the board
      theCanvas.addEventListener "mousedown", ((e) ->
        unless block
          socket.emit "startLine",
            clientX: e.clientX
            clientY: e.clientY

          click = true
          startLine e
      ), false

      # catch when someone is releasing the click in the board
      window.addEventListener "mouseup", ((e) ->
        unless block
          socket.emit "closeLine",
            clientX: e.clientX
            clientY: e.clientY

          click = false
          closeLine e
      ), false

      # catch the movement of the mouse
      theCanvas.addEventListener "mousemove", ((e) ->
        if click
          unless block
            socket.emit "draw",
              clientX: e.clientX
              clientY: e.clientY

            draw e
      ), false

      # receive through websockets the draw commands
      socket.on "down", (e) ->
        unless click
          block = true
          startLine e

      socket.on "up", (e) ->
        unless click
          block = false
          closeLine e

      socket.on "move", (e) ->
        draw e  if block

      socket.on "clean", clean

  # if there's canvas support, init the app
  if canvasSupport()
    theCanvas = document.getElementById("canvas")
    context = theCanvas.getContext("2d")
    buttonClean = document.getElementById("clean")
    socket = io.connect("/")
    init()

# when the page is loaded, launch canvasApp
window.onload = ->
  canvasApp()