{
	disable = criteria: {
		inherit criteria;
		status = "disable";
	};

	enable = criteria: props: (props // {
		inherit criteria;
		status = "enable";
	});

	output = criteria: {
		inherit criteria;
		status = null;
	};

	position =  criteria: position: scale: {
		inherit criteria position scale;
		status = "enable";
	};
}
