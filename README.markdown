fn-git-wiki: because who needs cool names when you use freenet and git?
======================================================================

fn-git-wiki is a simple wiki with MediaWiki syntax that relies on git to keep pages' history.
It also maintains a static mirror for freenet insertion as freesite.

Install
-------

The fellowing [gems][] are required to run fn-git-wiki:

- [Thin][]
- [Rack][]
- [Sinatra][]
- [grit][]
- [HAML][]
- [WikiCloth][]
- [builder][]

Prepare wiki
------------

Create a new directory for your wiki `mkdir ~/wikidir && cd ~/wikidir && git init && mkdir jSite && mkdir static`

Place your CSS (call it `wiki.css` for easy defaults) and image files in the folder `static`

Copy/link the folder `static` to jSite/static. (Don't forget to update if you modify stuff in static.)

Run
---

CD into the wiki dir and run with `path/to/run.ru -o127.0.0.1 -sthin -p4567`
and point your browser at <http://127.0.0.1:4567/>. Enjoy!

Upload
------

Just insert the `jSite` folder.

See also
--------

- [How to use vim to edit &lt;textarea&gt; in lynx][tip]
- [ikiwiki][] is a wiki compiler supporting git

  [Thin]: http://code.macournoyer.com/thin/
  [Rack]: http://rack.rubyforge.org/
  [Sinatra]: http://www.sinatrarb.com
  [git-wiki]: http://github.com/sr/git-wiki
  [Sr]: http://github.com/sr
  [al3x]: http://github.com/al3x/gitwiki
  [gems]: http://www.rubygems.org/
  [grit]: http://github.com/mojombo/grit
  [HAML]: http://haml.hamptoncatlin.com
  [WikiCloth]: http://github.com/nricciar/wikicloth
  [builder]: http://builder.rubyforge.org/
  [tip]: http://wiki.infogami.com/using_lynx_&_vim_with_infogami
  [WiGit]: http://el-tramo.be/software/wigit
  [ikiwiki]: http://ikiwiki.info

Credits
-------

fn-git-wiki was originally forked from [Sr]'s [git-wiki]

Licence
-------
               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                       Version 2, December 2004

    Copyright (C) 2008 Simon Rozet <simon@rozet.name>
    Everyone is permitted to copy and distribute verbatim or modified
    copies of this license document, and changing it is allowed as long
    as the name is changed.

               DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
      TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

     0. You just DO WHAT THE FUCK YOU WANT TO.
