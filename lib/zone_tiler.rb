# Zone Tiler: Zone Tiler Tiles Tiles
# Copyright (C) 2012 Antonio Passamani <ilcorsaronero@gmail.com>

# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.

# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

# Visit https://github.com/ilcorsaronero/zone_tiler for further updates.

require "RMagick"

module ZoneTiler

        TILE_SIZE = 256
        BACKGROUND_COLOR = "#DDDDDD"
        FORMAT = "jpg"

        def self.delete_tiles(tile_path)
           FileUtils.rmtree(tile_path)
        end

        def self.build_tiles(original_picture,tile_path)
             image = Magick::ImageList::new(original_picture)
             maxZoom = (Math.log([image.columns,image.rows].max / TILE_SIZE) /
                        Math.log(2)).ceil
             FileUtils.mkdir(tile_path)
             resized_image_paths = Array.new(maxZoom+1)
             zooms = Range.new(0,maxZoom)
             # forcing mulatiple of 2 ** z 
             surface_x_size = image.columns - (image.columns % (2 **maxZoom))
             surface_y_size = image.rows - (image.rows % (2 **maxZoom))
              
             zooms.each do |z|
                x_size = surface_x_size / (2 ** (maxZoom - z))
                y_size = surface_y_size / (2 ** (maxZoom - z))
                resized = image.scale(x_size, y_size)
                0.upto(2 ** z - 1) do |y|
                   0.upto(2 **z - 1) do |x|
                      x_start = x * TILE_SIZE
                      y_start = y * TILE_SIZE
                      x_end = (x + 1) * TILE_SIZE 
                      y_end = (y + 1) * TILE_SIZE
                      # how about borders?
                      if x_end > x_size 
                        x_end = x_size 
                      end
                      if y_end > y_size 
                        y_end = y_size 
                      end
                      cropped = Magick::Image.new(TILE_SIZE,TILE_SIZE){
                       self.background_color = BACKGROUND_COLOR}
                      # is there anything to copy?
                      if x_start < x_end and y_start < y_end
                        cropped.import_pixels(
                         0,0,x_end - x_start, y_end-y_start,"RGBA",
                         resized.export_pixels(
                          x_start,y_start,x_end - x_start,y_end-y_start,"RGBA"))
                      end
                      cropped.write("#{tile_path}/tile_#{z}_#{x}_#{y}.#{FORMAT}")
                   end
                 end
             end

             maxZoom

        end

end
