#Electrical System
var electricsystem=func{
    var pneumtic_pump = getprop("/yasim/ela07s/pneumatic-switch");
	var rotorbrake_switch = getprop("/yasim/ela07s/rotorbrake-switch");
	var master_bat = getprop("/controls/switches/master-bat");
    var master_alt = getprop("/controls/switches/master-alt");
	var battery_status = getprop("/systems/ela07s/electrical/battery-status");
	var new_battery_status = battery_status;
	var external_volts = 0;
	var external_amps = 0;
	var pneumatic_pressure = getprop("/systems/ela07s/pneumatic/pneumatic-press");
	var new_pneumatic_pressure = pneumatic_pressure;

	

	# external power source connected
    if (getprop("/controls/electric/external-power"))
    {
        external_volts = 14;
        external_amps = 35; 
 }
	
	var engine_rpm = getprop("/engines/engine/rpm");
	var ideal_rpm = 1300;	
	var ideal_volts = 12;
	var ideal_amps = 35;
	var bus_load = 0;
	var factor = engine_rpm/ideal_rpm;
	if (factor > 1.0) {
		factor = 1.0;
	}


	var alternator_volts = ideal_volts * factor;
	var alternator_amps = ideal_amps * factor;
 
       if ( master_alt == 0 ){
 		var alternator_volts = 0;
		var alternator_amps = 0;
	}


    # determine power source
    	var bus_volts = 0.0;
		var battery_volts = (12.0 * battery_status)/100;
		var battery_amps = (26.0 * battery_status)/100;
    	var power_source = nil;	


    if ( master_bat ) {
        bus_volts = battery_volts;        
		power_source = "battery";
    }
    if ( master_alt and (alternator_volts > bus_volts) ) {
        bus_volts = alternator_volts;
		bus_load += alternator_amps;
        power_source = "alternator";
    }
    if ( master_bat and (external_volts > bus_volts ) ) {
        bus_volts = external_volts;
		bus_load += external_amps;
        power_source = "external";
    }

    if ( power_source == "battery" ) {
		new_battery_status = battery_status - 0.0001;
		bus_load += battery_amps;
	}

    if ( power_source == "alternator" or power_source == "external") {
		new_battery_status = battery_status + 0.0001;
		if ( new_battery_status > 100.0 ) {
			new_battery_status = 100.0;
		}
	}
	
	#Electro-pneumatic rotorbrake system
	if ( ( battery_volts > 8 ) and pneumtic_pump ) {
		if ( rotorbrake_switch ) {
			new_pneumatic_pressure = pneumatic_pressure + 0.0004;
			if ( new_pneumatic_pressure > 1.0 ) {
				new_pneumatic_pressure = 1.0;
			}
		} else {
			new_pneumatic_pressure = pneumatic_pressure - 0.005;
			if ( new_pneumatic_pressure < 0 ) {
				new_pneumatic_pressure = 0;
			}
		}
	}
	
    # Instrument Power: ignition, fuel, oil temperature
    if ( getprop("/controls/circuit-breakers/instr") ) {
        setprop("/systems/ela07s/electrical/outputs/instr-ignition-switch", bus_volts);
		setprop("/systems/ela07s/electrical/outputs/comm[0]", bus_volts);
		setprop("/systems/ela07s/electrical/outputs/DG", bus_volts);
        if ( bus_volts > 8 ) {
            # starter
            if ( getprop("controls/engines/engine/starter-switch") ) {
                setprop("systems/electrical/outputs/starter", bus_volts);
            } else {
                setprop("systems/electrical/outputs/starter", 0.0);
            }
        } else {
            setprop("systems/electrical/outputs/starter", 0.0);
        }
    } else {
        setprop("/systems/ela07s/electrical/outputs/instr-ignition-switch", 0.0);
        setprop("/systems/ela07s/electrical/outputs/comm[0]", 0.0);
		setprop("/systems/ela07s/electrical/outputs/DG", 0.0);
		setprop("/systems/ela07s/electrical/outputs/starter", 0.0);
    }
     

    # Landing Light Power
    if ( getprop("/controls/circuit-breakers/landing_lt") ) {
        setprop("/systems/ela07s/electrical/outputs/landing-light", bus_volts);
		setprop("/systems/ela07s/electrical/outputs/strobe-lights", bus_volts);
    } else {
        setprop("/systems/ela07s/electrical/outputs/landing-light", 0.0 );
		setprop("/systems/ela07s/electrical/outputs/strobe-lights", 0.0);
    }

	setprop("/systems/ela07s/electrical/suppliers/battery", battery_volts);
	setprop("/systems/ela07s/electrical/suppliers/alternator", alternator_volts);
	setprop("/systems/ela07s/electrical/amps", alternator_amps);
	setprop("/systems/ela07s/electrical/bus_load", bus_load);
	setprop("/systems/ela07s/electrical/volts", bus_volts);
	setprop("/systems/ela07s/electrical/battery-status", new_battery_status);
	setprop("/systems/ela07s/pneumatic/pneumatic-press", new_pneumatic_pressure);
	setprop("/controls/rotor/brake", new_pneumatic_pressure);

	settimer(electricsystem, 0);
}

setlistener("sim/signals/fdm-initialized", electricsystem);



