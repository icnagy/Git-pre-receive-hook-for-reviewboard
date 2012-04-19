#!/bin/sh
# <oldrev> <newrev> <refname>
# Upload diff beetwen revisions to Reviewboard

#colors
c_red="\E[0;31m"
c_std="\E[0;39m"
c_green="\E[0;32m"

while read oldrev newrev ref
do
    echo "Start working with ReviewBoard"
    group='all'
    projectName='Nelbud'
    echo -e "${c_green}Project $projectName${c_std}"
    fileDiff="/var/diff/$projectName.path"
    echo "Creating diff between revision"
    git diff-tree -p $older $newrev > $fileDiff
    msg=`git shortlog $oldrev..$newrev`
    
    if (echo $msg | grep '#rb no-post') > /dev/null
    then 
      echo -e "${c_red}No Post flag was found${c_std}"
      exit 0
    fi

    if (echo $msg | grep '#rb no-request') > /dev/null
    then 
      echo -e "${c_red}No Request flag was found. Review request will be send but not bublish ${c_std}"
    post-review --diff-filename=$fileDiff --description="$msg" --summary="[$projectName project] Diff between revisions [${oldrev:0:6} ${newrev:0:6}]" --target-groups=$group
    exit 0
   fi

   if (echo $msg | grep '#rb group') > /dev/null
   then
     found="#rb group "
     first=`expr index "$i" "$found"`
     lng=${#found} #str length
     let "end=$lng+$first"
     newStr="${i:$end}"
     set $newStr;

     if [ $1 ]
     then 
       echo -e "${c_red}Group flag was found but group name wasn't found${c_std}"   
     else 
       unset group
       group="$1"
       echo -e "${c_red}Group flag was found. This review will be published to $goup group${c_std}"
       post-review --diff-filename=$fileDiff --description="$msg" --summary="[$projectName project] Diff between revisions [${oldrev:0:6} ${newrev:0:6}]" --target-groups=$group -p
       exit 0
     fi
  fi
done

