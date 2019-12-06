/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

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

/* Move item from A to C */

+!start : environment_IRI(EnvIRI) <- 
	.print("Hello world, I'm Transporter 2.0. Let's see if I can help in the environment: ",EnvIRI);
	.wait(1000);
	.send(node_manager, achieve, environment_loaded(EnvIRI)).
	

+environment_loaded(EnvIRI, WorkspacesNames) : true <-
	.print("Environment loaded: ", EnvIRI);
	!manageOrders.

+!manageOrders : order(PR) <-
	 .print("A new order has been placed!");
	!deliver(PR,[7,3,5],[7,9,5]);
	!ship(PR,[7,9,5]).

+moved(L) : true <- .print("Received moved to ", L, " signal ").

+grasped : true <- .print("Received grasped signal").

+released : true <- .print("Received released signal"). 

+pickedAndPlaced(L1,L2) : true <- .print("Received pickedAndPlaced from ", L1, " to ", L2, " signal").

+product(PR,L) : true <- .print("Product ", PR, " at location ", L).

+!ship(PR,L) : product(PR,L) <- .print("Order ready to get shipped!").

+!deliver(PR,SRC,DST) : bench("A",SRC) & bench("C",DST) & product(PR,SRC) <-
	?bench("B",B);
	?bench("C",C);
	!deliver(SRC,B);
	-+product(PR,B);
	!deliver(B,DST);
	-+product(PR,DST).
	
+!deliver(SRC,DST) : bench("A",SRC) & bench("B",DST) <-
	.print("r1 will deliver from location ", SRC, " to location ", DST);
	move(SRC)[artifact_name(r1)];
	grasp[artifact_name(r1)];
	move(DST)[artifact_name(r1)];
	release[artifact_name(r1)].


+!deliver(SRC,DST) : bench("B",SRC) & bench("C",DST) &
   	 	thing_artifact_available(_, ArtifactName, WorkspaceName) &
    	//	hasAction(_,ACT)[artifact_name(_, ArtifactName)] 
		hasAction(_,"http://example.com/PickAndPlace")[artifact_name(_,ArtifactName)]
  	<-	.print("rrrrrrrrrrrrrrrrrrrrrrrready to deliver with thing artifact ", ArtifactName);
		.nth(0,SRC,X1);
		.nth(0,SRC,Y1);
		.nth(0,SRC,Z1);
		.nth(0,DST,X2);
		.nth(0,DST,Y2);
		.nth(0,DST,Z2);
  		act("http://example.com/PickAndPlace",[["http://www.w3c.org/ns/td#Number",X1],["http://www.w3c.org/ns/td#Number",Y1]])[artifact_name(ArtifactName)].
		
+thing_artifact_available(ArtifactIRI, ArtifactName, WorkspaceName) : true <-
  	.print("A thing artifact is available: " , ArtifactIRI, " in workspace: ", WorkspaceName);
  	joinWorkspace(WorkspaceName, WorkspaceArtId);
	focusWhenAvailable(ArtifactName).

/*
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


+!deliver(SRC,DST) : bench("D",SRC) & bench("E",DST) <-
	.print("r4 will deliver from location ",SRC," to location ",DST);
	pickAndPlace(SRC,DST)[artifact_name(r4)].

//Plans Type B (hardly)

+!deliver(SRC,DST) : true <- 
	.print("Let's ask an agent");
	!askAgent({deliver}).


+!consultArtifactManual(G) : artifact_available(_,ArtifactName,WorkSpace)
			& artifact_manual_available(_,ArtifactName, Manual)
			& 

+!searchArtifactManual(G)

+!askAgent(G) : true <-
	.print("Ask the manager agent for a plan");
	.send(manager, askHow, {+!deliver}, Plans);
	.add_plan(Plans);
	.print("Plan received");
	!deliver.
	

//not like that but 
+!consultArtifactManual : thing_artifact_available(_,ArtifactName,WorkspaceName)
			& hasProperty(_,"cartago:Manual")[artifact_name(_,ArtifactName)]
		        & hasUsageProtocol(_,"cartago:")[artifact_name(_,ArtifactName)]
	<-
*/
	
  

{ include("$jacamoJar/templates/common-cartago.asl")} 

