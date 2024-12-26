package lineprompt

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"runtime/debug"
	"testing"

	"github.com/lucasb-eyer/go-colorful"
)

func init() {
	debug.SetGCPercent(-1)
}

func BenchmarkLinePrompt(b *testing.B) {
	const width = 100
	var gradient = []colorful.Color{
		rgba(85, 205, 252, 1),
		rgba(147, 194, 255, 1),
		rgba(200, 181, 245, 1),
		rgba(234, 171, 217, 1),
		rgba(247, 148, 168, 1),
	}

	var lods = []int{25, 50, 75, 100}

	var writer = bufio.NewWriterSize(ioutil.Discard, 0)

	for _, lod := range lods {
		b.Run(fmt.Sprint("LOD", lod), func(b *testing.B) {
			for i := 0; i < b.N; i++ {
				Blend(writer, width, nil, lod, gradient)
			}
		})
	}
}

func rgba(r, g, b, a uint8) colorful.Color {
	return colorful.Color{
		R: float64(r) / 255,
		G: float64(g) / 255,
		B: float64(b) / 255,
	}
}
