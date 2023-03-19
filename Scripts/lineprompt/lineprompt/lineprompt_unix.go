//go:build aix || darwin || dragonfly || freebsd || linux || netbsd || openbsd || solaris
// +build aix darwin dragonfly freebsd linux netbsd openbsd solaris

package lineprompt

import (
	"log"
	"os"

	"golang.org/x/sys/unix"
)

// Columns polls the terminal column size using TIOCGWINSZ.
func Columns() int {
	f, err := os.Open("/dev/tty")
	if err != nil {
		log.Fatalln("Failed to open /dev/tty:", err)
	}
	defer f.Close()

	sz, err := unix.IoctlGetWinsize(int(f.Fd()), unix.TIOCGWINSZ)
	if err != nil {
		log.Fatalln("Failed to get winsz:", err)
	}

	return int(sz.Col)
}
