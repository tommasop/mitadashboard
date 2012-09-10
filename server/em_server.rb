require 'serialport'
require 'eventmachine'
require 'em-websocket'
require 'eventmachine-tail'

# Serial Port connection
begin
  @@sp = SerialPort.new("COM6", 9600, 8, 1, SerialPort::NONE)
rescue => e
  STDERR.puts 'cannot open serial port!'
  STDERR.puts e.to_s
  exit 1
end

@@recvs = Array.new
@@channel = EM::Channel.new
@@channel.subscribe do |data|
  now = Time.now.to_i*1000+(Time.now.usec/1000.0).round
  @@recvs.unshift({:time => now, :data => data})
  while @@recvs > 100
    @@recvs.pop
  end
end

class SerialSocketServer < EM::Connection
  def post_init
    @sid = @@channel.subscribe do |data|
      send_data "#{data}\n"
    end
    puts "* new socket client <#{@sid}>"

    def receive_data data
      data = data.to_s.strip
      return if data.size < 1
      puts "* socket client <#{@sid}> : #{data}"
      @@sp.puts data
    end

    def unbind
      @@channel.unsubscribe @sid
      puts "* socket client <#{@sid}> closed"
    end
  end
end


EM.run {

  # Serial Port TCP Socket
  EM::start_server('0.0.0.0', 8785, SerialSocketServer)
  puts "start Serial Port TCP socket server - port 8785"
    
  # WebSocket Server
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8786) do |ws|
    ws.onopen do
      sid = @@channel.subscribe{|msg| ws.send msg }
      puts "* new WebSocket client <#{sid}> connected!"
    
      # Messages received from client
      # Used to manage process restart and logging
      # Messages sent from client will have the following format:
      # class name, action to perform ex.
      # Gps start
      ws.onmessage do |msg|
	puts "* websocket client <#{@sid}> : #{msg}"
        action_data = msg.split(',')
	@@sp.puts mes.strip
        #app_object = Object.const_set(action_data[0], Class.new)
        #app_object.send(action_data[1])
      end

      ws.onclose do
        @@channel.unsubscribe(sid)
	puts "* websocket client <#{@sid}> closed"
      end
    end
  end
  puts "start WebSocket server - port 8786"

  # Used to read Lasers and Accelerometers value from log file
  EventMachine::file_tail("C:\\Tommaso\\mitadashboard\\tom") do |filetail, line|
    # filetail is the 'EventMachine::FileTail' instance for this file.
    # line is the line read from thefile.
    # this block is invoked for every line read.
    puts line
    @@channel.push line
  end 
}
