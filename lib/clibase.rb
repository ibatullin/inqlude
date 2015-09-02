# Copyright (C) 2011 Cornelius Schumacher <schumacher@kde.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

class CliBase < Thor

  class_option :offline, :type => :boolean, :desc => "Work offline"
  class_option :manifest_dir, :type => :string, :desc => "Manifest directory"

  def initialize(*args)
    super
    process_global_options options
  end

  def self.settings= s
    @@settings = s
  end

  def self.distro= d
    @@distro = d
  end

  private

  def process_global_options options
    @@settings.offline = options[:offline]
    if options[:manifest_dir]
      @@settings.manifest_path = options[:manifest_dir]
    end
  end

end
