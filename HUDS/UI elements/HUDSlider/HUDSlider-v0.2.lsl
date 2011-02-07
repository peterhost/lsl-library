//*********************************************************************
//                                                                    *
///                       --HUD Slider--                              *
//                                                                    *
//*********************************************************************
// HUD Slider - v 0.2
// Highly customizable Sliding Bar
//
// by:          Peter Host (Pete Atolia inworld)
// License:     BSD, but please provide patches/bugfixes if you can!
//
// Description: provides a slider in one prim to be linked to a HUD
//              or standalone.
//              Slider either sends its position (0-100 number) :
//                  - on chat channel (default)
//                  - as llMessageLinked()
//                  - to an avatar, by IM
//              You can customize the result's scale to whatever you like
//              in the "//custom scale" section
//
// Usage: 1) add the texture in the same directory to a prim cube
//           ("slidingbar-grey.png")
//        2) place this script in the prim
//        3) let the script initialize 
//        4) do whatever you want with the slider
//
// Nota :   this slider both supports touch and drag, though drag
//          might be slow according to what region-server/script-engine
//          the script runs in
//____________________________________________________________________
//                          GLOBAL variables
//....................................................................
//                         USER
//....................................................................


//.................
// slider UI params
vector primPos = <0.5,0,0>; // only the x comonent (slider initial
                            // position) matters

float primscale = .5;       // the prim's size (positive number)
                            // 1 = medium, 0.5 = small, 2 = big
                            
integer resetOnRez = TRUE;  // disable if you don't want the prim to be 
                            // resized to 'primScale' on prim Rez
                            // as texture positioning on a slider is tricky
                            // you might need it to restore the defaults
integer resetOnScriptInit = TRUE; // same for script init
                            
integer textOn = TRUE;      // false to disable percentage display


//.....................
// slider color/texture
string sliderTexture;       // put a name here if you wish the HUD to
                            // use a specific texture instead of the
                            // first one it finds. In which case, you
                            // should set resetOnRez to FALSE 

                            // three zones defining slider's color
integer slowLimit = 20;     //%  blue (0-100)
integer safeLimit = 60;     //%  green (0-100)
                            // over that : red

integer primCOn = TRUE;     // FALSE to disable slider color change

integer disableDrag = FALSE;// TRUE to disable dragging slider

//.............
// custom scale

                            // by default the slider annouces an integer number
                            // between 0 and 100. If you wish for it to announce
                            // something else, set the following two parameters.
                            // [100, 0], [0.1, -0.5], [12, 24.999],...
                            // NB : these parameters only affect slider's output 
                            //      (hovering text and message), all inner functions
                            //      still use a [0-100] integer (slowLimit, safeLimit,...)
float minScale;
float maxScale;
string scaleUnit = "%";     // change to whatever your scale unit is, or ""

//..............
// communication
                                        // choose one :
integer communicationMethod = 0;        // 0 : llMessageLinked(...)
                                        // 1 : llSay(message, HUDchannel);
                                        // 2 : llInstantMessage() --> NB : only touch_end() updating due
                                        //                                 to the 2 sec. delay
                                        // then set one of these :
integer linkedTarget = LINK_ALL_OTHERS; // --> prim(s) to report to if communicationMethod is set to "0"
                                        //     LINK_ROOT, LINK_SET, LINK_ALL_OTHERS, LINK_ALL_CHILDREN,
                                        //     LINK_THIS, or prim linknumber
integer HUDchannel = 999;               // --> channel to report to if communicationMethod is set to "1"
integer regionWide = FALSE;             // --> TRUE : use llRegionSay instead of llSay if communicationMethod
                                        //     is set to "1". NB : HUDchannel can't be set to 0 (PUBLIC_CHANNEL)
key controllerAgent = "";               // --> key of avatar to report to if communicationMethod is set to "2"
                                        //     (default is script owner)

//......
// debug
integer debug = FALSE;           

                                 
//....................................................................
//                         COMPUTED
//....................................................................

vector UV;
integer percent = 50;       // the slider's (output) value
vector textColor;
vector primColor;
key me;
string meName;
float converted;            // converted output value in case minScale/maxScale are used

//____________________________________________________________________
//                          Initialization
//....................................................................

