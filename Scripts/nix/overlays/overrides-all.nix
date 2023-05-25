self: super:

let
	lib = self.lib;
in

{
	gnvim = super.callPackage ./packages/gnvim { };
}
