/* Initial beliefs and rules */
bench("D",[7,12,5]).
bench("E",[7,15,5]).

/* General Plans */

+!deliver: true <-
	.print("originally from manager:");
	.print("r4 would deliver from location SRC  to location  DST if there were any parameters").

