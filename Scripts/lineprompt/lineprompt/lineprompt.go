package lineprompt

import (
	"bytes"
	"io"
	"math"

	_ "unsafe"

	"github.com/lucasb-eyer/go-colorful"
)

var (
	header    = []byte("\033[38;2;")
	reset     = []byte("\033[0m")
	underline = []byte("\033[4m")
)

type rgb struct{ r, g, b uint8 }

// Writer is an interface that combines io.Writer and io.ByteWriter.
type Writer interface {
	io.Writer
	io.ByteWriter
}

// Opts are options for the prompt.
type Opts struct {
	// LOD is the level of detail of the blend. The higher the LOD, the more
	// steps within the gradient will be used to blend the text.
	LOD int
	// Underline is whether the prompt should be underlined.
	Underline bool
}

// DefaultOpts are the default options for the prompt.
var DefaultOpts = Opts{
	LOD:       20,
	Underline: true,
}

// Blend writes text to w with a text color that is blended between the
// provided colors. LOD controls the level of detail of the blend, or the number
// of steps between the two colors. The blend is linear, so the colors will be
// evenly distributed between the two colors.
func Blend(w Writer, text string, columns int, blends []colorful.Color, opts Opts) {
	// Constrain LOD at columns.
	if opts.LOD == 0 {
		opts.LOD = 20
	}
	if opts.LOD > columns {
		opts.LOD = columns
	}
	if opts.LOD < len(blends) {
		opts.LOD = len(blends)
	}

	flod := float64(opts.LOD)

	// Precalculate colors according to the level of details.
	colors := make([]rgb, 0, opts.LOD)
	var rgb rgb

	// We need to calculate the gradient pointer for each gradient segment. So
	// we can't use 1/perc*pos, as that only gets you the pointer for the entire
	// gradient at once.
	var segmentf64 = math.Ceil(flod / float64(len(blends)-1))
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
	chunkLen := int(math.Ceil(float64(columns) / flod))

	// Input text. In byte slices because. May not work because runecolumns.
	textbuf := bytes.Buffer{}
	textbuf.WriteString(text)

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
	if opts.Underline {
		w.Write(underline)
	}

	// Reuse the same bytes buffer to avoid copying.
	// var buf bytes.Buffer

	// LOD index to keep track of which color we're in.
	var lodIx int

	// cap because formatBits appends
	intbuf := make([]byte, 0, 3)

	// Lazy draw. Increment by chunk length.
	for i := 0; i < columns; i += chunkLen {
		// Print the color to use.
		rgb := colors[lodIx]

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
		lodIx++
	}

	w.Write(reset)
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
