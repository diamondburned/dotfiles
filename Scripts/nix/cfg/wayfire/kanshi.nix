{
	disable = criteria: {
		inherit criteria;
		status = "disable";
	};

	enable = criteria: props: (props // {
		inherit criteria;
		status = "enable";
	});

	position =  criteria: position: scale: {
		inherit criteria position scale;
		status = "enable";
	};
}
