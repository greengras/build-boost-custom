require 'rake'
require 'rake/clean'

# ======================
# variables set by user
# ======================

boost_link   = 'http://sourceforge.net/projects/boost/files/boost/1.53.0/boost_1_53_0.tar.gz'

gcc_path     = '/opt/gcc-4.8.0/bin'
gcc          = 'gcc-4.8.0'
gcc_version  = '4.8.0'
boost_prefix = '/opt/boost'

# ===================================
# variables automatically determined
# ===================================

working_path  = Dir.pwd
boost_folder  = boost_link.split('/').last.split('.').first
boost_version = boost_link.split('/')[-2]

build_path    = "#{working_path}/#{boost_folder}"
prefix        = "#{boost_prefix}/#{boost_version}-gcc-#{gcc_version}"
config_jam    = 'user-config.jam'

# =============================
# bootstrap.sh, bjam arguments
# =============================

bootstrap_options = [
  "--prefix=#{prefix}",
  '--with-toolset=gcc',
  '--without-icu'
]

bjam_options = [
  "--prefix=#{prefix}",
  '--layout=tagged',
  "--user-config=#{config_jam}",
  '--without-python',
  '--build-type=minimal',
  'link=static',
  'runtime-link=static',
  'threading=multi',
  'variant=debug,release',
  'address-model=32_64',
  'architecture=x86',
  'pch=off',
  'install'
]

# ============
# Build boost
# ============

CLEAN.include build_path

task :default => [ :build, :clean ]

task :build do
  verbose(false) { sh "echo '================= start building boost ================='" }

  sh "wget #{boost_link}" unless File.exists?(boost_link.split('/').last)
  sh "tar xvfz #{boost_link.split('/').last}"

  Dir.chdir build_path

  File.open(config_jam, 'a') do |file|
    file.write "using gcc : #{gcc_version} : #{gcc_path}/#{gcc} ;\n"
  end

  sh "./bootstrap.sh #{bootstrap_options.join(' ')}"
  sh "./b2 #{bjam_options.join(' ')}"

  Dir.chdir working_path

  verbose(false) { sh "echo '================= finished building boost ================='" }
end


