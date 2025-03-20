# frozen_string_literal: true

require_relative 'device_history'

def main
  # Get the simulator UDID from the command line argument
  simulator_udid = ARGV[0]

  begin
    # Update history
    DeviceHistory.update_device(simulator_udid, 'simulator')

    # Launch the simulator
    system("xcrun simctl boot \"#{simulator_udid}\"")
    system("open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/")

    # Return the simulator UDID for Alfred
    puts simulator_udid
  rescue => e
    # Log any errors
    puts "ERROR: #{e.class}: #{e.message}"
    # Still try to return the simulator UDID for Alfred
    puts simulator_udid
  end
end

main
