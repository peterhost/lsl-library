//*********************************************************************
//                                                                    *
//                    --HUD Slider with Listener--                    *
//                                                                    *
//*********************************************************************
// HUD Slider with Listener - v 0.1
// Highly customizable Sliding Bar, with listener (takes commands)
//
// by:          Peter Host (Pete Atolia inworld)
// License:     BSD, but please provide patches/bugfixes if you can!
//
// Description: * provides a slider in one prim to be linked to a HUD
//                or standalone.
//              * Slider either sends its position (0-100 number) :
//                  - on chat channel (default)
//                  - as llMessageLinked()
//                  - to an avatar, by IM
//              * Slider can take commands sent either by chat or llMessageLinked
//                to issue it's current position, or modify some of its parameters
//                Invalid commands fail silently
//                Valid commands are :
//
//                  - tellPosition                  //reports slider's position
//                  - hideSL                        //make slider transparent
//                  - showSL                        //restore slider's visibility
//                  - tellState                     //slider reports its state ("initializing" or "ready") 
//
//                  - init                          //reset slider's params
//                  - initHard                      //reset all slider's params (including prim shape)
//                  - reload                        //reloads slider params from notecard   (first notecard found in inventory)
//                  - save                          //saves slider params to notecard       (first notecard found in inventory)
//
//                  - textOnOff     boolean         //sets textOn to boolean
//                  - showDecimals  boolean         //sets showDecimals to boolean
//
//                  - limits        <x,y,z>         //sets limits : slowLimit = x, safeLimit = y, z ignored
//                                                  //              regardless of setRange, provide [0-100] integers
//                  - primCon       boolean         //sets primCon to boolean
//                  - disableDrag   boolean         //sets disableDrag to boolean
//                  - setRange      <x,y,z>         //sets minScale = x, maxScale = y, z ignored
//                  - scaleUnit     string          //sets scaleUnit to string
//
//                  - talkMethod    integer         //sets talkMethod to integer (0, 1, 2)
//                  - linkedTarget = integer        //-2 LINK_ALL_OTHERS, 1 LINK_ROOT, -1 LINK_SET, -2 LINK_ALL_OTHERS,
//                                                  //-3 LINK_ALL_CHILDREN, -4 LINK_THIS, or prim linknumber
//                  - HUDchannel    integer
//                  - regionWide    boolean
//                  - controllerAgent UUID
//
//                  - chatListen    boolean
//                  - listenChannel integer
//                  - listen2Name   string
//                  - listen2ID     key
//
//                  - debug         boolean
//
//              * Notecard-DRIVEN : you need to initialize this slider script with an
//                appropriate notecard (see below)
//
//              * You can customize the result's scale to whatever you like
//                in the "//custom scale" section
//
// Usage: 1) add the texture in the same directory to a prim cube
//           ("slidingbar-grey.png")
//        2) add the sample notecard in the same directory to the prim (named "params", or 
//           otherwise, the first notecard found in inventory will be used)
//        3) edit the notecard if you wish to change params
//        4) place this script in the prim
//        5) let the script initialize 
//        6) do whatever you want with the slider
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

                            // three zones defining slider's color (blue under green limit, green inbetween, red over green limit)
vector limits = <10, 20, 0>; // < blue (0-100), green (0-100), ignored >

integer primCon = TRUE;     // FALSE to disable slider color change

integer disableDrag = FALSE;// TRUE to disable dragging slider

//.............
// custom scale

                            // by default the slider annouces an integer number
                            // between 0 and 100. If you wish for it to announce
                            // something else, set the following two parameters.
                            // [100, 0], [0.1, -0.5], [12, 24.999],...
                            // NB : these parameters only affect slider's output 
                            //      (hovering text and message), all inner functions
                            //      still use a [0-100] integer (limit,...)
float minScale = -200;
float maxScale = 1800;
string scaleUnit = " meters";   // change to whatever your scale unit is, or ""
integer showDecimals = FALSE;   // true to show decimals in hover text (2 decimals)
//..............
// communication

