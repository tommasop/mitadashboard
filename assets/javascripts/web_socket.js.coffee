class WSConnector
  constructor: (host)->
    if WebSocket?
      window.socket = new WebSocket("ws://#{host}:8786")    
    else
      window.socket = new MozWebSocket("ws://#{host}:8786")
    
    window.socket.onopen = ->
      window.socket.send('Connesso')
      window.data_values = []

    window.socket.onmessage = (mess) =>
      if mess
        window.data_values = mess.data.split ";"

    window.socket.onclose = ->
      window.socket.send('Disconnesso,local')

$(document).ready ->
  client = new WSConnector('localhost')
