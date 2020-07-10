#
# Notes: 
# - Return values are delivered through `$return_value` variable.
#


###
# Handle global options:
# Thanks to: https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/
###
while getopts ":h" opt; do
  case ${opt} in
    h )
      echo "Usage:"
      echo "  content-gen.sh -h                   Display this help message."
      echo "  content-gen.sh new-post <options>   Create new post with <options>."
      echo "  content-gen.sh new-til <options>    Create til with <options>."
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done
shift $((OPTIND -1))


###
# Synthesize file name from title:
# Thanks: https://stackoverflow.com/questions/89609/in-a-bash-script-how-do-i-sanitize-user-input
###
function title_to_name {  # (title) -> name
  local cleaner=${1// /-}                 # Replace ' ' with '-'
  cleaner=${cleaner//[^a-zA-Z0-9\-]/}     # Remove [^a-zA-Z0-9_]
  cleaner=`echo -n $cleaner | tr A-Z a-z` # To lower-case

  return_value="$cleaner"
}

###
# Create new item through template:
###
function create_new_item_from_template {  # (type, title, ?name) -> file_path
  local type=$1
  local title=${2}

  # Synthesize file name from title if needs be
  title_to_name "$title"
  local name_from_title=${return_value} 
  local name=${4:-${name_from_title}}

  # Prepare dates
  local date_file=$(date +%F)
  local date_precise=$(date +"%F %T %z")

  # Prepare paths/folder fot the newly created item
  local folder="./_${type}"
  local path="${folder}/${date_file}-${name}.markdown"

  # Copy template, fill it in
  cat ${folder}/_template.markdown > ${path}
  sed -i "s/#title/${title}/g" ${path}
  sed -i "s/#date/${date_precise}/g" ${path}

  return_value="${path}"
}


###
# Sub-command functions:
###
function create_post {
    local type="posts"
    local category="misc"
    local title="New post"
    local name=""

    # Process sub-command's options
    while getopts ":c:t:n:h" opt; do
      case ${opt} in
        c )
          category=$OPTARG
          ;;
        t )
          title=$OPTARG
          ;;
        n )
          name=$OPTARG
          ;;
        h )
          echo "Usage:"
          echo "  -c <category[ies] | Post categories | default: 'misc'."
          echo "  -t <title>        | Post title      | default: 'New post'."
          echo "  -n <file-name>    | Post filename   | default: normalized <title>."
          exit 0
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Prepare new item
    create_new_item_from_template "$type" "$title" "$name"
    path="${return_value}"

    # Modify item specific values
    sed -i "s/#categories/${category}/g" ${path}
}

function create_til {
    local type="til"
    local category="misc"
    local title="New TIL"
    local name=""
    local link="https://petrroll.cz"

    # Process sub-command's options
    while getopts ":c:t:n:l:h" opt; do
      case ${opt} in
        c )
          category=$OPTARG
          ;;
        t )
          title=$OPTARG
          ;;
        n )
          name=$OPTARG
          ;;
        l )
          link=$OPTARG
          ;;
        h )
          echo "Usage:"
          echo "  -c <category>     | TIL category   | default: 'misc'."
          echo "  -t <title>        | TIL link text  | default: 'New TIL'."
          echo "  -l <title>        | TIL link URL   | default: 'https://petrroll.cz'."
          echo "  -n <file-name>    | TIL filename   | default: normalized <title>."
          exit 0
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))

    # Prepare new item
    create_new_item_from_template "$type" "$title" "$name"
    path="${return_value}"

    # Modify item specific values
    sed -i "s/#category/${category}/g" ${path}
    sed -i "s|#link|${link}|g" ${path}
}

###
# Handle subcommands:
###
subcommand=$1; shift  # Remove subcommand from the argument list
case "$subcommand" in
  new-post)
    create_post
    ;;

  new-til)
    create_til
    ;;
  *)
    echo "Invalid command: '$subcommand'" 1>&2
    ;;
esac



