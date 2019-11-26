/* Initial beliefs and rules */
bench("A",[7,3,5]).
bench("B",[7,6,5]).
bench("C",[7,9,5]).
bench("D",[7,12,5]).
bench("E",[7,15,5]).

product(111,[7,3,5]).

order(111).

/*Initial goals */

!start.

/* General Plans */


+!start : order(PR)
	 <- .print("A new order has been placed!");
	!deliver(PR,[7,3,5],[7,15,5]);
	!ship(PR,[7,15,5]).

+moved(L) : true <- .print("Received moved to ", L, " signal ").

+grasped : true <- .print("Received grasped signal").

+released : true <- .print("Received released signal"). 

+pickedAndPlaced(L1,L2) : true <- .print("Received pickedAndPlaced from ", L1, " to ", L2, " signal").

+product(PR,L) : true <- .print("Product ", PR, " at location ", L).

+!ship(PR,L) : product(PR,L) <- .print("Order ready to get shipped!").

+!deliver(PR,SRC,DST) : bench("A",SRC) & bench("E",DST) & product(PR,SRC) <-
	?bench("B",B);
	?bench("C",C);
	?bench("D",D);
	!deliver(SRC,B);
	-+product(PR,B);
	!deliver(B,C);
	-+product(PR,C);
	!deliver(C,D);
	-+product(PR,D);
	!deliver(D,DST);
	-+product(PR,DST).
	
+!deliver(SRC,DST) : bench("A",SRC) & bench("B",DST) <-
	.print("r1 will deliver from location ", SRC, " to location ", DST);
	move(SRC)[artifact_name(r1)];
	grasp[artifact_name(r1)];
	move(DST)[artifact_name(r1)];
	release[artifact_name(r1)].

+!deliver(SRC,DST) : bench("B",SRC) & bench("C",DST) <-
	.print("r2 will deliver from location ", SRC," to location ",DST);
	initialize("default")[artifact_name(r2)];
	move(SRC)[artifact_name(r2)];
	grasp[artifact_name(r2)];
	move(DST)[artifact_name(r2)];
	release[artifact_name(r2)].

+!deliver(SRC,DST) : bench("C",SRC) & bench("D",DST) <-
	.print("r3 will deliver from location ", SRC, " to location ", DST);
	pickAndPlace(SRC,DST)[artifact_name(r3)].

/*
+!deliver(SRC,DST) : bench("D",SRC) & bench("E",DST) <-
	.print("r4 will deliver from location ",SRC," to location ",DST);
	pickAndPlace(SRC,DST)[artifact_name(r4)].
*/
//Plans Type B (hardly)

+!deliver(SRC,DST) : true <- 
	.print("Let's ask an agent");
	!askAgent({deliver}).

/*
+!consultArtifactManual(G) : artifact_available(_,ArtifactName,WorkSpace)
			& artifact_manual_available(_,ArtifactName, Manual)
			& 

+!searchArtifactManual(G)
*/
+!askAgent(G) : true <-
	.print("Ask the manager agent for a plan");
	.send(manager, askHow, {+!deliver}, Plans);
	.add_plan(Plans);
	.print("Plan received");
	!deliver.
	
/*
//not like that but 
+!consultArtifactManual : thing_artifact_available(_,ArtifactName,WorkspaceName)
			& hasProperty(_,"cartago:Manual")[artifact_name(_,ArtifactName)]
		        & hasUsageProtocol(_,"cartago:")[artifact_name(_,ArtifactName)]
	<-
*/
	
  

{ include("$jacamoJar/templates/common-cartago.asl")} 

