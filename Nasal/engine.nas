#engine System
var enginesystem=func{

	var oil_tempf = getprop("/engines/engine/oil-temperature-degf");
	var env_tempf = getprop("/environment/temperature-degf");
	var eng_rpm = getprop("/engines/engine/rpm");
	var_new_eng_rpm = eng_rpm;
	var rotor_rpm = getprop("/rotors/main/rpm");
	var prerotator = getprop("/yasim/ela07s/prerotator");
	var cranking = 0;
	var running = 0;
	var fuel_pump = 0;
	var oil_pbar = 0;
	var fuel_press = getprop("/engines/engine/fuel-pressure-bar");	
	var new_fuel_press = fuel_press;
	
	if ( (oil_tempf!=nil) and (eng_rpm!=nil) and (env_tempf!=nil) ) {
	
		if ( oil_tempf  < env_tempf ) {
			var oil_tempc = ( ( env_tempf - 32 ) / 1.8 );
		} else {
			var oil_tempc = ( ( oil_tempf - 32 ) / 1.8 );
		}

		fuel_pump = getprop("/controls/fuel/tank/boost-pump");
		
		if ( eng_rpm > 550 ) {
			oil_pbar = ( 1.0 + ( oil_tempc * 0.025 ) + ( eng_rpm * 0.0001 ) );

			if ( fuel_pump ) {
				new_fuel_press = fuel_press + 0.005;
				if ( new_fuel_press > 0.24 ) {
					new_fuel_press = 0.24;
				}
				
				if ( eng_rpm < 2500 ) {
					new_fuel_press = fuel_press + ( eng_rpm * 0.00001 );
					if ( new_fuel_press > 0.415 ) {
						new_fuel_press = 0.415;
					}				
				} else {
					new_fuel_press = 0.415;
				}
			} else {
				if ( eng_rpm < 2500 ) {
					new_fuel_press = fuel_press + ( eng_rpm * 0.00001 );
					if ( new_fuel_press > 0.415 ) {
						new_fuel_press = 0.415;
					}
				} else {
					new_fuel_press = 0.475;
				}
			}
		} else {
			if ( fuel_pump ) {
				new_fuel_press = fuel_press + 0.005;
				if ( new_fuel_press > 0.24 ) {
					new_fuel_press = 0.24;
				}
			} else {
				new_fuel_press = fuel_press - 0.005;
				if ( new_fuel_press < 0.0 ) {
					new_fuel_press = 0.0;
				}
			}
		}

		if ( eng_rpm < 500 ) {
			setprop("/yasim/ela07s/prerotator", 0);
		}
		
		cranking = getprop("/engines/engine/cranking");
		running = getprop("/engines/engine/running");
		
		if ( cranking == 0 and  running == 0 and ( eng_rpm < 20 ) ) {
			setprop("/engines/engine/rpm", 0);
		}

		if ( prerotator and  eng_rpm > 500 ) {
			new_eng_rpm = eng_rpm - 20 / rotor_rpm;
			setprop("/engines/engine/rpm", new_eng_rpm);
		}
		
		setprop("/engines/engine/oil-temperature-degc", oil_tempc);
		setprop("/engines/engine/oil-pressure-bar", oil_pbar);
		setprop("/engines/engine/fuel-pressure-bar", new_fuel_press);
	}

	settimer(enginesystem, 0);
}

setlistener("sim/signals/fdm-initialized", enginesystem);
