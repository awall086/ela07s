# =============================== DEFINITIONS ===========================================
# set the update period

var UPDATE_PERIOD = 0.3;


var update_pax = func {
    var state = 0;
    state = bits.switch(state, 0, getprop("pax/pilot/present"));
    state = bits.switch(state, 1, getprop("pax/co-pilot/present"));
    setprop("/payload/pax-state", state);
};



##########################################
# Click Sounds
##########################################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/model/c170b/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after 0.2 seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

setlistener("/pax/pilot/present", update_pax, 0, 0);
setlistener("/pax/co-pilot/present", update_pax, 0, 0);
update_pax();

