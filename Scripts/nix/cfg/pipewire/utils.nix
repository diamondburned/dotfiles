lib:

{
	filterChains = eqs: lib.mapAttrsToList (name: v: {
		name = "libpipewire-module-filter-chain";
		args = lib.recursiveUpdate {
			"media.name"          = name;
			"node.description"    = name;
			"filter.graph"        = v.graph;
			"audio.format"        = v.audio.format;
			"audio.rate"          = v.audio.rate;
			"audio.allowed-rates" = v.audio.allowedRates;
			"capture.props" = {
				"media.class"  = "Audio/Sink";
				"node.name"    = v.short + "-sink.eq";
				"node.passive" = true;
			};
			"playback.props" = {
				"stream.dont-remix" = true;
				"node.name"         = v.short + "-output.eq";
				# "node.target"       = v.target;
				"node.passive"      = true;
			};
		} v.args;
	}) eqs;

	alsaMonitorRules = eqs: lib.mapAttrsToList (name: v: {
		matches = [ { "node.name" = v.target; } ];
		actions = {
			"update-props" = {
				"audio.format"         = v.audio.format;
				"audio.rate"           = v.audio.rate;
				"audio.allowed-rates"  = v.audio.allowedRates;
				"api.alsa.period-size" = v.audio.periodSize;
			};
		};
	}) eqs;
}
