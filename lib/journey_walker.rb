require 'r18n-core'
require 'journey_walker/version'
require 'journey_walker/journey'

R18n.default_places = File.join(File.dirname(File.expand_path(__FILE__)), 'i18n')
R18n.set('en')
