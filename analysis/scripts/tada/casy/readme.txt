Copyright Haskins Laboratories, Inc., 2001-2004
   270 Crown Street, New Haven, CT 06514, USA
   programmer Yuriy Koblents-Mishke
   e-mail koblents@haskins.yale.edu

Haskins Laboratories.

CASY for Matlab.

version 0.13.1


-----------------------------------------------------------
To work with the program, first enter Matlab rev.13. 

In my experience, it is better to use it is in command line environment.

The integrated Matlab environment ("desktop") is fine if your system have a big monitor, or even better, have two big monitors. However, wit smaller 17" displays, not to mention laptops, the screen will be too cluttered to work effectively with graphic programs.

Additionally, when working from remote terminal, X-terminal, etc, the integrated Matlab environment is slow to crawl. 


To start Matlab rev.13, you can give the following Linux command

matlab -nodesktop [-nosplash]

There is a command file matlab13 in this directory, to start matlab in command mode:

./matlab13

However, it does not work well over network.

Casy can be run from a working directory, with the program itself stored elsewhere. To do this, after starting Matlab as above, you can give the following Matlab command:

addpath programDir

where programDir is the directory where casy.m and other program files are stored. Or, even better, you can automate this by creating a short file named 'startup.m' in your working directory. The 'startup.m' must include the above addpath command.  
--------------------------------------------



To start CASY for Matlab, give the following command (under Matlab):

casy [fileName]

where optional fileName points to a script file, usually with initial values of the program parameters, which will be run by casy during initialization. Casy looks for the file first in the working directory, than in the program directory. A warning will be provided if the file is not found, and casy proceeds without running the script. If you call just casy, without parameters, casy looks for a script file maned 'default.par' in the same directories. If it is not found, casy proceeds without warning. 

You may select one of three graphic user interfaces (GUI) when working with CASY: single window interface (the default), two window interface, and four window interface. In four window are for plots of vocal tract, area function, spectrum, and wave form. In the single window interface the four above plots are implemented as subplots of a single window. In two window interface the plot of vocal tract is displayed in a separate window, while the other three elements are combined in a second window. The single window interface is more convenient when working with smaller monitors, 15-inch and 17-inch. Two and four window interfaces are more convenient when you have 19-inch or bigger monitor, or two-monitor setup. You also may use these interface if you want to zoom one of the above plots. 

CASY starts in the single window GUI mode. To switch between GUIs, you may use the following commands:

GUI
GUI 1
GUI 2
GUI 4

where the command GUI without arguments is equivalent to GUI 1. If you provide a wrong argument to the GUI command, the program displays a warning message on display and switches to the single window mode.


To save the generated sound in the *.pcm or *.wav formats, or to read it back, give respectively, the following commands

writepcm [fileName]
writewav [fileName]
readpcm [fileName]
readwav [fileName]

where [fileName] is the optional name of file. If you do not provide it, the program will ask the name of file in interactive mode. Usually the interactive mode is more convenient and less error-prone.

You can display the wave graphics, using command

drawWave

You also can play generated sound, using command

playsound

However, the audio output implementation in Matlab (not just CASY, but in Matlab package) is very poor. The work-around: save sound in *.wav format using command "writewav", than play it using the player installed on your computer.  


You can put MRI ("X-ray") image on the background of Vocal Tract plot. To read the image file in Haskins format, type the following command:

readimg [fileName | off]

The command readimg without parameters opens a dialog, which let to find the file interactively. Command

readimg off

removes the background MRI.


Similarly, you can read contour(s) or parts of contours from *.mat files, using command 

readcontr [filename | off]

To read a specific contour file, you can use command

readcontr filename

The command 

readcontr

without parameters let select the file interactively. You can use the command several times, with several contour files, to display several contours, or to build a contour from several parts. To remove all contours, use the following command:

readcontr off

The command readcontr reads Matlab format files (*.mat), and displays array XY, stored in the file. It means the contour files must contain a numerical array of size  n by 2, named XY. The two rows of the array stores values of X and Y coordinates. To be displayed, the coordinates must be, respectively, in the range of 0:150 and 0:185 millimeters. 


