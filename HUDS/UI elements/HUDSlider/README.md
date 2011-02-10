*********************************************************************
                       --HUD Slider--                              
*********************************************************************
 HUD Slider - v 0.2
 Highly customizable Sliding Bar

 by:          Peter Host (Pete Atolia inworld)
 License:     BSD, but please provide patches/bugfixes if you can!

 Description: provides a slider in one prim to be linked to a HUD
              or standalone.
              Slider either sends its position (0-100 number) :
                  - on chat channel (default)
                  - as llMessageLinked()
                  - to an avatar, by IM
              You can customize the result's scale to whatever you like
              in the "custom scale" section

 Usage: 1) add the texture in the same directory to a prim cube
           ("slidingbar-grey.png")
        2) place this script in the prim
        3) let the script initialize 
        4) do whatever you want with the slider

 Nota :   this slider both supports touch and drag, though drag
          might be slow according to what region-server/script-engine
          the script runs in

*********************************************************************
##                   HUD Slider with Listener
                  
*********************************************************************
######HUD Slider with Listener - v 0.1

   Highly customizable Sliding Bar, with listener (takes commands)

######by

   Peter Host (Pete Atolia inworld)
#####License

   BSD, but please provide patches/bugfixes if you can!

######Description: 

  * provides a slider in one prim to be linked to a HUD
                or standalone.
  * Slider either sends its position (0-100 number) :
                  - on chat channel (default)
                  - as llMessageLinked()
                  - to an avatar, by IM
  * Slider can take commands sent either by chat or llMessageLinked
                to issue it's current position, or modify some of its parameters
                Invalid commands fail silently
                
				  Valid commands are :


                  - tellPosition                  reports slider's position

                  - init                          reset slider's params
                  - initHard                      reset all slider's params (including prim shape)
                  - reload                        reloads slider params from notecard   (first notecard found in inventory)
                  - save                          saves slider params to notecard       (first notecard found in inventory)

                  - textOnOff     boolean         sets textOn to boolean

                  - limits        <x,y,z>         sets limits : slowLimit = x, safeLimit = y, z ignored
                                                                regardless of setRange, provide [0-100] integers
                  - primCon       boolean         sets primCon to boolean
                  - disableDrag   boolean         sets disableDrag to boolean
                  - setRange      <x,y,z>         sets minScale = x, maxScale = y, z ignored
                  - scaleUnit     string          sets scaleUnit to string

                  - talkMethod    integer         sets talkMethod to integer (0, 1, 2)
                  - linkedTarget = integer        -2 LINK_ALL_OTHERS, 1 LINK_ROOT, -1 LINK_SET, -2 LINK_ALL_OTHERS,
                                                  -3 LINK_ALL_CHILDREN, -4 LINK_THIS, or prim linknumber
                  - HUDchannel    integer
                  - regionWide    boolean
                  - controllerAgent UUID

                  - chatListen    boolean
                  - listenChannel integer
                  - listen2Name   string
                  - listen2ID     key



 
  * You can customize the result's scale to whatever you like
                in the "custom scale" section

###### Usage
        1) add the texture in the same directory to a prim cube
           ("slidingbar-grey.png")

        2) add the sample notecard in the same directory to the prim (named "params", or 
           otherwise, the first notecard found in inventory will be used)
        3) edit the notecard if you wish to change params
        4) place this script in the prim
        5) let the script initialize 
        6) do whatever you want with the slider

###### Nota
this slider both supports touch and drag, though drag
might be slow according to what region-server/script-engine
the script runs in
