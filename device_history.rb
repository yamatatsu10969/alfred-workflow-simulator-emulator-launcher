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
    # Try to load from the primary history file
    if File.exist?(HISTORY_FILE)
      begin
        if File.size?(HISTORY_FILE)
          content = File.read(HISTORY_FILE)
          begin
            return JSON.parse(content)
          rescue JSON::ParserError
            # Parse error, return empty hash
          end
        end
      rescue
        # Error reading file, continue to fallback
      end
    end

    # Try fallback if primary failed
    if File.exist?(FALLBACK_HISTORY_FILE)
      begin
        if File.size?(FALLBACK_HISTORY_FILE)
          content = File.read(FALLBACK_HISTORY_FILE)
          begin
            return JSON.parse(content)
          rescue JSON::ParserError
            # Parse error, return empty hash
          end
        end
      rescue
        # Error reading fallback file, return empty hash
      end
    end

    # If all else fails, return empty history
    {}
  end

  def self.update_device(device_id, device_type)
    # Check for empty or nil device ID
    return false if device_id.nil? || device_id.empty?

    # Load existing history
    history = load_history

    # Update history with new device
    history[device_id] = {
      'type' => device_type,
      'last_used' => Time.now.to_i
    }

    # Save to both locations to be safe
    save_history(history)
  end

  def self.save_history(history)
    success = false

    # Try to save to primary history file
    begin
      # Ensure directory exists
      FileUtils.mkdir_p(File.dirname(HISTORY_FILE))

      # Convert to JSON and write to file
      File.write(HISTORY_FILE, JSON.pretty_generate(history))
      success = true
    rescue
      # Try fallback if primary failed
      begin
        FileUtils.mkdir_p(File.dirname(FALLBACK_HISTORY_FILE))
        File.write(FALLBACK_HISTORY_FILE, JSON.pretty_generate(history))
        success = true
      rescue
        # Failed to save to either location
      end
    end

    success
  end

  def self.sort_by_history(items, device_type)
    # Load existing history
    history = load_history

    # Sort items by last_used timestamp
    items.sort_by do |item|
      # For objects like Emulator/Simulator
      if item.respond_to?(:name)
        device_id = item.name
      # For script filter items (already converted)
      elsif item.respond_to?(:arg)
        device_id = item.arg
      else
        next 0
      end

      # Look up in history
      history_entry = history[device_id]

      if history_entry && history_entry['type'] == device_type
        -history_entry['last_used'].to_i # Negative for descending order
      else
        0 # No history => end of list
      end
    end
  end
end
