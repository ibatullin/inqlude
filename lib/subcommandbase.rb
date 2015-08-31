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

class SubcommandBase < CliBase
  class << self
    def subcommand_setup(name, usage, desc)
      namespace :"#{name}"
      @subcommand_usage = usage
      @subcommand_desc = desc
    end

    def banner(task, namespace = nil, subcommand = false)
      "#{basename} #{task.formatted_usage(self, true, true)}"
    end

    def register_to(klass)
      klass.register(self, @namespace, @subcommand_usage, @subcommand_desc)
    end
  end
end
