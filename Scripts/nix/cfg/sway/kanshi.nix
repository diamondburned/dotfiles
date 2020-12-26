{
	disable = criteria: {
		inherit criteria;
		status = "disable";
	};

	enable = criteria: {
		inherit criteria;
		status = "enable";
	};

	position = criteria: position: {
		inherit criteria position;
		status = "enable";
	};
}
