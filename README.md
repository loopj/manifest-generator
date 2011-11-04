Manifest Destiny
================

A cache.manifest generator in ruby, for use in your HTML5 offline apps.

The configuration DSL is designed to map closely to the keywords in the HTML5 
cache manifest syntax: <http://www.w3.org/TR/html5/offline.html#manifests>


Installation
============

    gem install manifest-destiny


Configuration
=============

    # Build up the cache manifest
    manifest = ManifestDestiny.configure do
      # Cache local files in your offline app (maps to CACHE section)
      cache "images/sound-icon.png"
      cache "images/background.png"
    
      # Cache a remote file in your offline app (maps to CACHE section)
      cache "http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"

      # Online file whitelist (maps to NETWORK section)
      network "comm.cgi"
      
      # Fallback locations (maps to cache manifest FALLBACK section)
      fallback "/" => "offline.html"
    end


Generate a Cache Manifest
=============

    manifest.to_s


Render a Cache Manifest in Rails 2.x
====================================

    render_manifest do
      # Same configuration syntax as above
      cache "images/sound-icon.png"
      cache "images/background.png"
    end


Contributing to manifest-destiny
================================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
=========

Copyright (c) 2011 James Smith. See LICENSE.txt for
further details.

