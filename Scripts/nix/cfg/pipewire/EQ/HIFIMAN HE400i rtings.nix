{
	"nodes" = [
		{
			"name" = "eq_preamp";
			"type" = "builtin";
			"label" = "bq_highshelf";
			"control" = {
				"Freq" = 0;
				"Q"    = 1;
				"Gain" = -6.5;
			};
		}
		{
			"name" = "eq_band1";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 26;
				"Q"    = 0.63;
				"Gain" = 6.3;
			};
		}
		{
			"name" = "eq_band2";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 195;
				"Q"    = 0.94;
				"Gain" = -1.7;
			};
		}
		{
			"name" = "eq_band3";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 1969;
				"Q"    = 3.02;
				"Gain" = 4.3;
			};
		}
		{
			"name" = "eq_band4";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 4576;
				"Q"    = 5.65;
				"Gain" = 1.2;
			};
		}
		{
			"name" = "eq_band5";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 19305;
				"Q"    = 0.72;
				"Gain" = -6.7;
			};
		}
		{
			"name" = "eq_band6";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 502;
				"Q"    = 5.94;
				"Gain" = 1.3;
			};
		}
		{
			"name" = "eq_band7";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 3026;
				"Q"    = 2.89;
				"Gain" = -1.7;
			};
		}
		{
			"name" = "eq_band8";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 4109;
				"Q"    = 0.57;
				"Gain" = 0.7;
			};
		}
		{
			"name" = "eq_band9";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 6750;
				"Q"    = 4.44;
				"Gain" = -2.9;
			};
		}
		{
			"name" = "eq_band10";
			"type" = "builtin";
			"label" = "bq_peaking";
			"control" = {
				"Freq" = 10278;
				"Q"    = 2.07;
				"Gain" = 1.4;
			};
		}
	];
	"links" = [
		{ "output" = "eq_preamp:Out"; "input" = "eq_band1:In"; }
		{ "output" = "eq_band1:Out"; "input" = "eq_band2:In"; }
		{ "output" = "eq_band2:Out"; "input" = "eq_band3:In"; }
		{ "output" = "eq_band3:Out"; "input" = "eq_band4:In"; }
		{ "output" = "eq_band4:Out"; "input" = "eq_band5:In"; }
		{ "output" = "eq_band5:Out"; "input" = "eq_band6:In"; }
		{ "output" = "eq_band6:Out"; "input" = "eq_band7:In"; }
		{ "output" = "eq_band7:Out"; "input" = "eq_band8:In"; }
		{ "output" = "eq_band8:Out"; "input" = "eq_band9:In"; }
		{ "output" = "eq_band9:Out"; "input" = "eq_band10:In"; }
	];
	"inputs" = [ "eq_preamp:In" ];
	"outputs" = [ "eq_band10:Out" ];
}
