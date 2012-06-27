require 'eventmachine'
require 'em-websocket'
require 'eventmachine-tail'

EM.run {
  @channel = EM::Channel.new
  
  # WebSocket Server
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen do
      sid = @channel.subscribe{|msg| ws.send msg }
      puts "#{sid} connected!"
    
      # Messages received from client
      # Used to manage process restart and logging
      # Messages sent from client will have the following format:
      # class name, action to perform ex.
      # Gps start
      ws.onmessage do |msg|
        action_data = msg.split(',')
        puts msg
        #app_object = Object.const_set(action_data[0], Class.new)
        #app_object.send(action_data[1])
      end

      ws.onclose do
        @channel.unsubscribe(sid)
      end
    end
  end
  
  EventMachine::file_tail('/Users/tommasop/work/progetti_servizi/dash_scratch/tom') do |filetail, line|
    # filetail is the 'EventMachine::FileTail' instance for this file.
    # line is the line read from thefile.
    # this block is invoked for every line read.
    puts line
    @channel.push line
  end 
}
