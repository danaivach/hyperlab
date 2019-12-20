/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

//destination
destination(600,400).

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
	+item_position(200,400).


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


+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName,WorkspaceName) &
			hasAction(_,"http://example.com/Base")[artifact_name(_,ThingArtifactName)] &
			hasAction(_,"http://example.com/Gripper")[artifact_name(_,ThingArtifactName)] &
			inRange(ThingArtifactName,X1,Y1) &
			inRange(ThingArtifactName,X2,Y2) &
			item_free<-
			!deliver(ThingArtifactName,X1,Y1,X2,Y2).

			
+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName, WorkspaceName) &
			artifact_available("www.Robot2",R2Name,WorkspaceName) &
			inRange(ThingArtifactName,X2,Y2) &
			not item_free <- 
			.print("Plan B : Ready to deliver with artifact ", R2Name, " from (",X1,",",Y1,") to (",500,",",300,")");
			move(500,400)[artifact_name(R2Name)];
			unload[artifact_name(R2Name)];
			+item_free;
			-+item_position(500,400).


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
			load[artifact_name(R2Name)];
			-item_free;
			-+item_position(X1,Y2).

+!deliver(ThingArtifactName,X1,Y1,X2,Y2): true <-
			.print("Plan C: Ready to deliver with thing artifact ", ThingArtifactName, " from (",X1,",",Y1,") to (",X2,",",Y2,")");
			//TODO: These will be events from the Thing Artifact
			+rotating(ThingArtifactName,180);
			+grasping(ThingArtifactName);
			+rotating(ThingArtifactName,0);
			+releasing(ThingArtifactName);
			//act("http://example.com/Base",[["http://example.com/Value", 512]])[artifact_name(ThingArtifact)];
			-+item_position(X2,Y2).

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
	+location(ArtifactName,550,400);
	+range(ArtifactName,50).

+hasAction(_,_): true <- .print("Action detected").


+rotating(D) : true <- .print("Received signal: Robot1 rotating ", D, " degrees");
			robotArmRotate("robot1",D)[artifact_name(floorMap)].

+grasping : true <- .print("Received signal: Robot1 grasping");
		robotArmGrasp("robot1")[artifact_name(floorMap)].

+releasing : true <- .print("Received signal: Robot1 releasing");
			robotArmRelease("robot1")[artifact_name(floorMap)].

+loading : true <- .print("Received signal: Robot2 loading");
			-item_free;
			driverLoad("robot2")[artifact_name(floorMap)].

+unloading : true <- .print("Received signal: Robot2 unloading");
			+item_free;
			driverRelease("robot2")[artifact_name(floorMap)].

+moving(X,Y) : true <- .print("Received signal: Robot2 moving to (",X,",",Y,")");
			driverMove("robot2",X,Y)[artifact_name(floorMap)].

+rotating(ThingArtifactName,D) : true <- .print("Received signal: ",ThingArtifactName," rotating ", D, " degrees");
					.wait(2000);
					robotArmRotate(ThingArtifactName,D)[artifact_name(floorMap)].

+grasping(ThingArtifactName) : true <- .print("Received signal: ",ThingArtifactName," grasping");
		.wait(2000);
		robotArmGrasp(ThingArtifactName)[artifact_name(floorMap)].

+releasing(ThingArtifactName) : true <- .print("Received signal: ",ThingArtifactName, " releasing");
			.wait(2000);
			robotArmRelease(ThingArtifactName)[artifact_name(floorMap)].


+item_free : true <- .print("Item is not loaded").

-item_free :true <- .print("Item is loaded").


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
