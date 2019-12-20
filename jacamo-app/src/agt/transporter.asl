/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

bench("A",[200,300]).
bench("B",[300,300]).
bench("C",[400,200]).
bench("D",[500,300]).

//destination
destination(600,300).

inRange(ArtifactName,X,Y)
	:- location(ArtifactName,Xr,Yr) &
		range(ArtifactName,R) &
		 (X-Xr)*(X-Xr) + (Y-Yr)*(Y-Yr) <= R*R.


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
	+item_free;
	+item_position(200,300).


+item_position(X1,Y1): destination(X2,Y2) &
			X1=X2 &
			Y1=Y2 <-
			.print("Item is in its destination").


+item_position(X1,Y1): true <-
		.print("Item in location (",X1,",",Y1,")");
		?destination(X2,Y2);
		!deliver(X1,Y1,X2,Y2).

+location(ArtifactName,Xr,Yr) : true <-
	.print(ArtifactName, " has property location at (", Xr,",", Yr,")").

+range(ArtifactName,R) :true <-
	.print(ArtifactName, " has property range ",R).

+rotating(D) : true <- .print("Received signal: robot1 rotating ", D, " degrees");
			rotate("robot1",D)[artifact_name(floorMap)].

+grasping : true <- .print("Received signal: robot1 grasping").

+releasing : true <- .print("Received signal: robot1 releasing"); 
			+item_free. 

+mounting : true <- .print("Received signal: robot2 mounting").

+item_free : true <- .print("Item is not mounted").

+moving(X,Y) : true <- .print("Received signal: robot2 moving to (",X,",",Y,")");
			move("robot2",X,Y)[artifact_name(floorMap)].

-item_free :true <- .print("Item is mounted").


+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName,WorkspaceName) &
			hasAction(_,"http://example.com/Base")[artifact_name(_,ThingArtifactName)] &
			hasAction(_,"http://example.com/Gripper")[artifact_name(_,ThingArtifactName)] &
			inRange(ThingArtifactName,X1,Y1) &
			inRange(ThingArtifactName,X2,Y2) &
			item_free<-
			.print("Plan C: Ready to deliver with thing artifact ", ThingArtifactName, " from (",X1,",",Y1,") to (",X2,",",Y2,")");
			//act("http://example.com/Base",[["http://example.com/Value", 512]])[artifact_name(ThingArtifactName)];
			-+item_position(X2,Y2).

			
+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName, WorkspaceName) &
			artifact_available("www.Robot2",R2Name,WorkspaceName) &
			inRange(ThingArtifactName,X2,Y2) &
			not item_free <- 
			.print("Plan B : Ready to deliver with artifact ", R2Name, " from (",X1,",",Y1,") to (",500,",",300,")");
			move(500,300)[artifact_name(R2Name)];
			release[artifact_name(R2Name)];
			-+item_position(500,300).


+!deliver(X1,Y1,X2,Y2) : item_free & 
			artifact_available("www.Robot1",R1Name,WorkspaceName) &
			artifact_available("www.Robot2",R2Name,WorkspaceName) &
			inRange(R1Name,X1,Y1) &
			inRange(R1Name,X1,Y2) <- 
			//inRange(X1)[artifact_name(R1Name)]  <-
			.print("Plan A: Ready to deliver with artifact ", R1Name, " from (",X1,",",Y1,") to (",X1,",",Y2,")");
			move(X1,Y1)[artifact_name(R2Name)];
			rotateTowards(X1,Y1)[artifact_name(R1Name)];
			grasp[artifact_name(R1Name)];
			rotateTowards(X1,Y2)[artifact_name(R1Name)];
			release[artifact_name(R1Name)];
			mount[artifact_name(R2Name)];
			-item_free;
			-+item_position(X1,Y2).

		
+artifact_available("www.Robot1",ArtifactName,WorkspaceName) : true <-
	.print("An artifact is available: ", ArtifactName, " in ", WorkspaceName);
	joinWorkspace(WorkspaceName,WorkspaceArtId);
	focusWhenAvailable(ArtifactName);
	?location(X,Y);
	?range(R);
	+location(ArtifactName,X,Y);
	+range(ArtifactName,R).


+artifact_available(_,ArtifactName,WorkspaceName) : true <-
	.print("An artifact is available: ", ArtifactName, " in ", WorkspaceName);
	joinWorkspace(WorkspaceName,WorkspaceArtId);
	focusWhenAvailable(ArtifactName).
	


+thing_artifact_available(ArtifactIRI, ArtifactName, WorkspaceName) : true <-
  	.print("A thing artifact is available: " , ArtifactIRI, " in workspace: ", WorkspaceName);
  	joinWorkspace(WorkspaceName, WorkspaceArtId);
	focusWhenAvailable(ArtifactName);
	+location(ArtifactName,550,300);
	+range(ArtifactName,50).

+hasAction(_,_): true <- .print("Action detected").










/* 
+!deliver(SRC,DST) : bench("B",SRC) & bench("C",DST) &
   	 	thing_artifact_available(_, ArtifactName, WorkspaceName) &
		.nth(0,SRC,X1);
		.nth(1,SRC,Y1);
		.nth(2,SRC,Z1);
		.nth(0,DST,X2);
		.nth(1,DST,Y2);
		.nth(2,DST,Z2);
  		
*/


/*

//Plans Type B 

+!consultArtifactManual(G) : artifact_available(_,ArtifactName,WorkSpace)
			& artifact_manual_available(_,ArtifactName, Manual)	

//not like that but 
+!consultArtifactManual : thing_artifact_available(_,ArtifactName,WorkspaceName)
			& hasProperty(_,"cartago:Manual")[artifact_name(_,ArtifactName)]
		        & hasUsageProtocol(_,"cartago:")[artifact_name(_,ArtifactName)]
	<-
*/
	
  

{ include("$jacamoJar/templates/common-cartago.asl")} 
{ include("$jacamoJar/templates/common-moise.asl")}
