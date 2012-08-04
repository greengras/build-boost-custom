require 'rake'
require 'rake/clean'

# ==========
# variables
# ==========

boost_link   = 'http://sourceforge.net/projects/boost/files/boost/1.50.0/boost_1_50_0.tar.gz'

working_path = Dir.pwd
build_path   = "#{working_path}/boost_1_50_0"

gcc_path     = '/usr/gcc-4.7.1/bin'
gcc          = 'gcc-4.7.1'
gcc_version  = '4.7.1'

config_jam   = 'user-config.jam'

prefix       = '/opt/boost/1.50.0-gcc-4.7.1'

# =============================
# bootstrap.sh, bjam arguments
# =============================

bootstrap_options = [
  "--prefix=#{prefix}",
  "--with-toolset=gcc",
  "--without-icu"
]

bjam_options = [
  "--prefix=#{prefix}",
  "--layout=tagged",
  "--user-config=#{config_jam}",
  "--without-python",
  "--build-type=minimal",
  "link=static",
  "runtime-link=static",
  "threading=multi",
  "variant=debug,release",
  "address-model=32_64",
  "architecture=x86",
  "pch=off",
  "install"
]

# ============
# Build boost
# ============

CLEAN.include build_path

task :default => [ :build, :clean ]

task :build do
  p "================= start building boost ================="

  sh "wget #{boost_link}" unless File.exists?(boost_link.split('/').last)
  sh "tar xvfz #{boost_link.split('/').last}"

  Dir.chdir build_path

  File.open(config_jam, 'a') do |file|
    file.write "using gcc : #{gcc_version} : #{gcc_path}/#{gcc} ;\n"
  end

  sh "./bootstrap.sh #{bootstrap_options.join(' ')}"
  sh "./b2 #{bjam_options.join(' ')}"

  Dir.chdir working_path

  p "================= finished building boost ================="
end


