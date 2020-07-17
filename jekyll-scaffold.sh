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
  new-post )
    create_post_handler "$@"
    ;;

  new-til )
    create_til_handler "$@"
    ;;
  *)
    echo "Invalid command: '$command'" 1>&2
    echo "`./${0} -h`" 
    ;;
esac
