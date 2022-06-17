#!/usr/bin/env bash
regexPreamp="(-?[0-9.]+) dB"
regexFilter="ON ([A-Z]*) Fc ([0-9]+) Hz Gain (-?[0-9.]+) dB Q ([0-9.]+)"

main() {
	[[ "$1" ]] || fatal "Usage: $(basename "$0") <path to ParametricEQ.txt>"

	n=0

	cat<<'EOF'
{
	"nodes" = [
EOF

	while read -r line; do
		IFS=": " read -r keyword value <<< "$line"	

		case "$keyword" in
		Preamp)
			[[ $value =~ $regexPreamp ]] || fatal "Invalid preamp $value"
			dB="${BASH_REMATCH[1]}"
			printEQNode "eq_preamp" "bq_highshelf" 0 1 "$dB"
			;;
		Filter)
			[[ $value =~ $regexFilter ]] || fatal "Invalid filter $value"
			local label="${BASH_REMATCH[1]}"
			local freq="${BASH_REMATCH[2]}"
			local gain="${BASH_REMATCH[3]}"
			local q="${BASH_REMATCH[4]}"
			[[ $label != PK ]] && fatal "Unsupported EQ type $label"
			(( n++ ))
			printEQNode "eq_band$n" "bq_peaking" "$freq" "$q" "$gain"
			;;
		*)
			fatal "Unknown keyword $keyword"
		esac
	done < "$1"

	cat<<'EOF'
	];
	"links" = [
EOF

	lastOutput="eq_preamp"
	for ((i = 1; i <= n; i++)); {
		cat<<EOF
		{ "output" = "$lastOutput:Out"; "input" = "eq_band$i:In"; }
EOF
		lastOutput="eq_band$i"
	}

	cat<<EOF
	];
	"inputs" = [ "eq_preamp:In" ];
	"outputs" = [ "eq_band$n:Out" ];
}
EOF
}

# printEQNode name label freq Q gain
printEQNode() {
	local name="$1"
	local label="$2"
	local freq="$3"
	local q="$4"
	local gain="$5"

	cat<<EOF
		{
			"name" = "$name";
			"type" = "builtin";
			"label" = "$label";
			"control" = {
				"Freq" = $freq;
				"Q"    = $q;
				"Gain" = $gain;
			};
		}
EOF
}

fatal() {
	echo "$@" 2&>1
	exit 1
}

main "$@"
