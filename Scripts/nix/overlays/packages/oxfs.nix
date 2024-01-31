{ lib, fetchPypi, python3 }:

python3.pkgs.buildPythonApplication rec {
	pname = "oxfs";
	version = "0.5.5";

	src = fetchPypi {
		inherit pname version;
		sha256 = "sha256-iHtUfrf91vr5UOn5vr6679OsGh5xipgbCeCRxluf9Pc=";
	};

	propagatedBuildInputs = with python3.pkgs; [
		xxhash
		fusepy
		paramiko
	];
}
