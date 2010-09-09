#!/usr/bin/env rackup
require File.dirname(__FILE__) + "/fn-git-wiki"

run FnGitWiki.new(File.expand_path(ARGV[1] || "."),
  File.expand_path(ARGV[2] || "./jSite"), ARGV[3] || ".wikitext",
  ARGV[4] || "index", ARGV[5] || "wiki.css")
