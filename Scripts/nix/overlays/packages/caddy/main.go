package main

import (
	caddycmd "github.com/caddyserver/caddy/v2/cmd"

	_ "github.com/caddy-dns/cloudflare"
	_ "github.com/caddy-dns/namecheap"
	_ "github.com/caddy-dns/netlify"
	_ "github.com/caddyserver/caddy/v2/modules/standard"
	_ "github.com/mholt/caddy-dynamicdns"
	// _ "github.com/tailscale/caddy-tailscale"
)

func main() {
	caddycmd.Main()
}
