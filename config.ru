require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass/plugin/rack'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'db'
require 'application'

use Sass::Plugin::Rack
Sass::Plugin.options[:css_location] = "./public"
Sass::Plugin.options[:template_location] = "./public"
set :haml, { :format => :html5 }

run Sinatra::Application