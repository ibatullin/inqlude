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

class KdeCli < SubcommandBase
  subcommand_setup "kf", "kf [COMMAND]", "KDE frameworks commands"

  desc "create <frameworks-git-checkout> <output_dir>",
    "Create manifests from git checkout of KDE frameworks module in given directory"
  method_option "show-warnings", :type => :boolean,
    :desc => "Show warnings about missing data", :required => false
  method_option "ignore-errors-homepage", :type => :boolean,
    :desc => "Ignore errors about missing home page", :required => false
  def create checkout_dir, output_dir
    k = KdeFrameworksCreator.new
    if options["ignore-errors-homepage"]
      k.parse_checkout checkout_dir, :ignore_errors => [ "link_home_page" ]
    else
      k.parse_checkout checkout_dir
    end
    k.create_manifests output_dir
    k.errors.each do |error|
      puts "#{error[:name]}: #{error[:issue]}"
    end
    if options["show-warnings"]
      k.warnings.each do |warning|
        puts "#{warning[:name]}: #{warning[:issue]} (#{warning[:details]})"
      end
    end
  end

  desc "release <release_date> <version>",
    "Create release manifests for KDE frameworks release"
  def release release_date, version
    handler = ManifestHandler.new @@settings
    k = KdeFrameworksRelease.new handler
    k.read_generic_manifests
    k.write_release_manifests release_date, version
  end

end