You can save the current parameters of CASY, using the command

writepar [fileName]

and load them back, using command 

readpar [fileName]

To recalculate the model and to display the results after loading parameters, you need  to give command

refresh

The command "readpar" let you not only reading back saved parameters, but also to load parameter files, edited manually. The files may include arbitrary Matlab scripts. 

Correspondingly, the command "writepar" writes the Matlab script to set all parameters of model. 

If all you need is to change few parameters, sometimes just one or two, you can write a short "*.par" file. To refresh automatically, you can add the "refresh" command to the end of the "*.par" file.  
   
The initial set of parameters is hard-coded in program. It ensure that all parameters will be initialized. However, to let you override the hard-coded parameters automatically, i.e. without issuing every time command "readpar [fileName]", program reads and executes file provided as its argument, or "default.par" file, after hard-coded during initialization, and before calculating model. You can put into the file your own start-up parameters, or even an elaborated script.

If you have any question, e-mail to Yura Koblents <koblents@haskins.yale.edu>. 

===========================================


Version history:

There was no documentation for versions 0.1 to 0.4, and I am trying to reconstruct their history by memory. Starting from version 0.5, I have at least e-mails with user. Starting from version 0.9 will document properly. 



Version 0.1. 

- The underlying model of geometry was implemented, as well as rudimentary graphic representation of outlines. Model concerns the characteristic points. The segments of outlines between the major points were implemented as straight lines.


Version 0.2. 

- Cross-sections and midlines were implemented, as well as their graphic representation. Area function was implemented.


Version 0.3. 

- Interactive input was implemented. It lets user to move the control points (key and geo) using mouse. Model is re-calculating, and picture changes to reflect the user's input.

- Spectrum calculations were implemented, using Matlab modules by Louis Goldstein.

- The second and third windows were added, to display cross-section area and spectrum.


Version 0.4. 

- The program was moved from Matlab 6.1 release 12 to Matlab 6.5 release 13. It required several small changes, like replacing logical operator | by ||, and substantial testing.


Version 0.5. 

- The shape of the bottom (variable) outline was improved. Straight lines were replaced by circular arcs in three segments - like in older versions of Casy. The grid lines, mid lines, areas were changed correspondingly.

- The formants data are stored in global variable, to make them accessible. The names of these variables:

global bandwidths
global formantFreq

- Dozens of smaller fixes and improvements.


Version 0.6. 

- the shape of the upper (fixed) outline was improved. Outlines are implemented using Bezier curves.


Version 0.7.

- improves calculations of sections. In previous version the "classical" trsd (length of one-dimension cross-section) was implemented; now the trsd is the same as in the C/C++ version of Casy for Motif.

It looks, however, that the improvements in trsd did not change the model substantially. 


Version 0.8.

- Bugs were fixed, concerning the first and the last sections of the area tube.

- Graphic output of 3 area functions: as measured in cross-sections, extrapolated, and after  smoothing. Only the last graph was implemented before.


Version 0.9.

- A major bug was fixed, concerning the situation when the bottom (variable) outline intersects the upper (fixed) one. Negative length of cross-sections was replaced by zero one.

Strictly speaking, the intersection is impossible: the tongue cannot pierce the palate, even more the upper teeth. However, the geometry is used when modeling tongue pressing the upper surface of the vocal tract.

- A lot of small improvements in implementation of grid/cross-section/area model.

- The program was made more robust when closing/opening graphic windows, especially during re-runs.

- The legend was added to the areas graph, explaining what curves corresponds to the 3 functions (see version 0.8).

- The graphic windows received proper titles, not "Figure 1", "Figure 2", "Figure 3".


Version 0.9.2:

Just an intermediate version, in preparation for version 10. No new functionality. 

- A lot of minor bugs were fixed, mostly in the grid/area calculations when data are way out of expected range.

- A lot of changes inside program, to make easier to understand/debug/maintain.

- the command to start program was renamed to "casy" from "main".


Version 0.10.0:

- The command 'playsound' was added, to generate sound.

- The command 'drawWave' was added, to display the graph of wave.

- The command 'pcmsound' was added, to read sounds (waves) from files in *.pcm format. It is using internally the Matlab program by Mark Tiede.  

