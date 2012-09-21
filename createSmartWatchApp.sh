#!/bin/bash
set -e

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo Usage: "`basename $0` /path/to/project ProjectName com.project.yourpackage (shortname)"
    exit 1
fi

script=$(readlink -f $0)
srcpath=`dirname $script`

path="$1"
projectname="$2"
package="$3"
packagepath=`echo "$3" | sed 's/\./\//g'`
shortname="$4"

echo "This will create a project with the following settings:"
echo "  Path: $path"
echo "  Name: $projectname"
echo "  Package: $packagepath"
if [ -n "$shortname" ]; then
echo "  Short name: $shortname"
fi

mkdir -p $1

tmpspace=`mktemp -d`
pushd $tmpspace >/dev/null
echo "Unzipping resources..."
unzip $srcpath/samples/SampleControlExtension.zip >/dev/null
shopt -s dotglob nullglob
mv $tmpspace/SampleControlExtension/* $1/
rm -rf SampleControlExtension
popd >/dev/null


function searchnreplace {
    find ./ -iname "*.xml" -o -iname "*.java" -o -iname .project | xargs -i sed -i $1 {}
}

pushd $1 >/dev/null
searchnreplace "s/SampleControlExtension/ProjectName/g"
searchnreplace "s/com.sonyericsson.extras.liveware.extension.controlsample/$package/g"

mv src/com/sonyericsson/extras/liveware/extension/controlsample $tmpspace
rm -rf src/com
mkdir -p src/$packagepath
mv $tmpspace/controlsample/* src/$packagepath

if [ -n "$shortname" ]; then
    javaprefix="$shortname"
else
    javaprefix="$projectname"
fi

mv src/$packagepath/ExtensionReceiver.java src/$packagepath/${javaprefix}ExtensionReceiver.java
mv src/$packagepath/SampleControlSmartWatch.java src/$packagepath/${javaprefix}SWControl.java
mv src/$packagepath/SampleExtensionService.java src/$packagepath/${javaprefix}ExtensionService.java
mv src/$packagepath/SamplePreferenceActivity.java src/$packagepath/${javaprefix}PreferenceActivity.java
mv src/$packagepath/SampleRegistrationInformation.java src/$packagepath/${javaprefix}RegistrationInformation.java

searchnreplace "s/ExtensionReceiver/${javaprefix}ExtensionReceiver/g"
searchnreplace "s/SampleControlSmartWatch/${javaprefix}SWControl/g"
searchnreplace "s/SampleExtensionService/${javaprefix}ExtensionService/g"
searchnreplace "s/SamplePreferenceActivity/${javaprefix}PreferenceActivity/g"
searchnreplace "s/SampleRegistrationInformation/${javaprefix}RegistrationInformation/g"

rm -rf $tmpspace
