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

class Cli < CliBase

  KdeCli.register_to(self)
  ClientCli.register_to(self)

  desc "version", "Show version"
  def version
    puts "Inqlude: #{@@settings.version}"

    qmake_out = `qmake -v`
    qmake_out =~ /Qt version (.*) in/
    puts "Qt: #{$1}"

    if @@distro
      puts "OS: #{@@distro.name} #{@@distro.version}"
    else
      puts "OS: unknown"
    end
  end

  desc "view", "Create view"
  method_option :output_dir, :type => :string, :aliases => "-o",
    :desc => "Output directory", :required => true
  method_option :manifest_dir, :type => :string, :aliases => "-m",
    :desc => "Manifest directory", :required => false
  method_option :enable_disqus, :type => :boolean,
    :desc => "Enable Disqus based comments on generate web pages. Works only on
actual domain."
  method_option :disable_search, :type => :boolean,
    :desc => "Disable Google based search."
  def view
    if options[:manifest_dir]
      @@settings.manifest_path = options[:manifest_dir]
    end

    manifest_handler = ManifestHandler.new(@@settings)
    manifest_handler.read_remote

    view = View.new(manifest_handler)
    view.enable_disqus = options[:enable_disqus]
    view.enable_search = !options[:disable_search]
    view.create options[:output_dir]
  end

  desc "verify [filename]", "Verify all manifests or specific file if filename is given"
  method_option :check_links, :type => :boolean,
    :desc => "Check links for reachability."
  def verify filename=nil
    v = Verifier.new @@settings

    if options[:check_links]
      Upstream.get_involved "Implement --check-links option", 11
      exit 1
    end
    
    errors = []

    if filename
      result = v.verify_file filename
      result.print_result
    else
      handler = ManifestHandler.new @@settings
      handler.read_remote
      count_ok = 0
      handler.libraries.each do |library|
        library.manifests.each do |manifest|
          result = v.verify manifest
          result.print_result
          if result.valid?
            count_ok += 1
          else
            errors.push result
          end
        end
      end
      puts
      puts "#{handler.manifests.count} manifests checked. #{count_ok} ok, " +
        "#{errors.count} with error."
      if !errors.empty?
        puts
        puts "Errors:"
        errors.each do |error|
          puts "  #{error.name}"
          error.errors.each do |e|
            puts "    #{e}"
          end
        end
      end
    end
  end

  desc "review <repo>", "Review pull requests on GitHub. Use 'username:branch' as repo parameter."
  def review repo, action = nil
    if !action
      GitHubTool.review repo
    elsif action == "accept"
      GitHubTool.accept repo
    else
      STDERR.puts "Unknown review action: '#{action}'"
      exit 1
    end
  end
  
  desc "system_scan", "Scan system for installed Qt libraries and create manifests"
  method_option :dry_run, :type => :boolean,
    :desc => "Dry run. Don't write files."
  method_option :recreate_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of installed RPMs"
  method_option :recreate_qt_source_cache, :type => :boolean,
    :desc => "Recreate cache with meta data of Qt library RPMs"
  def system_scan
    m = RpmManifestizer.new @@settings
    m.dry_run = options[:dry_run]

    if options[:recreate_source_cache]
      m.create_source_cache
    end
    
    if options[:recreate_qt_source_cache]
      m.create_qt_source_cache
    end
    
    m.process_all_rpms
  end

  desc "create <manifest_name> [version] [release_date]", "Create new or updated manifest"
  method_option :kf5, :type => :boolean,
    :desc => "Create KDE Framworks 5 template", :required => false
  def create name, version=nil, release_date=nil
    @@settings.manifest_path = "."
    creator = Creator.new @@settings, name
    if creator.is_new?
      if !version && release_date || version && !release_date
        STDERR.puts "You need to specify both, version and release date"
        exit 1
      end
      if version && release_date
        if options[:kf5]
          creator.create_kf5 version, release_date
        else
          creator.create version, release_date
        end
      else
        creator.create_generic
      end
    else
      if !version || !release_date
        STDERR.puts "Updating manifest requires version and release_date"
        exit 1
      end
      creator.validate_directory
      creator.update version, release_date
    end
  end

  desc "get_involved", "Information about how to get involved"
  def get_involved
    Upstream.print_info
  end

end