- Generating and drawing waves was integrated into CASY. This subsystem is using Matlab programs by Louis Goldstein.  

Version 0.10.1

- commands "writewav", "readwav", and "writepcm"  were added; command "pcmsound" was renamed into "readpcm"

- The bug when tongue tip crosses the upper surface was exterminated. Turned to be, it was caused not by the crossing, but because a segment of the tongue became convex ("down"), and the program tried to draw a wide concave arc > 180 degrees.

Version 0.10.2

- commands "writepar" and "readpar" were added, to save and load parameters. The "readpar" also executes arbitrary Matlab scripts from files.

- Reading parameters (and executing scripts) from file "default.par" was added to initialization sequence.

- Tinkering with sound quality (not a great success).

- The redundant variable for fundamental frequency was removed, with only SRC_F0 left.

Version 0.10.3

- Spectrum was corrected. In previous versions, a wrong spectrum was displayed: it accounted for resonances only, but did not account for losses. Thanks to Louis Goldstein.

Version 0.10.4

- Spectrum, Area, and Wave Form plots do not refresh anymore after every mouse movement; the plots update after user releases the mouse button. Goal: to improves the program speed in interactive mode. Does not improve enough, however. 

For this a new Matlab function / file named

buttonUp.m 

was added, and the following functions were modified: 

casy.m
plotting.m
startCenter.m
startGeo.m
startKey.m


Version 0.11.1

- the outdated head file 

main.m

replaced long ago by file casy.m and not used for long times, was deleted.


- the global variables for parameters (points), which used to be scatter around many files, were consolidated into a single "include" file named 

pts.m

The functions 

init.m
outline.m

using the above parameters were modified accordingly.


- the two functions 

modkey.m
modgeo.m

were consolidated into

mods.m

while the three small functions: 

startCenter.m
startKey.m
startGeo.m

were consolidated into a single function (with parameter) 

starts.m

calling modes. The function 

drawVT.m

was modified accordingly, to call starts.



- The unwieldy function / file 

grid.m 

was divided into several files:

gridlin.m 
cross.m
area.m
smootharea.m
acoustics.m
 
calculating, respectively, the grid lines, the cross-section, the area function, the smoothed area function, and the acoustics functions - spectrum and wave form. To improve the speed, in the interactive mode the last three functions are called only after the user releases the mouse button. The calling functions

refresh.m
buttonUp.m

were modified accordingly.

The speed improved substantially, but is not good enough for my taste. It still needs more work. 


Version 0.12.1

The MRI image background was added to the plot of Vocal Tract, with a lot of related modifications in the following source files 

drawVT.m 
init.m. 

The source files 

readimg.m
IMGread.m 

were added to read the images.


Version 0.12.2

In the previous version a bug was introduced: when interactively editing vocal tract without the background image, the previous lines failed to erase. The bug eliminated in this version. File 

drawVT.m 

Version 0.12.3

- Removal of background images was implemented using command  

readimg off

- Several bugs concerning the background image were found and eliminated. Most important of the bugs: crashes when user hit the "Cancel" button in the file open dialog when using readimg interactively, and "hoarding" of two and more layers of background images when user read new ones.

- The image output was tuned to make animation smoother and faster.

- Tinkering with colors and line styles (outline, interpolated area function) to make them better stand out from background.

For this the window management was moved from the "draw*.m" modules and was centralized in the new source file named 

winManager.m

The following modules were heavily modified:

drawVT.m
drawArea.m
drawFreq.m
drawWave.m
readimg.m
IMGread.m


Version 0.12.4

Two new GUI modes were implemented: single window (default) and two window, in addition to the four window GUI, implemented eon ego. Switching between the modes using the user command GUI was implemented. Several small bugs were removed, and some useless (redundant or commented out) code was deleted. The windows are opening on the screen now in more convenient positions and have more convenient sizes. For this, the source file winManager.m was heavily rewritten and renamed as

GUI.m

The following source files:

drawVT.m
drawArea.m
drawFreq.m
drawWave.m
readimg.m

were slightly modified, mostly to accommodate renaming winManager as GUI.


