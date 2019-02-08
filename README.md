# CIS 566 Homework 2: Raymarching SDFs

## Overview

Matthew Riley\
PennKey: matriley\
Live at: https://mgriley.github.io/hw02-raymarching-sdfs/

![](demo_shot.png)

## Description:

The scene itself isn't impressive, but there are several sdf engine features that I'm proud of. The castle makes heavy use of the mirror and linear pattern functions, which are generalizations of the "symmetry" and "repetition" techniques mentioned in IQ's article on distance functions. The four turrets are actually mirrored single turrets, the turret windows are mirrored and revolved around the center of the turrets, and the ridges on the peaks of the turret are patterned along one dimension then mirrored twice to reproduce them along the entire perimeter.

Combination operations: op_union and op_diff are heavily used, as well as their smooth variations.

Raymarch Optimization: Haven't yet implemented.

Animation: The draw-bridge angle should animate.

Toolbox Functions: I did not use any for animation.

Procedural Texturing: The "grass" uses gradient noise.

Shading: I compute the surface normal using the gradient technique. The inner edges of the moat use the surface normal to create a dirt appearance. Sadly I did not get around to adding water, so there is also grass along the bottom.

Here are some features of the engine:

* Elongation, rounding, extrusion, and revolution
* Union, intersect, and difference, with smooth variations
* mirror operator, to mirror across an arbitrary plane
* repeat operator, to linearly repeat some geometry across many grid cells
* revolve operator, to revolve some geometry around a point
* local_pos operator, to rotate about an arbitrary axis then translate some geom
* A very handy variation of the sd_box function that allows you to specify the anchor point of the box
* AO using five-point method

## Sources

https://www.iquilezles.org/www/material/nvscene2008/rwwtt.pdf
https://www.iquilezles.org/www/articles/filteringrm/filteringrm.htm
https://www.iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
https://www.iquilezles.org/www/articles/smin/smin.htm
https://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
https://www.iquilezles.org/www/articles/sdfmodeling/sdfmodeling.htm
http://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm
http://iquilezles.org/www/articles/functions/functions.htm
https://www.iquilezles.org/www/articles/functions/functions.htm
https://www.shadertoy.com/view/4tByz3
https://www.shadertoy.com/view/Xds3zN

