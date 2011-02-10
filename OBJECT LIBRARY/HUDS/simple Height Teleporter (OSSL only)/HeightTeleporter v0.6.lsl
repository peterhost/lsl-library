key me;
vector position;
vector newPos;
float TPheight;
vector lookAt;
string sliderName = "slidingbar"; // change this to reflect your settings

integer sliderReady = FALSE; // becomes true when slider has sent the "ready" message

vector readyC   = <0.5, 1.0, 0.5>;
vector onC      = <1.0, 0.0, 0.0>;
vector initC    = <0.5, 0.5, 1>;
vector busyC    = <0.5, 0.5, 0.5>;
vector blinkC   = <1.0, 1.0, 1.0>;

updateTPinfos() {
    position = llList2Vector( llGetObjectDetails(me, [OBJECT_POS]),0 ); 
    lookAt = llList2Vector( llGetObjectDetails(me, [OBJECT_ROT]),0 );
    lookAt.x = 1;
    lookAt.y = 1; 
    newPos = position;
    if( (position.z + TPheight) >= 0) newPos.z += (float)TPheight;
    else newPos.z = (float)0;
    
    llOwnerSay("tp from" + (string)position + " to " + (string)newPos + "  " + (string)TPheight + "\nrotation : " + (string)lookAt);
    
}

init() {
    me = llGetOwner();
    if (sliderReady) llSetColor(readyC, ALL_SIDES);
    else {
        llSetColor(initC, ALL_SIDES);
        llSetText("initializing", initC,1);
    }
    llSetAlpha(1, ALL_SIDES);
    updateTPinfos();
    llSetTimerEvent(0.5); // wait till slider is ready to operate

}


default
{
    state_entry()
    {
        init();        
    }
    
    on_rez(integer n) {
        sliderReady = FALSE;
        init();
    }
    
    // Teleport Height update from slider
    link_message( integer sibling, integer num, string mesg, key mesg2 ) {
        
        if ( mesg == sliderName ) {
            if (mesg2 == "initializing") {
                sliderReady = FALSE;
                llSetColor(busyC, ALL_SIDES);
                
            }
            else if (mesg2 == "ready") {
                sliderReady = TRUE;
                llSetColor(readyC, ALL_SIDES);
                llSetText("ready!", readyC,1);
                llMessageLinked(LINK_ALL_CHILDREN,0, "tellPosition", ""); // read slider position (asynchronous)
                llSleep(0.5);
                llSetText("", readyC,1);
            }
            else {
                llSetColor(blinkC, ALL_SIDES);
                TPheight = mesg2;
                llSleep(0.1);
                llSetColor(readyC, ALL_SIDES);
            }          
        }
    }
    
    timer() {
       if ( sliderReady) llSetTimerEvent(0);// remove the timer when slider is ready
       else llMessageLinked(LINK_ALL_CHILDREN,0, "tellState", ""); // ask for slider's state
    }
    
    touch_start(integer n) {
        if (sliderReady) {
            llSetColor(onC, ALL_SIDES);
            updateTPinfos();
        }
        else {
            llSetText("wait a sec :)", initC,1);
        }   
    }
    touch_end(integer n) {
        if (sliderReady) state busy; // change state to clear event queue and not pile teleport requests onto one another
    }

    
}

state busy {
    state_entry() {
        llSetAlpha(0.5, ALL_SIDES);
        llSetText("recovering", <0.5,0.5,0.5>,1);
        llSetColor(busyC, ALL_SIDES);
        llMessageLinked(LINK_ALL_CHILDREN,0, "hideSL", ""); // hide slider
        osTeleportAgent(me, newPos, lookAt);
        llMessageLinked(LINK_ALL_CHILDREN,0, "showSL", ""); // show slider
        llSetText("", <0.5,0.5,0.5>,1);
        state default; 
    }   
}