Version 0.12.5

Tinkering. Improvements in overlay order, placement, and sizes of windows on screen (GUI mode 2 and 4) and placement and sizes of plots / subplots in windows (all GUI modes). A bug was fixed. The bug was in processing errors in the argument for command GUI. 

Only one source file,

GUI.m

was modified 

Version 0.12.6

New command readcontr was added, to display line contour(s) in the Vocal Tract area. The contours can be used to fit the vocal tract outlines interactively, the same way they can be fit to MRI images. Khalil Iskarous asked for the feature. .

The source file 

readcontr.m

was added, and the file

GUI.m

was modified to implement contours. They are displayed in separate layer of the vocal tract area, on top of image, but below the vocal tract outline.  


Version 0.13.1

The version copes with:

- starting program from working directory, the program files being stored elsewhere, 

- passing names of script files, finalizing initialization, as parameters to program, instead of always using 'default.par' files, 

- searching for the script files in two places: working directory and program directory,  

- running the scripts on computers which do not let overwriting easily existing files. 

The changes were suggested by Christian Kroos. Thank you, Christian.

Files

casy.m
readpar.m

were substantially rewritten in the version. 
 
======================================================


Known and suspected bugs, and needed improvements:

* some of the "circuits breakers" in calculating grid were improved, but other were removed temporarily in version 0.11.1. They will be replaced by a better code in future, but the code is not ready yet.

Reason: the grid calculations are both slow and prone to erroneous results when parameters (positions of control points) have bad values. This part of program needs to be rewritten using the proper geometric algorithms. 

* The wrong formula is used when calculating area in the lips region of the vocal tract. 

This is a very old bug. It was inherited from MCASY, i.e. the C/C++, Motif version of CASY. In its turns, MCASY inherited the bug pre-1996, pre-Motif version of CASY for VAX. Khalil told to postpone fixing it - to make it easier to compare output of Matlab version with output MCASY.

* Sequence must be implemented. Ignatius Mattingly and Khalil Iskarous need it strongly.

* The quality of sound, as produced by command "playsound", is very bad. This is due to very bad implementation of sound output in Matlab. It simply dump sound on audio device, with 8-bit precision, and without setting sample rate. See the source file /usr2/matlabR13/toolbox/matlab/audio/private/playsnd.m and *.c files in the same directory. Must be rewritten, separately for different types of computers - Linux and Windows.  

* There is a strong 100Hz component in sound, without visible counterpart in spectrum. I guess the sound came from the fundamental frequency. Ignatius Mattingly consider it OK, and the 100Hz component is present also in the C++ version of MCASY. However, I would like to discuss with Louis.

Or it may be cased by discretization (one pulse). 

* A strong sound is generated even when the area turns to zero (tongue crosses the upper surface of the vocal tract).

* The user interface. Ignatius Mattingly does not like slow redrawing of pictures when moving the Key/Geo points with mouse around the Vocal Tract window. Possible solutions: not calculating not displayed info, depending on what windows are open, and/or recalculating info only after finishing with moving pointer (on mouse button up). 

-> The speed substantially increased in the version 0.11.1, but needs future improvement. Some of the improvement were copied also from version 0.11.1 to the version 0.10.4.

* Louis Goldstein found a problem with tongue tip.

* Louis Goldstein wants options to display the KEY points only, without GEO parameters, and to display outline without gridlines and/or midlines. 

* Louis Goldstein wants to display values of the first five formants in the Spectrum graph.

* Redrawing of the MRI image background when tuning model interactively is very slow when running the program remotely from X-terminal over Internet (cable). Starting from version 0.12.3 the speed is fine when running the program directly at workstation: practically no difference weather using MRI background or not. Speed over network was improved in version 0.12.3, but still is not good. 

* Tuning of brightness, contrast, placing, and scaling of the background image was not implemented yet. It is possible to do this, but only using inconvenient workaround.

* Better tuning of position of windows and of subplots inside windows would improve the program. Particularly, the overlay order of windows on the screen, the asymmetry of waveform axis with 4-window GUI (3/4 positive number, 1/4 negative), and placement of windows in 4- and 2-window GUI.
