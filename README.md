# haltech-uc10-dash for Assetto Corsa
The Haltech uC-10 dash for Assetto Corsa utilizing CSP. Initially created by MetalRoachTwo for T-Pain in the RTR Convertible Formula Drift Mustang.
T-Pain, Nappy Boy Gaming, and MetalRoachTwo wanted to release it to the people to see the wild and crazy digital set ups others could create.



## Features

uc10-dash features 1 dash currently in version 1.0 but will be customizable allowing up to 5 custom dash layouts that you can switch between in game just like the IRL version
- all of the Haltech Dash Backgrounds have already been converted and are available within the ExtraScreens folder. If you ever want to learn or teach yourself LUA scripting I will be providing extra documentation to set up or modify different screen options in a later version

## Requirements

uc10-dash expects a CSP Version above or equal to 1.76. 


## Installation

The uc10-dash's build design allows it to be added ALL cars by editing the `ext_config.ini`, here is an example for the T-Pain's RTR Vert:

## In ext_config.ini
[INCLUDE: uc10.ini]

## In uc10.ini
[MODEL_REPLACEMENT_...]
ACTIVE = 1 ; change to 1 to enable
FILE = mm_tpain_picklerick.kn5 ; you can find the name of the car kn5 in the folder of your car.
INSERT = Haltech_ic7.kn5
INSERT_IN = gauges ; insert it in cockpit (or dummy/node for the location of the mod
; Options to transform inserted model:
SCALE = 1.23, 1.23, 1.23    ; change size: X, Y and Z axis (for car, X is normally left-right, Y is up-down, and Z is front to back - depending on the axis orientaion of the dummy/node you attached the mod to will determine the actual movement in game)
ROTATION = 180,-5 , 0  ; rotate: heading, pitch and roll, in degress
OFFSET = 0, 0, -.025  ; move: X, Y and Z axis, in meters

## Place the Assets folder, uc10.ini, uc10_display.lua, and Haltech_uc10.kn5 into the cars extension folder
All the above mentioned files must be in the extension folder of the car to work correctly


## Usage

After loading into the game, the Dash should be visible: *IF YOU DO NOT SEE THE DASH AT FIRST LOOK ALL AROUND, ABOVE, AND UNDER THE CAR, THE BEST WAY IS TO OPEN CAMTOOL AND HOLD SHIFT TO SLOWLY MOVE THE CAMERA AROUND THE CAR TO LOCATE THE DASH**
- One you have located the dash adjust the SCALE, ROTATION, AND OFFSET located in the uc10.ini
- If you can not locate the dash at all, double check the FILE is the KN5 of your car, and the INSERT is the dummy or node you are attaching the dash to *IT MUST BE ATTACHED TO A NODE, IF YOU PREVIOUSLY HAD A DIGITAL DASH OR COCKPIT DUMMY/NODE THOSE ARE TYPICALLY DEFAULTED TO MODS, THEY ARE USUALLY THE BEST TO ATTACH THE DASH TO*
- If you have questions or need assistance you may ask in the ACMP Discord, you can tag MetalRoachTwo or ask others for assistance.

Menus can be cycled with ALT+Numpad9 *or whichever key you have ExtraC bound to*, the RPM Lights can be cycled with ALT+Numpad8 *or whichever key you have Extra B bound to* 


## Issues and Technical Limitations

For Open Bugs and Issues, please refer to (https://github.com/Metalroachtwo/haltech-uc10-dash/issues)

- All uC-10 Textures are provided by Haltech themselves utilizing the Haltech NSP software. Nappyboy Gaming, Haltech and MetalRoachTwo want the community to go crazy, we want to see custom dashes and digital readouts to the wildest.
- If you would like help or need questions answered about the Haltech Software, please make sure you check out Haltech forums for additional assistance.
- The Haltech software was used along side 3DS Max, KSEditor, as well as Photoshop and DDS extension to create this attachment mod.
- The Haltech software is property of Haltech and also available for free on Haltech's website

## License

You are allowed to use, edit and redistribute modified versions of `uc10-dash`, however, we require that you give credit and link to this original project when doing so.

Please do not sell, or ship uc10-dash alongside **paid** models, cars and/or software.

Contributions via Pull Requests are very much encouraged.