// 1 - TALK
                                        // choose one :
integer talkMethod = 0;                 // 0 : llMessageLinked(...)
                                        // 1 : llSay(message, HUDchannel);
                                        // 2 : llInstantMessage() --> NB : only touch_end() updating due
                                        //                                 to the 2 sec. delay
                                        // then set one of these :
integer linkedTarget = LINK_ALL_OTHERS; // --> prim(s) to report to if talkMethod is set to "0"
                                        //     LINK_ROOT, LINK_SET, LINK_ALL_OTHERS, LINK_ALL_CHILDREN,
                                        //     LINK_THIS, or prim linknumber
integer HUDchannel = 999;               // --> channel to report to if talkMethod is set to "1"
integer regionWide = FALSE;             // --> TRUE : use llRegionSay instead of llSay if talkMethod
                                        //     is set to "1". NB : HUDchannel can't be set to 0 (PUBLIC_CHANNEL)
key controllerAgent = "";               // --> key of avatar to report to if talkMethod is set to "2"
                                        //     (default is script owner)

integer announceState = FALSE;          // TRUE : slider automatically announces its state ("initializing" or "ready")
                                        // warning : it's up to you to differentiate between this message and the slider's
                                        //           current position messages


// 2 - LISTEN
                                        // script listens to llMessageLinked by default, as this does not
                                        // add to lag. BUT it will only open a listen channel if you neet to 
integer chatListen = TRUE;             // alter slider settings via chat commands
                                        //
                                        // if chatListen == TRUE, be as specific as you can afford,
                                        // in setting the following. Those authentification params can
                                        // also be used for llMessageLinked authentification
                                        
integer listenChannel;                  // defaults to HUDchannel
string  listen2Name;                    // only listen to prims with this name; default ""
key     listen2ID;                      // only listen to the prim with this UUID

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
integer ChatlistenerHandle;
integer SLready = FALSE;      // becomes TRUE when slider is ready
//____________________________________________________________________
//                          Initialization
//....................................................................

init() {
    SLready = FALSE;
    if (announceState) announce("initializing");
    llSetAlpha(0, ALL_SIDES);
    llSetText("", <1,1,1>,1);
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

    

    // who am i ?
    me = llGetKey();
    meName = llKey2Name(me);
    
    init_soft();
    updateSliderAppearance();
    SLready = TRUE;
    if (announceState) announce("ready");
}

//....................................................................
// only reset global-variable-dependant settings (to update
// slider without reseting it following an external command

init_soft() {
    
    // talkMethod ==2, default is script owner's avatar
    if (controllerAgent == "" && talkMethod == 2) controllerAgent = llGetOwner();

    // optionnal chat listener
    if (chatListen) {
        // set listen channel to default if not set (even if not used)
        if (!listenChannel) listenChannel = HUDchannel;
        // setup a listener if the chatListen == TRUE
        llListenRemove(ChatlistenerHandle);
        ChatlistenerHandle = llListen(listenChannel, listen2Name, listen2ID, "");
    }
    else llListenRemove(ChatlistenerHandle); // remove last callback in case chatListen has just been set to FALSE 
}

//....................................................................

init_hard() {
    if (resetOnRez || resetOnScriptInit) restorePrimShape();
    init();
    
}

//....................................................................

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
        dbg("prim shape restored");
   
}

//....................................................................

reloadTexture() {
    if (sliderTexture == "") sliderTexture = llGetInventoryName(INVENTORY_TEXTURE, 0);
    
}

//....................................................................

loadNotecard() {
    dbg("loadNotecard not yet implemented");
    init();   
}

//....................................................................

saveNotecard() {
    dbg("saveNotecard not yet implemented");
    
}


//____________________________________________________________________
//                          LISTENING / SPEAKING
//....................................................................


announceResult(integer eventType) {                         // eventType :  0 -> from touch()   
                                                            //              1 --> from touch_end()
                                                            //              2 --> from executeOrder()
    string result = convert();
    // from touch(), and method is NOT llInstantMessage()
    if          (eventType == 0 && talkMethod != 2) announce(result);  
    // from touch_end() event or executeOrder()
    else if     (eventType == 1 || eventType == 2) announce(result);
    // unknown eventType
    else return;
}


