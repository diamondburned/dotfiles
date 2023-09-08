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

	var output = bufio.NewWriterSize(os.Stdout, 512)
	defer output.Flush()

	columns := lineprompt.Columns()
	opts := lineprompt.Opts{
		// Lower means more details, must be higher than len(blends)
		LOD: 35,
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

/*
func parseColor(color string) (colorful.Color, error) {
	switch {
	case strings.HasPrefix(color, "#"):
		return colorful.Hex(color)

	case strings.HasPrefix(color, "rgb"):
		var r, g, b float64
		_, err := fmt.Sscanf(color, "rgb(%f, %f, %f)", &r, &g, &b)
		return colorful.FastLinearRgb(r, g, b), err

	case strings.HasPrefix(color, "rgba"):
		var r, g, b, a float64
		_, err := fmt.Sscanf(color, "rgba(%f, %f, %f, %f)", &r, &g, &b, &a)
		return colorful.FastLinearRgb(r, g, b), err

	default:
		return colorful.Color{}, fmt.Errorf("unknown error %q", color)
	}
}
*/

func rgba(r, g, b, a uint8) colorful.Color {
	return colorful.Color{
		R: float64(r) / 255,
		G: float64(g) / 255,
		B: float64(b) / 255,
	}
}
