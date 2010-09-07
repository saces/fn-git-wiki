#!/usr/bin/env rackup
require File.dirname(__FILE__) + "/git-wiki"

run GitWiki.new(File.expand_path(ARGV[1] || "."),
  File.expand_path(ARGV[2] || "./jSite"), ARGV[3] || ".wikitext", ARGV[4] || "index")
