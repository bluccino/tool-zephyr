##!/bin/bash
# bd.sh: board selection (setup BOARD environment variable)

   _SELECT_=true

   if [ "$*" == "-?" ]; then
      echo '  usage: bd                                # show board settings'
      echo '         bd -l                             # list all boards'
      echo '         bd -d                             # delete boards with given ID'
      echo '         bd -! <id> <type> <segger> <info> # define a board'
      echo '         bd <id>                           # select board by given ID'
      echo '         bd -?                             # show usage'
      echo '         bd --version                      # print version'
      echo ''
      echo '  examples for board definition:'
      echo "         bd -! n1 nrf52dk_nrf52832 682799342 'Nordic 832 DK #1'"
      echo "         bd -! n2 nrf52840dk_nrf52840 683483566 'Nordic 840 DK #2'"
      echo "         bd -! d1 nrf52840dongle_nrf52840 00000000 'Nordic 840 Dongle #1'"
      echo ''
      echo '  example for board selection:'
      echo '         bd 832dk                         # select board `832dk`'
      echo ''
      bash $BIN/bd.sh -l
      echo ''
      echo '  see also: bd, we, zenv'
      _SELECT_=false

      return 0 2>/dev/null || exit 0  # safe return/exit
   fi

#===============================================================================
# inst --version  # print version
#===============================================================================

   if [ "$*" == "--version" ]; then
      echo "1.0.2"
      return 0 2>/dev/null || exit 0  # safe return/exit
   fi

#===============================================================================
# define board
#===============================================================================

  if [ "$1" == "-!" ]; then
    shift
    if [ "$1" == "" ]; then
      bash $BIN/bd.sh -?
    else
      export BRDID="$1"
      export BOARD="$2"
      export SEGGER="$3"
      export BRDINFO="$4"

      if [ -d "$ETC/boards" ]; then
         echo "  export BRDID=$BRDID"      >$ETC/boards/$BRDID
         echo "  export BOARD=$BOARD"     >>$ETC/boards/$BRDID
         echo "  export SEGGER=$SEGGER"   >>$ETC/boards/$BRDID
         echo "  export BRDINFO='"$BRDINFO"'" >>$ETC/boards/$BRDID
      else
        ec -r 'error: missing $ETC/boards directory'
      fi
    fi
    _SELECT_=false

    return 0 2>/dev/null || exit 0  # safe return/exit
  fi

#===============================================================================
# delete board with given ID
#===============================================================================

  if [ "$1" == "-d" ] && [ "$2" != "" ]; then
    if [ -f $ETC/boards/"$2" ]; then
      rm $ETC/boards/"$2"
      export BRDID=
      export BOARD=
      export SEGGER=
      export BRDINFO=

      _TAGS_=`ls $ETC/boards`
      for _TAG_ in $_TAGS_
      do
        if [ -f $ETC/boards/"$_TAG_" ]; then
          source $ETC/boards/"$_TAG_"
        else
          ec -r "error: board $_TAG_ not defined!"
        fi
      done
      bash $BIN/bd.sh
    else
      ec -r "error: board $2 not defined!"
    fi
    _SELECT_=false

    return 0 2>/dev/null || exit 0  # safe return/exit
  fi

#===============================================================================
# print board info
#===============================================================================

  if [ "$1" == "-p" ] && [ "$2" != "" ]; then
    source "$ETC/boards/$2"
    if [ "$BRDINFO" == "" ]; then
      echo "    $2:  $BOARD, #$SEGGER"
    else
      echo "    $2:  $BOARD, #$SEGGER ($BRDINFO)"
    fi
    _SELECT_=false

    return 0 2>/dev/null || exit 0  # safe return/exit
  fi

#===============================================================================
# list all boards or select board
#===============================================================================

  if [ "$1" == "-l" ]; then
    _TAGS_=`ls $ETC/boards`

    echo "  "`ec -g  defined boards:`
    for _TAG_ in $_TAGS_
    do
      bash $BIN/bd.sh -p $_TAG_
    done
    _SELECT_=false
    return 0 2>/dev/null || exit 0  # safe return/exit

  elif [ "$1" != "" ] && [ "$2" == "" ] && [ "$_SELECT_" == "true" ]; then
    if [ -f $ETC/boards/"$1" ]; then
      source $ETC/boards/"$1"
      bash $BIN/bd.sh
    else
      ec -r "error: board $1 not defined!"
    fi

    return 0 2>/dev/null || exit 0  # safe return/exit
  fi

#===============================================================================
# summary of board settings
#===============================================================================

  if [ "$*" == "" ] ; then
    ec -g "Board Settings: $BRDID"
    ec    "  BOARD:   $BOARD"
    ec    "  SEGGER:  $SEGGER"
    ec    "  BRDINFO: $BRDINFO"
    return 0 2>/dev/null || exit 0  # safe return/exit
  fi

#===============================================================================
# cannot deal with anything else ...
#===============================================================================

   ec -r "error: we $*"
   bd -?
   return 1 2>/dev/null || exit 1  # safe return/exit
