Bare Website with nanoc3
========================

This repository contains a bare website that uses nanoc3 to power it up. It has
additional features compared to the standard nanoc website:

 -  tags
 -  pagination, the right way for static websites
 -  support for static assets

Meta information
================

 -  `publish: true|false`

    Set to false to disable publishing
    
 -  `filter:`
  
    Filter or filters to use
    
 -  `layout: ""`
  
    Layout to use

Metadata:

 -  `title: ""`
    
    Page title
    
 -  `tags:`
    
    List of tags associated with the page
    
 -  `kind: ""`

    The kind of page, to be part of an index of this kind
  
 -  `author:`
    
    Author Name
  
 -  `excerpt:`
 
    Excerpt
  
 -  `created_at:`
 
    Creation time
  
 -  `updated_at:`
 
    Updated automatically 

For paginated pages:

 -  `index_kind: ""`
    
    The kind of elements that is going to appear in the index
    
 -  `page_size: 10`
  
    The number of elements in the pages

How To
======

Start
-----

Modify the following keys in `config.yaml`:

 -  base_url
 -  deploy.default.dst
 -  author_name
 -  author_uri

Modify the front page: `content/index.haml`

Delete the default article and create your own using `rake create:article`

Update `layouts/defaults.haml` to suit your own needs.

Create a new article
--------------------

    rake create:article title="The Title"

Have static content
-------------------

Put items in the `static` directory.

Create a list of articles
-------------------------

Set the `kind` property of the elements you want to paginate to a specific
string and create a page that have the `index_kind` property set and that
contains the haml code:

    = render "_index_page", :header => true

An associated atom feed will be created.

TODO List
=========

 -  Have a configurable list of source streams. A rake/redo task should be able
    to import the articles in a RSS/Atom feed. Perhaps a source git repository
    can also be used.

