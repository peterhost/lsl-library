#Simple Height Teleporter for OpenSim
##Description
Simple Teleporter

This HUD instantly teleports you in the Z direction to another height (if ever you get stuck while building and don't want to move prims around). It uses the OSSL function osTeleportAgent, which needs to be enabled in your OpenSim.ini config file.

##Usage
###OpenSim.ini


In the [XEngine] section, check that the following line is :

    [XEngine]
    ;# {Enabled} {} {Enable the XEngine scripting engine?} {true false} true
    ;; Enable this engine in this OpenSim instance
    Enabled = true

Then, at the end of this section, add the following line :

    Allow_osTeleportAgent = your-avatar-UUID-here

It's important that you restrict the usage of this function to scripts owned by your avatar to avoid grieving

###Download/Upload
* Download this folder's contents
* in Imprudence viewer, File -> Import + Upload -> choose the xml file in this folder
* the HUD will be rezzed inworld, already textured. It's composed of two prims : a small cube (HUD button) and an elongated rectangle (slider)

###Edit the HUD button
* edit the object, select *edit linked parts*
* select the HUD button, change the object's name to *HeightTeleporter v0.6* (or whatever you like)
* in your inventory, look for the texture named **14ab36e4-2ae2-4343-8c2b-502ca9e3b6fd** and drop it in this prim's inventory
* copy the script named *HeightTeleporter v0.6* in this prim

###Edit the Slider
* select the slider prim 
* **RENAME IT** *slidingbar*
* in your inventory, look for the texture named **faa6958a-a469-4ca6-90a7-bb94bfbfa8b8** and drop it in this prim's inventory
* copy the script named *HUDSlider-with-listener-v0.1.lsl* in this prim

###Take It
* close the edit menu and take the object in your inventory
* attach it to a free HUD position, wait for it to initialize
* set the desired height with the slider, and click the HUD button to teleport

##Note on textures
If ever you get confused,
 
* faa6958a-a469-4ca6-90a7-bb94bfbfa8b8 : is the slider's texture
* 14ab36e4-2ae2-4343-8c2b-502ca9e3b6fd : is the HUD's button texture