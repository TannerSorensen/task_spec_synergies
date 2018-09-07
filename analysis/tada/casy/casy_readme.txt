Copyright Haskins Laboratories, Inc., 2001-2003
   270 Crown Street, New Haven, CT 06514, USA
   programmer Yuriy Koblents-Mishke
   e-mail koblents@haskins.yale.edu

Haskins Laboratories.

CASY for Matlab.

Pre-beta-test version 0.10.3 


-----------------------------------------------------------
To work with the program, first enter Matlab rev.13. 

In my experience, it is better to use it is in command line environment.

The integrated Matlab environment ("desktop") is fine if your system is rich in real estate, for example have two big monitors, but on smaller screens it does not leave enough place for graphic programs.

Additionally, when working from remote terminal, X-terminal, etc, the integrated Matlab environment is slow to crawl. 


To start Matlab rev.13, you can give the following Linux command 

./matlab13

or 

./matlab13 -nosplash -nodesktop 

--------------------------------------------



To start CASY for Matlab, give the following command (under Matlab):

casy 

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

You can save the current parameters of CASY, using the command

writepar [fileName]

and load them back, using command 

readpar [fileName]

To recalculate the model and to display the results after loading parameters, you need  to give command

refresh

The command "readpar" let you not only reading back saved parameters, but also to load parameter files, edited manually. The files may include arbitrary Matlab scripts. 

Correspondingly, the command "writepar" writes the Matlab script to set all parameters of model. 

If all you need is to change few parameters, sometimes just one or two, you can write a short "*.par" file. To refresh automatically, you can add the "refresh" command to the end of the "*.par" file.  
   
The initial set of parameters is hard-coded in program. It ensure that all parameters will be initialized. However, to let you override the hard-coded parameters automatically, i.e. without issuing every time command "readpar [fileName]", program reads (executes) file "default.par" during initialization, before calculating model. You can put into the 'default.par' file your own start-up parameters, or even a script to execute during initialization.

If there is no 'default.par' file in your directory, program still works OK. However, it is better create at least an empty 'default.par' file  - to avoid nuisance diagnostic messages.


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

- The formats data are stored global variable, to make them accessible. The names of these variables:

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

- Reading parameters (and executing scripts) from file "default.par" was added to initilaization sequence.

- Tinkering with sound quality (not a great success).

- The redundant variable for fundamental frequency was removed, with only SRC_F0 left.

Version 0.10.3

- Spectrum was corrected. In previous versions, a wrong spectrum was displayed: it accounted for resonances only, but did not account for losses. Thanks to Louis Goldstein.

======================================================


Known and suspected bugs, and needed improvements:

* The wrong formula is used when calculating area in the lips region of the vocal tract. 

This is a very old bug. It was inherited from MCASY, i.e. the C/C++, Motif version of CASY. In its turns, MCASY inherited the bug pre-1996, pre-Motif version of CASY for VAX. Khalil told to postpone fixing it - to make it easier to compare output of Matlab version with output MCASY.

* Program behaves strange when the center of grid is moved far right.

* Sequence must to be implemented ASAP. Ignatius Mattingly and Khalil Iskarous need it strongly.

* The quality of sound, as produced by command "playsound", is very bad. This is due to very bad implementation of sound output in Matlab. It simply dump sound on audio device, with 8-bit precision, and without setting sample rate. See the source file /usr2/matlabR13/toolbox/matlab/audio/private/playsnd.m and *.c files in the same directory. Must be rewritten, separately for different types of computers - Linux and Windows.  

* There is a strong 100Hz component in sound, without visible counterpart in spectrum. I guess the sound came from the fundamental frequency. Ignatius Mattingly consider it OK, and the 100Hz component is present also in the C++ version of MCASY. However, I would like to discuss with Louis.

* A strong sound is generated even when the area turns to zero (tongue crosses the upper surface of the vocal tract).

* The user interface, with 4 separate windows for vocal tract, area, spectrum, and wave graphs, is inconvenient on smaller screens. Khalil Iskarous suggested to combine the graphs as subplots in one or two windows (panels). Louis Goldstein insists on 2 panels, not one, and 4-windows as an option.

* The user interface. Ignatius Mattingly does not like slow redrawing of pictures when moving the Key/Geo points with mouse around the Vocal Tract window. Possible solutions: not calculating not displayed info, depending on what windows are open, and/or recalculating info only after finishing with moving pointer (on mouse button up).

* Louis Goldstein found a problem with tongue tip.

* Louis Goldstein wants options to display the KEY points only, without GEO parameters, and to display outline without gridlines and/or midlines. 

* Louis Goldstein wants to display values of the first five formants in the Spectrum graph.