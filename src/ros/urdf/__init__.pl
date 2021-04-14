
:- use_module('URDF').
:- ( setting(mng_client:read_only, true)
	->	true
	;	urdf_init).