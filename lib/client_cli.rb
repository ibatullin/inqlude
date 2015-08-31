
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

class ClientCli < SubcommandBase
  subcommand_setup "client", "client COMMAND", "Client commands"

  desc "list", "List libraries"
  method_option :remote, :type => :boolean, :aliases => "-r",
    :desc => "List remote libraries"
  def list
    handler = ManifestHandler.new @@settings
    handler.read_remote

    if options[:remote]
      handler.libraries.each do |library|
        puts library.name + " (" + library.versions.join(", ") + ")"
      end
    else
      manifests = @@distro.installed handler
      manifests.each do |manifest|
        puts manifest["name"]
      end
    end
  end

  desc "show <library_name>", "Show library details"
  def show name
    Upstream.get_involved "Add command for showing library details", 1
  end

  desc "download", "Download source code archive"
  def download(name)
    handler = ManifestHandler.new(@@settings)
    handler.read_remote
    manifest = handler.manifest(name)
    if !manifest
      STDERR.outs "Manifest for '#{name}' not found"
      exit 1
    else
      Downloader.new(handler, STDOUT).download(name, Dir.pwd)
    end
  end

  desc "uninstall", "Uninstall library"
  def uninstall name
    handler = ManifestHandler.new @@settings
    manifest = handler.manifest name
    if !manifest
      STDERR.puts "Manifest for '#{name}' not found"
    else
      @@distro.uninstall manifest
    end
  end

  desc "install", "Install library"
  method_option :dry_run, :type => :boolean,
    :desc => "Only show what would happen, don't install anything."
  def install name
    handler = ManifestHandler.new @@settings
    manifest = handler.manifest name
    if !manifest
      STDERR.puts "Manifest for '#{name}' not found"
    else
      @@distro.install manifest, :dry_run => options[:dry_run]
    end
  end

end
