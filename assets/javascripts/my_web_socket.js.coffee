class WSConnector
  constructor: (host)->
    if WebSocket?
      window.socket = new WebSocket("ws://#{host}:8080")
    else
      window.socket = new MozWebSocket("ws://#{host}:8080")
    
    window.socket.onopen = (e) ->
      console.log('connesso')
      window.socket.send('Connesso')
      window.data_values = []

    window.socket.onmessage = (mess) =>
      if mess
        window.data_values = mess.data.split ";"

    window.socket.onclose = (e) ->
      window.socket.send('Disconnesso,local')

$(document).ready ->
  client = new WSConnector('localhost')
