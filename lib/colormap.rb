#!/usr/bin/env ruby
##############################################################################
# Converts HTML colors between different formats
##############################################################################
# Handles color input in multiple formats:
#
#  * Six-character hexadecimal
#  * Three-character hexadecimal
#  * RGB
#  * HTML named color (including non-W3C colors)
#
# Three character hex codes are normalized to six characters and all
# input is normalized to lowercase. Colors can be converted from any
# one of these formats to any other.
#
# Code ported from the PHP originally used in Hextractor,
# a Corvid Works project.
# http://www.hextractor.com/
# http://www.corvidworks.com/
#
# This code is released under the terms of the MIT License
#
# Author: Kenn Wilson
# Copyright: Copyright (c) 2008 Kenn Wilson
# Version: 1.0
#
##############################################################################
# The MIT License
#
# Copyright (c) 2008 Kenn Wilson
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
#
##############################################################################
# Example usage:
#
# Include class and instantiate cwColorMap object:
#
#     require 'colormap.rb'
#     map = CwColorMap.new
#
# Call various methods, as needed:
#
#     hex  = map.rgb_to_hex("119 125 66")         # Returns '#777d42'
#     rgb  = map.hex_to_rgb("#777d42", :string)   # Returns '119 125 66'
#     name = map.hex_to_name("#ffffff")           # Returns 'white'
#
##############################################################################

class CwColorMap

  # Hash containing complete list of named colors and their hex codes
  attr_reader :colormap
	
  # Load colormap hash
  def initialize
    load_colormap
  end
	
  # Normalize three-character hex codes to six characters
  def hex_to_six(hex)
    prefix = String.new
    if hex.include?('#')
      prefix = '#'
      hex.sub!('#', '')
    end
    if hex.length == 6
      return prefix + hex
    end
    hex3  = hex.scan(/./)
    hex6  = hex3[0] + hex3[0]
    hex6 += hex3[1] + hex3[1]
    hex6 += hex3[2] + hex3[2]
    return prefix + hex6
  end
	
  # Convert RGB colors to hex codes.
  # Dumps values from hash into array to ensure that the
  # iterator reads them in the correct order (r, g, b).
  def rgb_to_hex(rgb)
    hex = "#"
    rgb = [
      rgb['r'], rgb['g'], rgb['b']
    ]
    rgb.each do |value|
      value = value.to_i
      value = value.to_s(16)
      value = value.rjust(2, "0")
      hex += value
    end
    return hex
  end
	
  # Converts hexadecimal colors to RGB. Defaults to returning a three-element
  # hash but can also return a space-delimited string if requested.
  def hex_to_rgb(hex, format = :hash)
    hex.sub!('#', '')
    if hex.length == 3
      hex = hex_to_six(hex)
    end
    hex = hex.scan(/./)
    rgb = {
      'r' => hex[0] + hex[1],
      'g' => hex[2] + hex[3],
      'b' => hex[4] + hex[5],
    }
    rgb['r'] = rgb['r'].to_i(16)
    rgb['g'] = rgb['g'].to_i(16)
    rgb['b'] = rgb['b'].to_i(16)
    # Accept format request as a symbol or string
    if format == :string || format == "string"
      rgb = rgb_hash_to_string(rgb)
    end
    return rgb
  end
