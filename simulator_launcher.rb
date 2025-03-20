# frozen_string_literal: true

require_relative 'device_history'

def main

  # Get the device ID from the command line argument
  device_id = ARGV[0]

  begin
    # Update history
    result = DeviceHistory.update_device(device_id, 'simulator')


    # Launch the simulator
    system("xcrun simctl boot #{device_id}")
    system("open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/")

    # Return the device ID for Alfred
    puts device_id
  rescue => e
    # Log any errors
    puts "ERROR: #{e.class}: #{e.message}"
    # Still try to return the device ID for Alfred
    puts device_id
  end
end

main
