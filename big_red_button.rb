#!/usr/bin/env ruby
# frozen_string_literal: true

begin
  require 'rubygems'
rescue StandardError
  nil
end
require 'usb'

#
# AUTHORS
#   Eaden McKee <eadz@eadz.co.nz>
#   First Big Red Button Version
#   Forked from DelcomLightHid https://raw.github.com/puyo/delcom_light_hid
#   ( for a different device)
#   Originally by
#   Ian Leitch <ian@envato.com>, Copyright 2010 Envato
#     * Original single light RGY version
#   Gregory McIntyre <blue.puyo@gmail.com>
#     * RGY+RGB support
#     * Multiple light support
#     * Method to get current light color
#
# You'll need to install ruby-usb:
#
#   gem install ruby-usb
#
# Only pass :vendor_id, :product_id or :interface_id to BigRedButton.open if you
# need to override their defaults.
# ref http://www.a-k-r.org/ruby-usb/rdoc/USB/DevHandle.html#method-i-usb_control_msg
# ref http://www.beyondlogic.org/usbnutshell/usb6.shtml
class BigRedButton
  DEFAULT_VENDOR_ID = 0x1d34
  DEFAULT_PRODUCT_ID = 0x000d
  DEFAULT_DEVICE_INDEX = 0
  DEFAULT_INTERFACE_ID = 0

  # Create a handler and ensure it gets closed after your block exits.
  def self.open(*args_to_new, &block)
    light = new(*args_to_new)
    begin
      block.call(light)
    ensure
      light.close
    end
  end

  # Create a handler that can control the light. Options are:
  #
  # * <tt>:device_index</tt> - Zero-based index of the light to use, if you have multiple lights.
  def initialize(options = {})
    @vendor_id = options[:vendor_id] || DEFAULT_VENDOR_ID
    @product_id = options[:product_id] || DEFAULT_PRODUCT_ID
    @device_index = options[:device_index] || DEFAULT_DEVICE_INDEX
    @interface_id = options[:interface_id] || DEFAULT_INTERFACE_ID
    @device = USB.devices.select do |device|
      device.idVendor == @vendor_id && device.idProduct == @product_id
    end[@device_index]
    raise 'Unable to find device' unless @device
  end

  def close
    handle.release_interface(@interface_id)
    handle.usb_close
    @handle = nil
  end

  def set(data)
    handle.usb_control_msg(0x21, 0x09, 0x0635, 0x000, "\x65\x0C#{[data].pack('C')}\xFF\x00\x00\x00\x00", 0)
  end

  def get
    buf = "\0" * 8
    buf[0] = 100
    status = handle.usb_control_msg(0xa1, 0x01, 0x0301, 0x000, buf, 0)
    raise 'Error reading status' if status != 8

    result = buf[2]
    case result
    when 0xfe then 'DelcomLight::RGB::GREEN'
    # when 0xfd then DelcomLight::RGB::RED
    #     when 0xfb then DelcomLight::RGB::BLUE
    #     when 0xfc then DelcomLight::RGB::YELLOW
    #     when 0xfa then DelcomLight::RGB::CYAN
    #     when 0xf9 then DelcomLight::RGB::PURPLE
    #     when 0xf8 then DelcomLight::RGB::WHITE
    #     when 0xfe then DelcomLight::OFF
    else raise 'Unknown result: %02x' % result
    end
  end

  private

  def handle
    return @handle if @handle

    @handle = @device.usb_open
    begin
      # ruby-usb bug: the arity of rusb_detach_kernel_driver_np isn't defined
      # correctly, it should only accept a single argument
      if USB::DevHandle.instance_method(:usb_detach_kernel_driver_np).arity == 2
        @handle.usb_detach_kernel_driver_np(@interface_id, @interface_id)
      else
        @handle.usb_detach_kernel_driver_np(@interface_id)
      end
    rescue Errno::ENODATA
      # already detached
    end
    @handle.set_configuration(@device.configurations.first)
    @handle.claim_interface(@interface_id)
    @handle
  end
end

b = BigRedButton.new
puts b.get
