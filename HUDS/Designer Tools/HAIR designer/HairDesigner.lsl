//____________________________________________________________________
//                           GLOBAL VARIABLES
//____________________________________________________________________
//@ : computed variable
//# : setting


integer totPrims;               //@
integer currentPrim;            //@
integer currentAlpha100 = -1;   //@ current selection
float   myAlphaHidden = 0.05;   //# ALPHA for hidden prim
float   myAlphaSelected = 1;    //# ALPHA for touched prim

integer mode = 0;               //# default mode : 0 (1 prim)
                                //  trail        : 1 (trailTotLength prims)
integer trailTotLength = 10;    //# number of prims to include in the alpha trail
list trail;                     //@ the trail propper (child prim indexes)
integer trailDampen = 80;       //# from 0 (%) to 100 (%)

integer trailLength = 0;        //@ actual trail's length (computed)

integer evStartTime;
integer evEndTime;

integer HUDchannel = 999;       //#
integer resetAlpha = FALSE;     //@ alpha channel slider triger

init() {
    totPrims = llGetNumberOfPrims();   
}


//____________________________________________________________________
//                           UI
//____________________________________________________________________


//....................................................................
// update all the child prims with current alpha settings

alphaPaint() {
     // FIRST touch : we ALPHA all prims except the touched one
    if (currentAlpha100 == -1 || resetAlpha) { 
        integer i;
        for (i=0; i<=totPrims; i++) {
            if (i != currentPrim)   llSetLinkAlpha( i, myAlphaHidden, ALL_SIDES );
            else llSetLinkAlpha( i, myAlphaSelected, ALL_SIDES );
            
        }
    }
    // ALPHA last one, DEALPHA current one
    else {
        
        // new selected prim
        llSetLinkAlpha( currentPrim, myAlphaSelected, ALL_SIDES );
        
        // mask last prim
        if (mode == 0) {
            llSetLinkAlpha( currentAlpha100, myAlphaHidden, ALL_SIDES );
            
        }
        // alpha trail
        else if (mode == 1) {
            // add precedently selected prim to trail and keep max
            // trailTotLength prims in trail
            trailLength = llGetListLength(trail);
            if (trailLength >= trailTotLength) trail =  llList2List(trail, 1, trailTotLength - 1 ) + [currentAlpha100];
            else trail =  trail + [currentAlpha100];
            trailPaint();
            llOwnerSay((string)trailLength + " of " + (string)trailTotLength + " - TRAIL : " + (string)trail);
        }
        
        

   
    }
    currentAlpha100 = currentPrim; 
    
}


trailPaint() {
    string debug ="";
    integer i;
    float curAlpha = myAlphaHidden + (myAlphaSelected - myAlphaHidden) * (100 - trailDampen) / 100; // trail alpha attenuation
    float decrement = (curAlpha - myAlphaHidden) / (trailTotLength + 1);
    
    for (i=0; i< trailLength; i++) {
        curAlpha -= decrement;
        llSetLinkAlpha( (integer)llList2String(trail,i), curAlpha, ALL_SIDES );
        debug = debug + "-" + (string)curAlpha;
    }
    llOwnerSay("DECR="+ (string)decrement + "\nAlphaTRAIL=" + debug);

}

//____________________________________________________________________
//                           MISC UTILS
//____________________________________________________________________
string freeMem() {
//float mempct = (100 * llGetFreeMemory() / (float)(16*1024)); // for non-MONO
    float mempct = (100 * llGetFreeMemory() / (float)(64*1024)); // for MONO
    string percent = llGetSubString((string)mempct,0,4); // displays 75.25%
    string memtmpA = (string)(llGetFreeMemory()/1024)+"k ("+percent+"%)";
    return memtmpA;
}
//____________________________________________________________________
//                           STATES
//____________________________________________________________________

default
{
    state_entry()
    {
        init();
        llSay(0, "TOT PRIMS = " + (string)totPrims + "\n");
        llListen( HUDchannel, "", NULL_KEY, "" );
    }
    
    touch_start(integer num_detected)
    {
        integer i;
        for(i=0; i<num_detected; ++i) {
            currentPrim = llDetectedLinkNumber(i);
            llOwnerSay("Link number clicked: " + (string)currentPrim);
        }
        
    }

    //llSetLinkAlpha( integer linknumber, float alpha, integer face );
    touch_end(integer num_detected) {
        alphaPaint(); 
        llSetText((string)freeMem(), <0,1,0>,1);       
    }
    
    
    listen(integer channel, string name, key id, string message ) {
        llOwnerSay(message);
        
        // alpha strength slider
        if (name == "tappered sliding bar v0.3") {
               myAlphaHidden = (float)message / 100;
               resetAlpha = TRUE;
               alphaPaint();
               resetAlpha = FALSE;
        } 
        
        // alpha trail activation
        else if (name == "trailOnOff") {
            if (message == "trailon") {
                mode = 1;
            } else {
                mode = 0;
            }
            alphaPaint();    
        }
        else if (name == "trailDampen") {
            trailDampen = (integer)message;
            trailPaint();
        }
    }

}



// simple linkset switcher
//
//default
//{
//    
//
//    touch_start(integer total_number)
//    {
//        llSetPrimitiveParams([PRIM_FULLBRIGHT, ALL_SIDES, TRUE]);
//        llSetLinkPrimitiveParams(LINK_ALL_OTHERS, [PRIM_FULLBRIGHT, ALL_SIDES, FALSE]);
//        
//    }
//}