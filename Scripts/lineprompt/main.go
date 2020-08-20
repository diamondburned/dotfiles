package main

import (
	"bufio"
	"os"

	"github.com/lucasb-eyer/go-colorful"
	"gitlab.com/diamondburned/lineprompt/lineprompt"
)

func main() {
	// Lower means more details, must be higher than len(blends)
	const LOD = 35

	var text []byte
	if len(os.Args) > 1 {
		text = []byte(os.Args[1])
	}

	var output = bufio.NewWriterSize(os.Stdout, 512)
	defer output.Flush()

	lineprompt.Blend(output, lineprompt.Columns(), text, LOD, []colorful.Color{
		rgba(85, 205, 252, 1),
		rgba(147, 194, 255, 1),
		rgba(200, 181, 245, 1),
		rgba(234, 171, 217, 1),
		rgba(247, 148, 168, 1),
	})
}

func rgba(r, g, b, a uint8) colorful.Color {
	return colorful.Color{
		R: float64(r) / 255,
		G: float64(g) / 255,
		B: float64(b) / 255,
	}
}
