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
function title_to_name {
  local cleaner=${1// /-}                 # Replace ' ' with '-'
  cleaner=${cleaner//[^a-zA-Z0-9\-]/}     # Remove [^a-zA-Z0-9_]
  cleaner=`echo -n $cleaner | tr A-Z a-z` # To lower-case

  return_value="$cleaner"
}


###
# Subcommands functions:
###
function create_post_or_til {
    local type=$1
    local category=${2:-misc}
    local title=${3:-"New post"}
    local link=${5}

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
    sed -i "s/#category/${category}/g" ${path}
    sed -i "s/#link/${link}/g" ${path}
}


###
# Handle subcommands:
###
subcommand=$1; shift  # Remove subcommand from the argument list
case "$subcommand" in
  new-[pt]*)
    category=""
    title=""
    name=""

    # Handle precise type of subcommand
    case ${subcommand} in
      new-post )
        type="posts"
        ;;
      new-til )
        type="til"
        ;;
      * )
        echo "Invalid command: '$subcommand'" 1>&2
        ;;
    esac

    # Process subcommand options
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
          echo "  -c <category[ies] |                   | default: 'misc'."
          echo "  -t <title>        |                   | default: 'New post'."
          echo "  -n <file-name>    |                   | default: normalized <title>."
          echo "  -l <URL>          | url for TIL posts | default: ''."
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

    create_post_or_til "$type" "$category" "$title" "$name" "$link" # Note: "" are important to be able to pass empty variable correctly
    ;;
  *)
    echo "Invalid command: '$subcommand'" 1>&2
    ;;
esac



