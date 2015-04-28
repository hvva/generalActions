## Generic Action Finder
A small script to attempt to associate created digital artifacts with general user activities in a suspect system.
This script collects all keywords for files created/accessed/modified at a particular time range. These keywords
can be used to start to understand what actions where happing at the specified time.

### Requires
Sleuthkit (fls and mactime)

### Usage:
./genericActions.sh -b /tmp/body.txt -D "Apr 27 2015" -t "12:58" -d 5 -w 20

This command will search the mactime body file for all entries on Apr 27 2015, from
12:58 to 13:02 (-d 5), and will output 20 of the most common keywords for those 5 minutes.

### Create a [body file](http://wiki.sleuthkit.org/index.php?title=Body_file)
With sleuthkit installed:
* fls -r -m / [targetDrive]
* fls -m "C:/" -o 63 -r images/disk.dd > body.txt
* fls -o 63 -f openbsd -m / -r images/disk.dd > body.txt
* fls -o 3233664 -f openbsd -m /var/ -r images/disk.dd >> body.txt

For more information see: http://wiki.sleuthkit.org/index.php?title=Timelines
