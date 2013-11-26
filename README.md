Ncdu JSON generator
==================================

DESCRIPTION

	Ncdu JSON generator (njgen) searches files that matches a "find" expression and generates a 
	JSON file ready to import into ncdu program.


REQUIREMENTS

	- find (GNU findutils). The version I used to develop njgen is 4.4.2. Higher versions are
	 supposed to work
	- ncdu (NCurses Disk Usage). A program developed by Yoran Heling 
	(http://dev.yorhel.nl/ncdu) to see the disk usage with a ncurses interface. Although ncdu 
	is not mandatory, obviously you need it to import the JSON file generated by njgen. 
	The version I use is v1.10. I guess higher versions will work, but I cannot guarentee 
	since that programs does not depend on me. Only ncdu v1.9 and higher have the feautre of 
	importing json files.
	- awk (GNU awk). The version I use is 3.1.8. Higher versions are supposed to work
	- coreutils package. Shipped with almost Linux distros. Used for example to create temp 
	files with `mktemp'


INSTALLATION

	No install needed. Simply chmod'it +x and exec


USAGE
	
	With no arguments, njgen will print in the standard output the json file with all the 
	files in the current directory subtree. The info and warning messages are printed to the 
	error standard output, so to save the JSON file you only have to redirect the standard 
	input to the desired file:

		njgen.sh > myFile

	The most useful feature of njgen is to pass "GNU find" expressions to filter the files 
	you are interested in. For example:

		njgen.sh -atime +365 -mtime +365 -size +4G > myFile

	will look for files bigger than 4GB that have not been accesed nor modified in the last 
	year, and save JSON info in `myFile'. Later, you can import with "ncdu -f myFile" and 
	view the list with a friendly ncurses interface

	Since v1.3, njgen accepts the --saveFilenames <filename> option (abbreviated as -s). With 
	this option, njgen saves each filename (with the full path) into <filename>. This is 
	useful for example if you run njgen in a large directory and you want to save the file 
	names to process them later.


COPYING

  Copyright (c) 2013 Miguel Gutiérrez

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


CHANGELOG

	v1.1 - 2013/09/04 - almost the very first version. A lot of bugs will be detected soon :-) No 
	help available
	v1.2 - 2013/09/04 - too soon, the first bug ;-) Problems with wildcards related to 
	bash expansion
	v1.3 - 2013/09/04 - added --saveFilenames (-s) option
