#!/usr/bin/env ruby
#  test
#
#  Created by Carlos Maximiliano Giorgio Bort on 2012-10-08.
#  Copyright (c) 2011 University of Trento. All rights reserved.
#

require "../lib/simple_ipc"
require "../lib/charter_interface"

include Charter

# Initialise server (the client is the smartphone)
from_client = SimpleIPC::IPC.new :port => 5555, :nonblock => true, :kind => :udp
from_client.listen

# Initialise client (the server is the Charter application)
charter = Charter::Client.new(1)
charter.clear
charter.names %w|acc_X acc_Y acc_Z gyro_X gyro_Y gyro_Z magn_X magn_Y magn_Z|
charter.labels %w|Time Value|

# Initialize output file
file = File.new("../data/out.txt", "w")

file.write( "t : Time (s)
A : Acceleration (m/s^2): X, Y, Z
G : Gyroscope    (rad/s): X, Y, Z
M : Magnetometer (uT): X, Y, Z\n
t\tAX\tAY\tAZ\tGX\tGY\tGZ\tMX\tMY\tMZ")

# Start acquisition
started = false
t0 = 0
input = ""
while true do
  str = from_client.get
  
  puts str if !str.nil?
  unless str.nil?
    
    unless started
      tokens = str.split(",")
      t0 = tokens[0].to_f
      started = true
    else
      tokens = str.split(",")
      data = [(tokens[0].to_f-t0).round(3),                  # Time (s)
         tokens[2].to_f,  tokens[3].to_f,  tokens[4].to_f,   # Acceleration (m/s^2): X, Y, Z
         tokens[6].to_f,  tokens[7].to_f,  tokens[8].to_f,   # Gyroscope    (rad/s): X, Y, Z
         tokens[10].to_f, tokens[11].to_f, tokens[12].to_f ] # Magnetometer (uT): X, Y, Z
  
      charter << data  
      file.write "%s\t"*data.size % data.to_s.delete("[]").split(", ") + "\n"
    end # unless started
  end # unless tokens.nil?
  
end # while true

charter.close
file.close
