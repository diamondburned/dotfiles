package lineprompt

import (
	"bytes"
	"io"
	"log"
	"math"
	"os"
	_ "unsafe"

	"github.com/lucasb-eyer/go-colorful"
	"golang.org/x/sys/unix"
)

var (
	header    = []byte("\033[38;2;")
	reset     = []byte("\033[0m")
	underline = []byte("\033[4m")
)

type rgb struct{ r, g, b uint8 }

type Writer interface {
	io.Writer
	io.ByteWriter
}

func Blend(w Writer, columns int, text []byte, lod int, blends []colorful.Color) {
	// Constrain LOD at columns.
	if lod > columns {
		lod = columns
	}

	// Precalculate colors according to the level of details.
	var colors = make([]rgb, 0, lod)
	var rgb rgb

	// We need to calculate the gradient pointer for each gradient segment. So
	// we can't use 1/perc*pos, as that only gets you the pointer for the entire
	// gradient at once.
	var segmentf64 = math.Ceil(float64(lod) / float64(len(blends)-1))
	var segmentLen = int(segmentf64)

	for blend := 0; blend < len(blends)-1; blend++ {
		for i := 0; i < segmentLen; i++ {
			start, end := blends[blend], blends[blend+1]
			rgb.r, rgb.g, rgb.b = start.BlendRgb(end, 1/segmentf64*float64(i)).RGB255()

			colors = append(colors, rgb)
			// log.Println(rgb, i, start, end, pos)
		}
	}

	// Chunk length.
	var chunkLen = int(math.Ceil(float64(columns) / float64(lod)))

	// Input text. In byte slices because. May not work because runecolumns.
	textbuf := bytes.Buffer{}
	textbuf.Write(text)

	// Pad the rest of the text slice.
	switch delta := columns - textbuf.Len(); {
	// If the input text is longer than the terminal:
	case delta < 0:
		// Cut it.
		textbuf.Truncate(columns)

	// If the input text is shorter than the terminal:
	case delta > 0:
		textbuf.Grow(delta)
		for i := 0; i < delta; i++ {
			textbuf.WriteByte(' ')
		}
	}

	// Print a new line that's underlined
	w.Write(underline)

	// Reuse the same bytes buffer to avoid copying.
	// var buf bytes.Buffer

	// LOD index to keep track of which color we're in.
	var lodIndex = 0

	// cap because formatBits appends
	var intbuf = make([]byte, 0, 3)

	// Lazy draw. Increment by chunk length.
	for i := 0; i < columns; i += chunkLen {
		// Print the color to use.
		rgb := colors[lodIndex]

		w.Write(header)
		w.Write(itoau8(intbuf, rgb.r))
		w.WriteByte(';')
		w.Write(itoau8(intbuf, rgb.g))
		w.WriteByte(';')
		w.Write(itoau8(intbuf, rgb.b))
		w.WriteByte('m')

		// Write the text.
		var end = min(i+chunkLen, textbuf.Len())
		w.Write(textbuf.Bytes()[i:end])

		// increment
		lodIndex++
	}

	w.Write(reset)
}

func getPair(blends []colorful.Color, current, total int) (start, end int) {
	i := current * (len(blends) - 1) / total
	return i, i + 1
}

func min(i, j int) int {
	if i < j {
		return i
	}
	return j
}

// WHAT THE FUCK AAAAAAAAAAAAAAAAAAAAa

//go:linkname formatBits strconv.formatBits
//go:noescape
func formatBits(dst []byte, u uint64, base int, neg, append_ bool) (d []byte, s string)

func itoau8(dst []byte, n uint8) []byte {
	d, _ := formatBits(dst, uint64(n), 10, false, true)
	return d
}

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
