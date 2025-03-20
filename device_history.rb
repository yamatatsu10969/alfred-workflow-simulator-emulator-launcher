# frozen_string_literal: true

require 'json'
require 'fileutils'

# Device History Manager
class DeviceHistory
  # Preferred locations for history file
  WORKFLOW_DATA_DIR = ENV['alfred_workflow_data']
  SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))

  # If running in Alfred, use workflow data directory, otherwise use script directory
  HISTORY_DIR = WORKFLOW_DATA_DIR || SCRIPT_DIR
  HISTORY_FILE = File.join(HISTORY_DIR, 'history.json')

  # Fallback to script directory
  FALLBACK_HISTORY_FILE = File.join(SCRIPT_DIR, 'history.json')

  def self.load_history
    # Create temp log file for debugging
    log_file = '/tmp/alfred_device_history.log'
    FileUtils.touch(log_file)
    File.write(log_file, "==== DeviceHistory.load_history called at #{Time.now} ====\n")
    File.write(log_file, "ENV: #{ENV.to_hash.inspect}\n", mode: 'a')
    File.write(log_file, "WORKFLOW_DATA_DIR: #{WORKFLOW_DATA_DIR}\n", mode: 'a')
    File.write(log_file, "SCRIPT_DIR: #{SCRIPT_DIR}\n", mode: 'a')
    File.write(log_file, "HISTORY_DIR: #{HISTORY_DIR}\n", mode: 'a')
    File.write(log_file, "Primary HISTORY_FILE: #{HISTORY_FILE}\n", mode: 'a')
    File.write(log_file, "Fallback HISTORY_FILE: #{FALLBACK_HISTORY_FILE}\n", mode: 'a')
    File.write(log_file, "Current directory: #{Dir.pwd}\n", mode: 'a')

    # Create history file path if it doesn't exist
    if HISTORY_DIR && !Dir.exist?(HISTORY_DIR)
      begin
        FileUtils.mkdir_p(HISTORY_DIR)
        File.write(log_file, "Created directory: #{HISTORY_DIR}\n", mode: 'a')
      rescue => e
        File.write(log_file, "Failed to create directory: #{e.message}\n", mode: 'a')
      end
    end

    # Try to load from the primary history file
    if File.exist?(HISTORY_FILE)
      begin
        if File.size?(HISTORY_FILE)
          content = File.read(HISTORY_FILE)
          File.write(log_file, "Loaded from primary history file. Content length: #{content.length}\n", mode: 'a')
          begin
            parsed = JSON.parse(content)
            File.write(log_file, "Successfully parsed JSON with #{parsed.keys.size} entries\n", mode: 'a')
            return parsed
          rescue JSON::ParserError => e
            File.write(log_file, "JSON parsing error: #{e.message}\n", mode: 'a')
            File.write(log_file, "Content causing error: #{content}\n", mode: 'a')
          end
        else
          File.write(log_file, "Primary history file exists but is empty\n", mode: 'a')
        end
      rescue => e
        File.write(log_file, "Error reading primary history file: #{e.message}\n", mode: 'a')
      end
    else
      File.write(log_file, "Primary history file does not exist\n", mode: 'a')
    end

    # Try fallback if primary failed
    if File.exist?(FALLBACK_HISTORY_FILE)
      begin
        if File.size?(FALLBACK_HISTORY_FILE)
          content = File.read(FALLBACK_HISTORY_FILE)
          File.write(log_file, "Loaded from fallback history file. Content length: #{content.length}\n", mode: 'a')
          begin
            parsed = JSON.parse(content)
            File.write(log_file, "Successfully parsed JSON with #{parsed.keys.size} entries\n", mode: 'a')
            return parsed
          rescue JSON::ParserError => e
            File.write(log_file, "JSON parsing error: #{e.message}\n", mode: 'a')
            File.write(log_file, "Content causing error: #{content}\n", mode: 'a')
          end
        else
          File.write(log_file, "Fallback history file exists but is empty\n", mode: 'a')
        end
      rescue => e
        File.write(log_file, "Error reading fallback history file: #{e.message}\n", mode: 'a')
      end
    else
      File.write(log_file, "Fallback history file does not exist\n", mode: 'a')
    end

    # If all else fails, return empty history
    File.write(log_file, "No valid history found, returning empty hash\n", mode: 'a')
    {}
  end

  def self.update_device(device_id, device_type)
    # Create temp log file for debugging
    log_file = '/tmp/alfred_device_history.log'
    File.write(log_file, "==== DeviceHistory.update_device called at #{Time.now} ====\n", mode: 'a')
    File.write(log_file, "device_id: #{device_id.inspect}, device_type: #{device_type.inspect}\n", mode: 'a')

    # Check for empty or nil device ID
    if device_id.nil? || device_id.empty?
      File.write(log_file, "ERROR: Cannot update history with empty device ID\n", mode: 'a')
      return false
    end

    # Load existing history
    history = load_history
    File.write(log_file, "Loaded history with #{history.keys.size} entries\n", mode: 'a')

    # Update history with new device
    history[device_id] = {
      'type' => device_type,
      'last_used' => Time.now.to_i
    }
    File.write(log_file, "Added/updated entry for #{device_id}\n", mode: 'a')

    # Save to both locations to be safe
    success = save_history(history)

    File.write(log_file, "History updated successfully: #{success}\n", mode: 'a')
    success
  end

  def self.save_history(history)
    log_file = '/tmp/alfred_device_history.log'
    File.write(log_file, "==== DeviceHistory.save_history called at #{Time.now} ====\n", mode: 'a')
    File.write(log_file, "Saving history with #{history.keys.size} entries\n", mode: 'a')

    success = false

    # Try to save to primary history file
    begin
      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(HISTORY_FILE))
      File.write(log_file, "Directory created/verified: #{File.dirname(HISTORY_FILE)}\n", mode: 'a')

      # Convert to JSON
      json = JSON.pretty_generate(history)
      File.write(log_file, "JSON generated, length: #{json.length}\n", mode: 'a')

      # Write to file
      File.write(HISTORY_FILE, json)
      File.write(log_file, "Saved to primary history file\n", mode: 'a')

      # Verify file was written
      if File.exist?(HISTORY_FILE) && File.size?(HISTORY_FILE)
        File.write(log_file, "Primary file verified, size: #{File.size(HISTORY_FILE)}\n", mode: 'a')
        success = true
      else
        File.write(log_file, "Primary file not verified\n", mode: 'a')
      end
    rescue => e
      File.write(log_file, "Error saving to primary history file: #{e.message}\n", mode: 'a')
      File.write(log_file, "Backtrace: #{e.backtrace.join("\n")}\n", mode: 'a')

      # Try fallback if primary failed
      begin
        FileUtils.mkdir_p(File.dirname(FALLBACK_HISTORY_FILE))
        json = JSON.pretty_generate(history)
        File.write(FALLBACK_HISTORY_FILE, json)

        # Verify file was written
        if File.exist?(FALLBACK_HISTORY_FILE) && File.size?(FALLBACK_HISTORY_FILE)
          File.write(log_file, "Fallback file verified, size: #{File.size(FALLBACK_HISTORY_FILE)}\n", mode: 'a')
          success = true
        else
          File.write(log_file, "Fallback file not verified\n", mode: 'a')
        end
      rescue => e2
        File.write(log_file, "Error saving to fallback history file: #{e2.message}\n", mode: 'a')
        File.write(log_file, "Backtrace: #{e2.backtrace.join("\n")}\n", mode: 'a')
      end
    end

    success
  end

  def self.sort_by_history(simulators, device_type)
    # Load existing history
    history = load_history

    # Create temp log file for debugging
    log_file = '/tmp/alfred_device_history.log'
    File.write(log_file, "==== DeviceHistory.sort_by_history called at #{Time.now} ====\n", mode: 'a')
    File.write(log_file, "Sorting #{simulators.length} devices of type #{device_type}\n", mode: 'a')
    File.write(log_file, "History contains #{history.keys.size} entries\n", mode: 'a')

    # Sample a few history entries for debugging
    if history.keys.size > 0
      sample_keys = history.keys.take(3)
      sample_keys.each do |key|
        File.write(log_file, "Sample history entry - key: #{key}, value: #{history[key].inspect}\n", mode: 'a')
      end
    else
      File.write(log_file, "No history entries to sample\n", mode: 'a')
    end

    # Sort simulators by last_used timestamp
    sorted = simulators.sort_by do |simulator|
      # Extract device ID
      device_id = simulator.arg

      # Look up in history
      history_entry = history[device_id]

      if history_entry && history_entry['type'] == device_type
        timestamp = -history_entry['last_used'].to_i
        File.write(log_file, "Found history for #{device_id}, using timestamp: #{timestamp}\n", mode: 'a')
        timestamp
      else
        File.write(log_file, "No history for #{device_id}, using default timestamp 0\n", mode: 'a')
        0 # No history => end of list
      end
    end

    File.write(log_file, "Sorting complete, returning #{sorted.length} sorted devices\n", mode: 'a')
    sorted
  end
end
