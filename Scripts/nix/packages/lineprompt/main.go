package main

import (
	"bufio"
	"os"

	"github.com/lucasb-eyer/go-colorful"
	"gitlab.com/diamondburned/dotfiles/Scripts/lineprompt/lineprompt"
)

func main() {
	var text string
	if len(os.Args) > 1 {
		text = os.Args[1]
	}

	output := bufio.NewWriterSize(os.Stdout, 512)
	defer output.Flush()

	columns := lineprompt.Columns()
	opts := lineprompt.Opts{
		// Lower means more details, must be higher than len(blends)
		LOD:       35,
		Underline: true,
	}

	lineprompt.Blend(output, text, columns, []colorful.Color{
		rgba(85, 205, 252, 1),
		rgba(147, 194, 255, 1),
		rgba(200, 181, 245, 1),
		rgba(234, 171, 217, 1),
		rgba(247, 148, 168, 1),
	}, opts)
}

func rgba(r, g, b, a uint8) colorful.Color {
	return colorful.Color{
		R: float64(r) / 255,
		G: float64(g) / 255,
		B: float64(b) / 255,
	}
}
