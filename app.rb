require 'rubygems'
require 'bundler/setup'

require_relative 'lib/ash_frame'
AshFrame.root = File.dirname __FILE__

Bundler.require :default, AshFrame.environment

require 'require_all'
require_rel %w| config/initializers lib app |

# config.ru takes care of firing up the sinatra server, so now all we have to
# do is sit back and relax
