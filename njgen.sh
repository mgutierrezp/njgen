#!/bin/bash

set -f
PROGVERSION="v1.4"
TMPFILE=`mktemp`
TMPDIR=`mktemp -d`
trap "echo >&2; echo 'aborted.' >&2; rm -f $TMPFILE && rmdir $TMPDIR > /dev/null 2>&1; exit" SIGINT SIGTERM
trap "rm -f $TMPFILE && rmdir $TMPDIR > /dev/null 2>&1" EXIT

function help(){
	echo "Usage: njgen.sh [-s filename] [find expression] [> output]"
	echo
	echo "Searches files that matches a 'find' expression and generates a JSON file ready to import into ncdu program"
	echo "With no arguments, njgen will print in the standard output the json file with all the files in the current directory subtree"
	echo "If -s parameter is specified, saves each filename (with the full path) into <filename>. This is useful for example if you run njgen in a large directory and you want to save the file names to process them later"
	echo
	echo "Example:	njgen.sh -atime +365 -mtime +365 -size +4G > myFile"
	echo "       will look for files bigger than 4GB that have not been accesed nor modified in the last year, and save JSON info in 'myFile'. Later, you can import with 'ncdu -f myFile' and view the list with a friendly ncurses interface"
	exit 0
}

function checkReqs() {
	which ncdu > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo "Warning: ncdu is not installed" >&2
	else [[ X`ncdu -v` != "Xncdu 1.10" ]] && echo "Warning: this program has been tested with ncdu 1.10. Yours is "`ncdu -v` >&2
	fi
}

function testFindExpr() {
	find $TMPDIR -type f $@ -printf '%y//%P//%s//%i//%f//%D//%h\n' > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
		echo "ERROR: 'find' expression failed!" >&2
		echo $@ >&2
		exit 1
	fi
}

function checkParams() {
	[[ "X"$1 == "X-h" ]] && help
	[[ "X"$1 == "X--help" ]] && help
	saveFilenames=0
	if [ "X"$1 == "X--saveFilenames" -o "X"$1 == "X-s" ]
	then
		touch $2 >/dev/null 2>&1
		if [ $? -ne 0 ]
		then
			echo "Could not create file "$2 >&2
			echo "File names won't be saved" >&2
			saveFilenames=0
		else
			saveFilenames=1
			saveFilenamesLOG=$2
		fi
	fi
}

echo "Ncdu JSON generator "$PROGVERSION >&2
checkReqs
checkParams $@
[[ -n $saveFilenames && $saveFilenames -eq 1 ]] && shift && shift
testFindExpr $@

# save awk in temporal file
cat $0 | awk '/^## queeY7ah ##/,/EOF/{print}' > $TMPFILE

echo "User 'find' expression: $@" >&2
echo "Full exec: find . -type f $@ -printf '%y//%P//%s//%i//%f//%D//%h\n'" >&2
echo "Running..." >&2
if [ $saveFilenames -eq 1 ]
then
	find . -type f $@ -printf '%y//%P//%s//%i//%f//%D//%h\n' | tee $saveFilenamesLOG | awk -F '//' -f $TMPFILE
	saveFilenamesLOGTMP=`mktemp`
	cat $saveFilenamesLOG | awk -F '//' '{print $2}' > $saveFilenamesLOGTMP
	mv $saveFilenamesLOGTMP $saveFilenamesLOG
else
	find . -type f $@ -printf '%y//%P//%s//%i//%f//%D//%h\n' | awk -F '//' -f $TMPFILE
fi
echo "OK. Try to import JSON with 'ncdu -r -f <filename>" >&2

exit





### awk program starts here ###
# please do not remove or modify the following signature
## queeY7ah ##
BEGIN { 
	dirName="./"
	print "[1,0,{\"progname\":\"ncdu\",\"progver\":\"1.10\",\"timestamp\":"systime()"},"
	printf "[{\"name\":\"%s\"}",ENVIRON["PWD"]
}

{
	previousTypeOfFile=typeOfFile
	previousDirName=dirName

	typeOfFile=$1
	fullNameOfFile=$2
	size=$3
	inode=$4
	nameOfFile=$5
	dev=$6
	dirName=$7
	

	gsub(/\\/,"\\\\",dirName)
	gsub(/\\/,"\\\\",nameOfFile)
	gsub(/\\/,"\\\\",previousDirName)
	
	gsub(/\"/,"\\\"",dirName)
	gsub(/\"/,"\\\"",nameOfFile)
	gsub(/\"/,"\\\"",previousDirName)
	
	
	if (typeOfFile == "d") {
		printf "\n\nDirectories are not allowed in find expression. Exiting...\n\n"
		exit
	}

	if (previousDirName == dirName) {
		# we are in the same dir
		printf ",\n{\"name\":\"%s\",\"dsize\":%d,\"ino\":%d}",nameOfFile,size,inode
		next
	}

	len1=split(previousDirName,aux1,"/")
	len2=split(dirName,aux2,"/")
	i=1
	while (i <= len1 && i <= len2 && aux1[i] == aux2[i]) 
		i++

	# find out how many dirs we have to close
	for (j=0; j < len1-i+1; j++)
		if (previousDirName != "./") printf "]"
	
	# and find out how many dirs we have to open
	for (j=i; j <= len2; j++) 
		printf ",\n[{\"name\":\"%s\"}",aux2[j]

	# and finally print file name
	printf ",\n{\"name\":\"%s\",\"dsize\":%d,\"ino\":%d}",nameOfFile,size,inode

}


END {
	a=split(dirName,aux,"/")
	for (i=0; i<a-1; i++) if (dirName != "./") printf "]"

	print "]]"
	printf "\n"
}