init() {
    reloadTexture();
    
    llSetTexture(TEXTURE_TRANSPARENT,0);
    llSetTexture(TEXTURE_TRANSPARENT,1);
    llSetTexture(TEXTURE_TRANSPARENT,3);
    // eye candy for HUD
    if (!llGetAttached()){
        llSetTexture(TEXTURE_TRANSPARENT,2);
        llSetTexture(TEXTURE_TRANSPARENT,4);
    }
    
    // a virer
    llSetColor(<1,1,1>, ALL_SIDES);
    
    // TEXTURES
    //note: face indexes for HUD attachement of this object
    
    llSetTexture(sliderTexture, 5);
    // eye candy for HUD
    if (llGetAttached()) {
        llSetTexture(sliderTexture, 2);
        llSetTexture(sliderTexture, 4);
    }

    //front face (5)

    llOffsetTexture(0,0,5);
    llScaleTexture(1,0.333333,5);
    llSetText("", <1,0,0>, 0.5);
    
    llOffsetTexture(0.5 - primPos.x, 0.666, 5); // hover effect
    llOffsetTexture(0.5 - primPos.x, 0, 5);     // do this so that it's "loaded"
    

    //right face (2)
    
    llScaleTexture(0.02,0.333333,2);
    llRotateTexture(-PI_BY_TWO, 2);
    llOffsetTexture(-0.02,0.356,2);    

    //left face (4)
    
    llScaleTexture(0.02,0.333333,4);
    llRotateTexture(-PI_BY_TWO, 4);
    llOffsetTexture(0.98,0.333,4);

    
    // communicationMethod ==2, default is script owner's avatar
    if (controllerAgent == "" && communicationMethod == 2) controllerAgent = llGetOwner();

    // who am i ?
    me = llGetKey();
    meName = llKey2Name(me);
    
}

init_hard() {
    if (resetOnRez || resetOnScriptInit) restorePrimShape();
    init();
    
}

// in case we need that
restorePrimShape() {
        //llSetPrimitiveParams( [PRIM_ROTATION, llEuler2Rot(<0, PI_BY_TWO, PI + PI_BY_TWO>)] );
        //llSetPrimitiveParams( [PRIM_ROTATION, llEuler2Rot(<0, PI_BY_TWO,-PI_BY_TWO>)] );
        llSetLocalRot( llEuler2Rot(<0, PI_BY_TWO,-PI_BY_TWO>));
        //llSetRot(  llEuler2Rot(<0, PI_BY_TWO, PI_BY_TWO>) );
        list params = [  9,
                         0,
                         0,
                        <0.000000, 1.000000, 0.000000>,
                         0.000000,
                        <0.000000, 0.000000, 0.000000>,
                        <1.030000, 1.000000, 0.000000>,
                        <0.000000, 0.000000, 0.000000>
                    ];
        llSetPrimitiveParams( params);
        llSetPrimitiveParams( [PRIM_SIZE, primscale * <0.25, 0.02, 0.01>] );
        llOwnerSay("prim shape restored");
   
}

reloadTexture() {
    if (sliderTexture == "") sliderTexture = llGetInventoryName(INVENTORY_TEXTURE, 0);
    
}


//____________________________________________________________________
//                          UI
//....................................................................

updateCoords() {    // called on touch() and touch_end() events
                    // computes the slider position
    primPos = llDetectedTouchST(0);
    
    // carefull on the borders
    if (primPos.x >= 0.02 && primPos.x <= 0.98 ) llOffsetTexture(0.5 - primPos.x , 0.666, 5);
    else if (primPos.x < 0.02) primPos.x = 0.02;
    else primPos.x = 0.98;
    
    percent = llFloor( 100 * (primPos.x - 0.02 ) / 0.96 );    
}


updateColorGlobs(integer init) { //don't update prim color if init == TRUE
    if (percent < slowLimit) {
        textColor = <0.5,0.5,1>;
        primColor =  <0.8,0.8,1>;
        
    }
    else if (percent > safeLimit) {
        textColor = <1,0.2,0.2>;
        primColor =  <1,0.8,0.8>;
    }
    else {
        textColor = <0.5,1,0.5>;
        primColor =  <0.8,1,0.8>;
    }
    
    if (textOn) llSetText(convert() + scaleUnit, textColor,1);
    if (primCOn && !init) llSetColor(primColor, ALL_SIDES);    

}

