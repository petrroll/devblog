---
layout: post
title:  Scaffolding jekyll posts with little bit of bash
date:   2020-07-10 20:40:51 +0200
author: Petr Houška
categories: misc
truncate: 2000
---	

Jekyll blogs are quite awesome. Really [simple to set-up](https://github.com/barryclark/jekyll-now), relatively [straightforward](https://github.com/petrroll/devblog/commit/6e19339a9ca9dc09c6ed5fdfac0a136181597fe6) to [customize](https://github.com/petrroll/devblog/commit/0f90114ed5e7358f2fc778fd8c9d00dc6d19e019), and generally a pleasure to work with. Their only downside I've noticed is a slightly annoying new-post story. You need to create a file at a specific location, correctly lower-case and sanitize its name - that should correspond to the title, and fill the date - twice.

Luckily, we can spend hours perfecting automation of this menial task and save a negative amount of time even assuming we'll continue blogging at a reasonable pace. 

A quick google revealed at least two existing scaffolding projects for jekyll posts but [one didn't fit my needs](http://www.marcusoft.net/2014/12/my-post-scaffolder-for-jekyll.html) - as it only works with normal posts, and [another required jeoman](http://anandmanisankar.com/posts/jekyll-starter-scaffold-blog-yeoman/) and was generally larger in scope. 

For those reasons, I decided to write my own little bash script. In its current form it is capable of scaffolding new posts and new items of my special TIL items (a normal Jekyll [collection](https://jekyllrb.com/docs/collections/) with specific attributes and format). It could, however, be very easily customized to handle any type of jekyll content. Apart from just creating new files, it automatically handles all the dates, sanitizing title and using it as the file-name, and supports custom templating in case your content is more specialized.

It's built on top of two principles:
- The first argument specifies `command`. The `command` determines what handler is called to operate and interpret subsequent options.
- Scaffolding is done by taking a `_template.markdown` (ignored by Jekyll) file in `./_<content-type>/` folder and templating it with specified options.

For example, calling `./jekyll-scaffold.sh new-til -t "Awesome site" -l "https://petrroll.cz"` scaffolds a new item in my `til` collection using these steps:
1. Recognizes `new-til` command -> calls `create_til_handler`.
2. Prepares default values for all options, sets `type` to `til`.
3. Parses `-t` and `-l` options as title and link through `getopts` and (potentially) overrides default values.
4. Creates new item based on template `create_new_item_from_template`.
    1. Prepares `filename` out of `title` through sanitization, replacing ` ` with `-` and lower-casing (in this case: `awesome-site`), if not specified explicitly.
    2. Prepares all the dates, ... .
    3. Copies [template](https://raw.githubusercontent.com/petrroll/devblog/master/_til/_template.markdown) (`./_til/_template.markdown`) to the new item's location (`./_til/<date>-awesome-site.markdown)`
    4. Replaces relevant things in the template. In this case `#date#`, `#title#`, `#category#`, and `#link#` with values gathered from options.

> For usage help just call `./jekyll-scaffold.sh -h` or `./jekyll-scaffold.sh <command> -h`. Or just make a mistake, when wrong option is specified the script calls itself with `-h` option automatically, preserving the same command :).

For posts it's very similar, the only differences are that `create_post_handler` is called, you can't use `-l` option, and the template from `./_posts/_template.markdown` is used instead. If you wanted to support some other type of content, it should be pretty clear how to write your own handler, prepare a template, and leverage the generic `create_new_item_from_template` function.

> For up-to-date version check it out in [devblog's repo](https://github.com/petrroll/devblog/blob/master/jekyll-scaffold.sh).

```bash
#!/bin/bash

###
# Usage: 
# - `jekyll-scaffold.sh <command> <options>``
#
# Notes: 
# - Return values are delivered through `$return_value` variable.
#
# More info at:
# - https://devblog.petrroll.cz/2020-07-10-scaffolding-jekyll-posts-with-little-bit-of-bash/
###


###
# Synthesize filename from title:
# Thanks: https://stackoverflow.com/questions/89609/in-a-bash-script-how-do-i-sanitize-user-input
###
function title_to_filename {  # (title) -> filename
  local cleaner=${1// /-}                 # Replace ' ' with '-'
  cleaner=${cleaner//[^a-zA-Z0-9\-]/}     # Remove [^a-zA-Z0-9_]
  cleaner=`echo -n $cleaner | tr A-Z a-z` # To lower-case

  return_value="$cleaner"
}


###
# Create new item through template:
###
function create_new_item_from_template {  # (type, title, ?filename) -> file_path
  local type=$1
  local title=${2}

  # Synthesize file filename from title if needs be
  title_to_filename "$title"
  local filename_from_title=${return_value} 
  local filename=${4:-${filename_from_title}}

  # Prepare dates
  local date_file=$(date +%F)
  local date_precise=$(date +"%F %T %z")

  # Prepare paths/folder fot the newly created item
  local folder="./_${type}"
  local path="${folder}/${date_file}-${filename}.markdown"

  # Copy template, fill it in
  cat ${folder}/_template.markdown > ${path}
  sed -i "s/#title#/${title}/g" ${path}
  sed -i "s/#date#/${date_precise}/g" ${path}

  return_value="${path}"
}


###
# Command handlers:
###
function create_post_handler {
    local type="posts"
    local category="misc"
    local title="New post"
    local filename=""

    # Process command's options
    while getopts ":c:t:n:h" opt; do
      case ${opt} in
        c )
          category=$OPTARG
          ;;
        t )
          title=$OPTARG
          ;;
        n )
          filename=$OPTARG
          ;;
        h )
          echo "Usage: $0 $command :c:t:n:h"
          echo "  -c <category[ies] | Post categories | default: 'misc'."
          echo "  -t <title>        | Post title      | default: 'New post'."
          echo "  -n <filename>     | Post filename   | default:  normalized <title>."
          exit 0
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          echo "`./${0} $command -h`" 
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          echo "`./${0} $command -h`" 
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Prepare new item
    create_new_item_from_template "$type" "$title" "$filename"
    path="${return_value}"

    # Modify item specific values
    sed -i "s/#categories#/${category}/g" ${path}
}

function create_til_handler {
    local type="til"
    local category="misc"
    local title="New TIL"
    local filename=""
    local link="https://petrroll.cz"

    # Process command's options
    while getopts ":c:t:n:l:h" opt; do
      case ${opt} in
        c )
          category=$OPTARG
          ;;
        t )
          title=$OPTARG
          ;;
        n )
          filename=$OPTARG
          ;;
        l )
          link=$OPTARG
          ;;
        h )
          echo "Usage: $0 $command :c:t:n:l:h"
          echo "  -c <category>     | TIL category   | default: 'misc'."
          echo "  -t <title>        | TIL link text  | default: 'New TIL'."
          echo "  -l <link>         | TIL link URL   | default: 'https://petrroll.cz'."
          echo "  -n <filename>     | TIL filename   | default:  normalized <title>."
          exit 0
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          echo "`./${0} $command -h`" 
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          echo "`./${0} $command -h`" 
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Prepare new item
    create_new_item_from_template "$type" "$title" "$filename"
    path="${return_value}"

    # Modify item specific values
    sed -i "s/#category#/${category}/g" ${path}
    sed -i "s|#link#|${link}|g" ${path}
}

###
# Handle global options:
# Thanks to: https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/
###
while getopts ":h" opt; do
  case ${opt} in
    h )
      echo "Usage: $0 <command> <options>"
      echo "  $0 -h                   Display this help message."
      echo "  $0 new-post <options>   Create new post with <options>."
      echo "  $0 new-til <options>    Create til with <options>."
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     echo "`./${0} -h`" 
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))

###
# Handle commands:
###
command=$1; shift  # Remove command from the argument list
case "$command" in
  new-post)
    create_post_handler "$@"
    ;;

  new-til)
    create_til_handler "$@"
    ;;
  *)
    echo "Invalid command: '$command'" 1>&2
    echo "`./${0} -h`" 
    ;;
esac
```