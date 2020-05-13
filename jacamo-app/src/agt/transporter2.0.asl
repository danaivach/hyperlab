
/* General Plans */

+!push(X1,Y1,X2,Y2) : true <-
	move(X1,Y1)[artifact_name("Robot2")];
	attach[artifact_name("Robot2")];
	move(X2,Y2)[artifact_name("Robot2")];
	detach[artifact_name("Robot2")].