announce(string tellthem) {
        if          (talkMethod == 0)  llMessageLinked(linkedTarget, 0, meName, tellthem);
        else if     (talkMethod == 2)  llInstantMessage(controllerAgent, tellthem);
        else if     (regionWide)                llRegionSay(HUDchannel, tellthem);
        else                                    llSay(HUDchannel, tellthem);            
}

executeOrder(string mesg) {
    // 1 - parse order
    list tmpOrder = llParseString2List(mesg, " ", ""); 
    string command = (string)llList2List(tmpOrder, 0, 0);
    string arg = (string)llList2List(tmpOrder, 1, 1);
    
    // 2 - execute order  
    if (command == "tellPosition") announceResult(2); // slider reports its position (to whomever in the universe, listens)
    //else if (order == "savePresets")                // slider saves presets in notecard
    else if (command == "init")         init();
    else if (command == "initHard")     init_hard();
    else if (command == "reload")       loadNotecard();
    else if (command == "save")         saveNotecard();
    else if (command == "hideSL") {
        llSetAlpha(0, ALL_SIDES);
        llSetText("",<1,1,1>,0);   
    }
    else if (command == "showSL") updateSliderAppearance();
    else if (command == "tellState") {
        if (SLready) announce("ready");
        else announce("initializing");   
    }
    else if (command == "textOnOff"){
        if ( (integer)arg) textOn = TRUE;
        else textOn = FALSE;
        updateSliderAppearance();
    }
    else if (command == "showDecimals"){
        if ( (integer)arg) showDecimals = TRUE;
        else showDecimals = FALSE;
        updateSliderAppearance();
    }
    else if (command == "primCon"){
        if ( (integer)arg) primCon = TRUE;
        else primCon = FALSE;
        updateSliderAppearance();
    }
    else if (command == "disableDrag"){
        if ( (integer)arg) disableDrag = TRUE;
        else disableDrag = FALSE;
    }    
    else if (command == "regionWide"){
        if ( (integer)arg) regionWide = TRUE;
        else regionWide = FALSE;
        init_soft();
    } 
    else if (command == "chatListen"){
        if ( (integer)arg) chatListen = TRUE;
        else chatListen = FALSE;
        init_soft();
    }     
    else if (command == "listenChannel") {
        listenChannel = (integer)arg;
        init_soft();
    }
    else if (command == "listen2Name") {
        listen2Name = arg;
        init_soft();
    }
    else if (command == "listen2ID") {
        listen2ID = (key)arg;
        init_soft();
    }        
    else if (command == "controllerAgent") controllerAgent = (key)arg;
    else if (command == "HUDchannel") HUDchannel = (integer)arg;
    else if (command == "linkedTarget") linkedTarget = (integer)arg;
    else if (command == "talkMethod") talkMethod = (integer)arg;
    else if (command == "scaleUnit") {
        scaleUnit = arg;
        updateSliderAppearance();
    }
    else if (command == "limits") {
        limits = (vector)arg;
        updateSliderAppearance();
    }
    else if (command == "setRange") {
        vector tmpvect = (vector)arg;
        minScale = tmpvect.x;
        maxScale = tmpvect.y;
        updateSliderAppearance();
        dbg((string)tmpvect);
    }
    else if (command == "debug") debug = (integer)arg;
    else dbg("Unknown command");
        

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


updateSliderAppearance() { 
    llSetAlpha(1, ALL_SIDES);
    if (percent < limits.x) {
        textColor = <0.5,0.5,1>;
        primColor =  <0.8,0.8,1>;
        
    }
    else if (percent > limits.y) {
        textColor = <1,0.2,0.2>;
        primColor =  <1,0.8,0.8>;
    }
    else {
        textColor = <0.5,1,0.5>;
        primColor =  <0.8,1,0.8>;
    }
    
    if (textOn) llSetText(convert() + scaleUnit, textColor,1);
    else llSetText("", textColor, 1);
 
    if (primCon) llSetColor(primColor, ALL_SIDES);   

}


//____________________________________________________________________
//                         MISC
//....................................................................

// converts output message from [0-100] integer to []
string convert() {
    
    if (minScale && maxScale) {
        float res = (minScale + ((float)percent / 100) * (maxScale - minScale) );
        if (showDecimals) { // show 2 decimals
            return formatDecimal(res, 2);            
        } else return (string)(llRound(res));
    }
    else return (string)percent;

}


string formatDecimal(float number, integer precision)
{    
    float roundingValue = llPow(10, -precision)*0.5;
    float rounded;
    if (number < 0) rounded = number - roundingValue;
    else            rounded = number + roundingValue;
 
    if (precision < 1) // Rounding integer value
    {
        integer intRounding = (integer)llPow(10, -precision);
        rounded = (integer)rounded/intRounding*intRounding;
        precision = -1; // Don't truncate integer value
    }
 
    string strNumber = (string)rounded;
    return llGetSubString(strNumber, 0, llSubStringIndex(strNumber, ".") + precision);
}



string FreeMem()
{
//float mempct = (100 * llGetFreeMemory() / (float)(16*1024)); // for non-MONO
float mempct = (100 * llGetFreeMemory() / (float)(64*1024)); // for MONO
string percent = llGetSubString((string)mempct,0,4); // displays 75.25%
string memtmpA = (string)(llGetFreeMemory()/1024)+"k ("+percent+"%)";
return memtmpA;
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
        dbg(FreeMem());      
    }
    
    on_rez(integer start_param)
    {
        init_hard();
    }



    //________________________________________________________________
    //                           UI commands
    //________________________________________________________________


    touch_start(integer total_number)
    {
        llOffsetTexture(0.5 - primPos.x, 0.666, 5);
        updateSliderAppearance();
        //llSay(0, "Touched.");
       
        
    }
    
    
    touch(integer total_number)
    {
        if (!disableDrag) { // skip if disableDrag == TRUE
            
            if (llDetectedTouchFace(0) == 5) { // only detect touches on the front face (5)        
                updateCoords();
                updateSliderAppearance();
                announceResult(0);          
            }
            //else dbg("out of coords!!");
        }   
    }
    
    
    touch_end(integer total_number)
    {
        if (disableDrag || talkMethod == 2) {  // triggers for :   - llInstantMessage (in all cases)
                                                        //                  - llSay, llMessageLinked, if drag is disabled
                                                        //                    (otherwise handled by touch() event)
            //llSay(0, "end touch"); 
            llOffsetTexture(0.5 - primPos.x, 0, 5);
            if (!primCon) llSetColor(<1,1,1>, ALL_SIDES);
            updateCoords();
            updateSliderAppearance();
            announceResult(1);
        }
    }

    //________________________________________________________________
    //                           LISTENERS
    //________________________________________________________________

    // 1 - llMESSAGELINKED (better)
    link_message( integer sender_num, integer num, string mesg, key mesg2 ) {   // mesg  is either a name or a key
                                                                                // mesg2 is of the type "command parameter"
        dbg("reveived llMessageLinked order: " + mesg + " -- " + mesg2);
        key iskey = (key)mesg2;
                                                                           
        if      (iskey && (iskey == listen2ID   || !listen2ID)  )   executeOrder(mesg); // valid key && authorized key if authorisation set
        else if ( mesg2 == listen2Name          || !listen2Name )   executeOrder(mesg); // authorized name || null
    }
    
    // 2 - llLISTEN
    listen(integer channel, string name, key id, string mesg) // message is of the type "command parameter"
    {
        // filtering has already be done by the llListen() call
        dbg("received llSay order: " + mesg);
        executeOrder(mesg);        
    }



}

//____________________________________________________________________
// Note on wise use of channel listeners :
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
// drop this script in another prim, and link/unink it to the slider while changing talkMethod
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
