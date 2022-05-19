md5b64() {
	read -d ' ' hexsum < <(md5sum "$1")

	b64sum=$(
		base64 < <(
			for ((i = 0; i < ${#hexsum}; i += 2)); {
				printf "\\x${hexsum:$i:2}"
			}
		)
	)

	echo -n "${b64sum%%=*}" # Trim trailing equals
}
