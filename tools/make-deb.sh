#!/bin/bash

echo -en "\033[37;1;41mCheck dependencies...\033[0m\n"
if ! dpkg -l | grep md5deep
then
	sudo apt-get install md5deep
fi
if ! dpkg -l | grep debhelper
then
	sudo apt-get install debhelper
fi
if ! dpkg -l | grep cmake
then
	sudo apt-get install cmake
fi
if ! dpkg -l | grep make
then
	sudo apt-get install make
fi
if ! dpkg -l | grep fakeroot
then
	sudo apt-get install fakeroot
fi

echo -en "\033[37;1;41mBuild binary...\033[0m\n"
cd ../
cmake CMakeLists.txt
make

echo -en "\033[37;1;41mCreate temporary directory for package and copy required files...\033[0m\n"
cd ./tools/

# Making catalog structure 
mkdir -p ./kbe/usr/share/kbe
mkdir -p ./kbe/usr/bin
mkdir -p ./kbe/usr/share/applications
mkdir -p ./kbe/usr/share/pixmaps

# Copying needed files into catalog structure
cp -r ./DEBIAN ./kbe/
mv -f ../media ./kbe/usr/share/kbe/
mv -f ../kbe ./kbe/usr/share/kbe/
cp ./files/kbe.desktop ./kbe/usr/share/applications/
cp ./files/kbe.xpm ./kbe/usr/share/pixmaps/

# Making symbolic link to our binary file from /user/share/
ln -s /usr/share/kbe/kbe ./kbe/usr/bin/kbe

echo -en "\033[37;1;41mMake *.deb pachage...\033[0m\n"
cd ./kbe
md5deep -r -l usr/share > ./DEBIAN/md5sums
cd ..
fakeroot dpkg-deb --build kbe

echo -en "\033[37;1;41mRemove temporary data...\033[0m\n"
rm -r ../CMakeFiles ../sources/*/*.cxx ../sources/*.cxx ./kbe
rm ../cmake_install.cmake ../CMakeCache.txt ../Makefile ../ui_mainwindow.h

echo -en "\033[37;1;41mkbe.deb package is built\033[0m\n"
