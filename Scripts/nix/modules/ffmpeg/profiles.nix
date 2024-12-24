let
	input  = "%%INPUT%%";
	output = "%%OUTPUT%%";
in

{
	"mobile" = {
		description = ''VAAPI-accelerated video transcoding for Pixel-recorded videos'';
		flags = [
			"-hwaccel" "vaapi"
			"-hwaccel_device" "/dev/dri/renderD128"
			"-hwaccel_output_format" "vaapi"
			"-i" input
			"-c:v" "h264_vaapi"
			"-crf" "23"
			output
		];
	};
}
