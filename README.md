# robo_bee
The repository contains the code that comes with the robobee publication. It provides preprocessing methods on robotic and natural dances and following. If furtermore has a visualisation method to plot trajectories on videos. Furthermore, code about analytics is available.

The **trajectory_processing** folder provides methods to rectify a given track, to interpolate and thereby upsample the track to fill frame gaps, and it provides the methods to rectify a video. The `rectifyTrack`- and the `splineInterpolateTrack`-functions can be called seperately, the `process_dataset`-skript can be used to have them executed over a whole folder structure.

The **visualization** folder contains a script to draw trajectories of followers and dancers on given videos for validation purpose. Use the `displayAllTrajectoriesInFolder` function to start displaying. You need to provide one of the following fileendings `*.raw`, `*.rect`, or `*.ups` to load the corresponding data.

The **analyses** folder provides scripts to reproduce the results presented in the paper. 
* `analyzeHeadBodyDistancesAndAngles`: To analyze the head-body distances and the angle between dancer and follwer.
