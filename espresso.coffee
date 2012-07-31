child_process = require 'child_process'
fs = require 'fs'
isWindows = process.platform.match /win/

ensureIsFile = (f, cb) ->
  fs.stat f, (err, stats) ->
    throw err if err
    if stats.isFile() and not stats.isDirectory()
      cb(f) if cb and typeof cb is 'function'

core =
  node_modules_path: if isWindows then 'call node_modules\\.bin\\' else './node_modules/.bin/'
  exec: (cmd) ->
    std = child_process.exec cmd
    std.stderr.on 'data', (error) ->
      console.log "error: #{error}"
    return std

  minify: ->
      fs.readdir 'public/js', (err, data) ->
        throw err if err

        for f in data
          ensureIsFile "public/js/#{f}", (f) ->
            core.exec core.node_modules_path + "uglifyjs --overwrite #{f}"

  logEspresso: ->
    console.log ' ______                                   '
    console.log '|  ____|                                  '
    console.log '| |__   ___ _ __  _ __ ___  ___ ___  ___  '
    console.log '|  __| / __| \'_ \\| \'__/ _ \\/ __/ __|/ _ \\ '
    console.log '| |____\\__ \\ |_) | | |  __/\\__ \\__ \\ (_) |'
    console.log '|______|___/ .__/|_|  \\___||___/___/\\___/ '
    console.log '           | |                            '
    console.log '           |_|                            '

exports.core = core