announceResult(integer eventType) {                         // eventType :  0 -> from touch()   
                                                            //              1 --> from touch_end()
    string result = convert();
    // from touch(), and method is NOT llInstantMessage()
    if          (eventType == 0 && communicationMethod != 2) {       
        if          (communicationMethod == 0)  llMessageLinked(linkedTarget, 0, meName, result);
        else if (regionWide)                    llRegionSay(HUDchannel, result);
        else                                    llSay(HUDchannel, result);   
    // from touch_end() event
    } else if   (eventType == 1) {
        if          (communicationMethod == 0)  llMessageLinked(linkedTarget, 0, meName, result);
        else if     (communicationMethod == 2)  llInstantMessage(controllerAgent, result);
        else if     (regionWide)                llRegionSay(HUDchannel, result);
        else                                    llSay(HUDchannel, result);        
    // unknown eventType
    } else return;
}

//____________________________________________________________________
//                         MISC
//....................................................................

// converts output message from [0-100] integer to []
string convert() {
    if (minScale && maxScale) {
        llOwnerSay("conversion ON");
        return (string)(minScale + ((float)percent / 100) * (maxScale - minScale) );
    }
    else {
        llOwnerSay("no conversion");
        return (string)percent;
    }
}

dbg(string msg) {
    if (debug) llOwnerSay(msg);
}


//____________________________________________________________________
//                          STATES
//....................................................................

default
{
    state_entry()
    {
        init_hard(); 
        updateColorGlobs(TRUE);
        //llOwnerSay("init completed");      
    }
    
    on_rez(integer start_param)
    {
        init_hard();
    }


    touch_start(integer total_number)
    {
        llOffsetTexture(0.5 - primPos.x, 0.666, 5);
        updateColorGlobs(FALSE);
        //llSay(0, "Touched.");
       
        
    }
    
    
    touch(integer total_number)
    {
        if (!disableDrag) { // skip if disableDrag == TRUE
            
            if (llDetectedTouchFace(0) == 5) { // only detect touches on the front face (5)        
                updateCoords();
                updateColorGlobs(FALSE);
                announceResult(0);          
            }
            //else llOwnerSay("out of coords!!");
        }   
    }
    
    
    touch_end(integer total_number)
    {
        if (disableDrag || communicationMethod == 2) {  // triggers for :   - llInstantMessage (in all cases)
                                                        //                  - llSay, llMessageLinked, if drag is disabled
                                                        //                    (otherwise handled by touch() event)
            //llSay(0, "end touch"); 
            llOffsetTexture(0.5 - primPos.x, 0, 5);
            if (primCOn) llSetColor(<1,1,1>, ALL_SIDES);
            updateCoords();
            updateColorGlobs(FALSE);
            announceResult(1);
        }
    }



}

//____________________________________________________________________
// Note on use of channel listeners :
// (http://wiki.secondlife.com/wiki/LlListen)
//
//       1. Chat that is said gets added to a history.
//       2. A script that is running and has a listen event will ask the history for a chat message
//          during its slice of run time.
//       3. When the script asks the history for a chat message the checks are done in this order:
//              * channel
//              * self chat (prims can't hear themselves)
//              * distance/RegionSay
//              * key
//              * name
//              * message 
//       4. If a message is found then a listen event is added to the event queue. 
//
//    The key/name/message checks only happen at all if those are specified of course. 
//    So, the most efficient way is llRegionSay on a rarely used channel.
//
//____________________________________________________________________
// basic test :
//
// drop this script in another prim, and link/unink it to the slider while changing communicationMethod
//
//
//string sliderName = "slidingbar" // change this to reflect your settings
//default
//{
//    state_entry()
//    {
//        llListen(999, sliderName, "", "");
//    }
//    
//    
//    listen(integer channel, string name, key id, string message) {
//        llOwnerSay("SAY " + message);
//    }
//    
//    
//    link_message( integer sibling, integer num, string mesg, key target_key ) {
//        if ( mesg == sliderName ) {
//            llOwnerSay("LINK " + (string)target_key);
//        }           
//    }
//
//    
//}
//____________________________________________________________________
