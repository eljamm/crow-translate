#!/bin/sh

. /etc/os-release

cleanDir()
{
		make clean
        rm crow
        rm .qmake.stash
        rm Makefile
}

case $ID in
	"arch" | "parabola" | "manjarolinux" )
        cd archlinux
	
        makepkg
        rm -r pkg
        rm -r src
        cd ../../..
        cleanDir
	
        echo -e "\x1b[1;32mNow you can install Crow by running the following commands:\x1b[0m"
        echo -e "\x1b[1;37mcd archlinux\x1b[0m"
        echo -e "\x1b[1;37msudo pacman -U crow-git-*.pkg.tar.xz\x1b[0m"
    ;;
	
	"ubuntu" | "linuxmint" | "elementary" | "debian" | "devuan" )
		if [ -z $(which debuild) ]; then
			echo "Package devsripts REQUIRED for building:"
			sudo apt install devscripts
			
			[ "$?" -eq 1 ] && echo "You can still install it by yourself." && exit 0
		fi
		
		tar czfv crow_$(awk 'NR==1 {print $2}' dist/unix/debian/changelog | sed 's/-[1-9]//g;s/[()]//g').orig.tar.gz *
		mv crow_*.orig.tar.gz ..
		cp -r dist/unix/debian .
		debuild -i -us -uc
		rm -rf debian
		cleanDir
		
        echo -e "\x1b[1;32mNow you can install Crow by running the following commands:\x1b[0m"
        echo -e "\x1b[1;37mcd ../../..\x1b[0m"
        echo -e "\x1b[1;37msudo dpkg -i crow-*-amd64.deb\x1b[0m"
        echo -e "\x1b[1;37msudo apt install -f\x1b[0m"
	;;
	
	"fedora" )
	echo -e "\x1b[1;31mSorry, package generation for your distribution temporally unsupported\x1b[0m"
	;;
	
	*)
		echo -e "\x1b[1;37mCan't determine your distribution. The project will be compiled and installed in the \"install\" folder.\x1b[0m"
		
		CORES="$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)"
		
		qmake
		make -j$CORES		
		mkdir ../install
		PREFIX=../install make install
		cleanDir
		echo -e "\x1b[1;32mCrow was successfully installed in the \"install\" folder\x1b[0m"
	;;
esac