=begin
hex_to_yuv('#ccccc')
return {'y' => 12, 'u' => 123, 'v' => 123}
=end
  def hex_to_yuv(hex_color)
    rgb = hex_to_rgb(hex_color)
    yuv = {}
    yuv['y'] = 66*(rgb['r'].to_i) + 129*(rgb['g'].to_i) + 25*(rgb['b'].to_i)
    yuv['u'] = -38*(rgb['r'].to_i) - 74*(rgb['g'].to_i) + 112*(rgb['b'].to_i)
    yuv['v'] = 112*(rgb['r'].to_i) - 94*(rgb['g'].to_i) - 18*(rgb['b'].to_i)
    return yuv
  end
  # Converts RGB hash to string
  def rgb_hash_to_string(rgb_hash)
    rgb_string  = rgb_hash['r'].to_s + ' '
    rgb_string += rgb_hash['g'].to_s + ' '
    rgb_string += rgb_hash['b'].to_s
    return rgb_string
  end
	
  # Converts RGB color string to three-element hash
  def rgb_string_to_hash(rgb_string)
    rgb_array = rgb_string.split(' ')
    rgb_hash = {
      'r' => rgb_array[0],
      'g' => rgb_array[1],
      'b' => rgb_array[2],
    }
    return rgb_hash
  end

  # Associative arrays in PHP are hashes in Ruby, so let's rename
  # these methods while preserving the original API.
  alias :rgb_array_to_string :rgb_hash_to_string
  alias :rgb_string_to_array :rgb_string_to_hash
	
  # Convert a named color to its hexadecimal equivilant and
  # returns hex code. Returns nil if name doesn't exist.
  def name_to_hex(name)
    name.downcase!
    colormap = downcase_keys(@colormap)
    if colormap.has_key?(name)
      return colormap[name]
    else
      return nil
    end
  end
	
  # Convert a hexadecimal color to it's named equivilant, if possible.
  # Returns the name if it exists, otherwise returns original hex code.
  def hex_to_name(hex)
    hex.downcase!
    colormap = downcase_keys(@colormap)
    colormap = colormap.invert
    if colormap.has_key?(hex)
      return colormap[hex]
    else
      return hex
    end
  end
	
  # Convert a named color to it's RGB equivilant
  def name_to_rgb(name, format = :hash)
    hex = name_to_hex(name)
    rgb = hex_to_rgb(hex, format)
    return rgb
  end
	
  # Convert an RGB color to it's named equivilant, if possible.
  def rgb_to_name(rgb)
    if rgb.class == "String"
      rgb = rgb_string_to_hash(rgb)
    end
    hex  = rgb_to_hex(rgb)
    name = hex_to_name(hex)
    return name
  end
	
  # Lowercase all hash keys.
  # Returns new hash with keys in lowercase.
  def downcase_keys(colormap)
    colormap_lower = Hash.new
    @colormap.each do |key, value|
      colormap_lower[key.downcase] = colormap[key]
    end
    return colormap_lower
  end

  # Private methods
  private
	
  # Set instance variable with colormap hash
  def load_colormap
    @colormap = {
      'AliceBlue'            => '#f0f8ff',
      'AntiqueWhite'         => '#faebd7',
      'Aqua'                 => '#00ffff',
      'Aquamarine'           => '#7fffd4',
      'Azure'                => '#f0ffff',
      'Beige'                => '#f5f5dc',
      'Bisque'               => '#ffe4c4',
      'Black'                => '#000000',
      'BlanchedAlmond'       => '#ffebcd',
      'Blue'                 => '#0000ff',
      'BlueViolet'           => '#8a2be2',
      'Brown'                => '#a52a2a',
      'Burlywood'            => '#deb887',
      'CadetBlue'            => '#5f9ea0',
      'Chartreuse'           => '#7fff00',
      'Chocolate'            => '#d2691e',
      'Coral'                => '#ff7f50',
      'CornflowerBlue'       => '#6495ed',
      'Cornsilk'             => '#fff8dc',
      'Crimson'              => '#dc143c',
      'Cyan'                 => '#00ffff',
      'DarkBlue'             => '#00008b',
      'DarkCyan'             => '#008b8b',
      'DarkGoldenrod'        => '#b8860b',
      'DarkGray'             => '#a9a9a9',
      'DarkGrey'             => '#a9a9a9',
      'DarkGreen'            => '#006400',
      'DarkKhaki'            => '#bdb76b',
      'DarkMagenta'          => '#8b008b',
      'DarkOliveGreen'       => '#556b2f',
      'DarkOrange'           => '#ff8c00',
      'DarkOrchid'           => '#9932cc',
      'DarkRed'              => '#8b0000',
      'DarkSalmon'           => '#e9967a',
      'DarkSeaGreen'         => '#8fbc8f',
      'DarkSlateBlue'        => '#483d8b',
      'DarkSlateGray'        => '#2f4f4f',
      'DarkSlateGrey'        => '#2f4f4f',
      'DarkTurquoise'        => '#00ced1',
      'DarkViolet'           => '#9400d3',
      'DeepPink'             => '#ff1493',
      'DeepSkyBlue'          => '#00bfff',
      'DimGray'              => '#696969',
      'DimGrey'              => '#696969',
      'DodgerBlue'           => '#1e90ff',
      'FireBrick'            => '#b22222',
      'FloralWhite'          => '#fffaf0',
      'ForestGreen'          => '#228b22',
      'Fuchsia'              => '#ff00ff',
      'Gainsboro'            => '#dcdcdc',
      'GhostWhite'           => '#f8f8ff',
      'Gold'                 => '#ffd700',
      'Goldenrod'            => '#daa520',
      'Gray'                 => '#808080',
      'Grey'                 => '#808080',
      'Green'                => '#008000',
      'GreenYellow'          => '#adff2f',
      'Honeydew'             => '#f0fff0',
      'HotPink'              => '#ff69b4',
      'IndianRed'            => '#cd5c5c',
      'Indigo'               => '#4b0082',
      'Ivory'                => '#fffff0',
      'Khaki'                => '#f0e68c',
      'Lavender'             => '#e6e6fa',
      'LavenderBlush'        => '#fff0f5',
      'LawnGreen'            => '#7cfc00',
      'LemonChiffon'         => '#fffacd',
      'LightBlue'            => '#add8e6',
      'LightCoral'           => '#f08080',
      'LightCyan'            => '#e0ffff',
      'LightGoldenrodYellow' => '#fafad2',
      'LightGray'            => '#d3d3d3',
      'LightGrey'            => '#d3d3d3',
      'LightGreen'           => '#90ee90',
      'LightPink'            => '#ffb6c1',
      'LightSalmon'          => '#ffa07a',
      'LightSeaGreen'        => '#20b2aa',
      'LightSkyBlue'         => '#87cefa',
      'LightSlateGray'       => '#778899',
      'LightSlateGrey'       => '#778899',
      'LightSteelBlue'       => '#b0c4de',
      'LightYellow'          => '#ffffe0',
      'Lime'                 => '#00ff00',
      'Limegreen'            => '#32cd32',
      'Linen'                => '#faf0e6',
      'Magenta'              => '#ff00ff',
      'Maroon'               => '#800000',
      'MediumAquamarine'     => '#66cdaa',
      'MediumBlue'           => '#0000cd',
      'MediumOrchid'         => '#ba55d3',
      'MediumPurple'         => '#9370d8',
      'MediumSeaGreen'       => '#3cb371',
      'MediumSlateBlue'      => '#7b68ee',
      'MediumSpringGreen'    => '#00fa9a',
      'MediumTurquoise'      => '#48d1cc',
      'MediumVioletRed'      => '#c71585',
      'MidnightBlue'         => '#191970',
      'MintCream'            => '#f5fffa',
      'MistyRose'            => '#ffe4e1',
      'Moccasin'             => '#ffe4b5',
      'NavajoWhite'          => '#ffdead',
      'Navy'                 => '#000080',
      'OldLace'              => '#fdf5e6',
      'Olive'                => '#808000',
      'OliveDrab'            => '#6b8e23',
      'Orange'               => '#ffa500',
      'OrangeRed'            => '#ff4500',
      'Orchid'               => '#da70d6',
      'PaleGoldenrod'        => '#eee8aa',
      'PaleGreen'            => '#98fb98',
      'PaleTurquoise'        => '#afeeee',
      'PaleVioletRed'        => '#d87093',
      'PapayaWhip'           => '#ffefd5',
      'PeachPuff'            => '#ffdab9',
      'Peru'                 => '#cd853f',
      'Pink'                 => '#ffc0cb',
      'Plum'                 => '#dda0dd',
      'PowderBlue'           => '#b0e0e6',
      'Purple'               => '#800080',
      'Red'                  => '#ff0000',
      'RosyBrown'            => '#bc8f8f',
      'RoyalBlue'            => '#4169e1',
      'SaddleBrown'          => '#8b4513',
      'Salmon'               => '#fa8072',
      'SandyBrown'           => '#f4a460',
      'SeaGreen'             => '#2e8b57',
      'Seashell'             => '#fff5ee',
      'Sienna'               => '#a0522d',
      'Silver'               => '#c0c0c0',
      'SkyBlue'              => '#87ceeb',
      'SlateBlue'            => '#6a5acd',
      'SlateGray'            => '#708090',
      'SlateGrey'            => '#708090',
      'Snow'                 => '#fffafa',
      'SpringGreen'          => '#00ff7f',
      'SteelBlue'            => '#4682b4',
      'Tan'                  => '#d2b48c',
      'Teal'                 => '#008080',
      'Thistle'              => '#d8bfd8',
      'Tomato'               => '#ff6347',
      'Turquoise'            => '#40e0d0',
      'Violet'               => '#ee82ee',
      'Wheat'                => '#f5deb3',
      'White'                => '#ffffff',
      'WhiteSmoke'           => '#f5f5f5',
      'Yellow'               => '#ffff00',
      'YellowGreen'          => '#9acd32',
    }
  end
	
	
end

