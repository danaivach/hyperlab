/* Initial beliefs and rules */

/*Initial goals */

!start.

/* General Plans */

+!start : true
	 <- .print("Hello from me too");
            !move(111).

+!move(X) : true
	<- .print("Time to move product ", X).  

{ include("$jacamoJar/templates/common-cartago.asl") }
