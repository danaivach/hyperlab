/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

bench("A",[200,300]).
bench("B",[300,300]).
bench("C",[400,200]).
bench("D",[500,300]).

//destination
destination(250,500).

inRange(ArtifactName,X,Y)
	:- location(ArtifactName,Xr,Yr) &
		range(ArtifactName,R)&
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
			robotArmRotate("robot1",D)[artifact_name(floorMap)].

+grasping : true <- .print("Received signal: robot1 grasping").

+releasing : true <- .print("Received signal: robot1 releasing");
			-mounted.

+mounting : true <- .print("Received signal: robot2 mounting").

+moving(X,Y) : true <- .print("Received signal: robot2 moving to (",X,",",Y,")");
			driverMove("robot2",X,Y)[artifact_name(floorMap)].



+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ArtifactName,WorkspaceName) &
			hasAction(_,"http://example.com/Base")[artifact_name(_,ArtifactName)] &
			hasAction(_,"http://example.com/Gripper")[artifact_name(_,ArtifactName)] <-
			.print("Ready to deliver with thing artifact ", ArtifactName);
			act("http://example.com/Base",[["http://example.com/Value", 512]])[artifact_name(ArtifactName)];
			-+location(X2,Y2).




+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,RoboticArmArtifact, WorkspaceName) &
			artifact_available(_,DriverArtifact,WorkspaceName) &
			inRange(RoboticArmName,X1,Y1) &
			inRange(RoboticArmName,X2,Y2) &
			mounted <-
			release[artifact_name(DriverArtifact)];
			move(X1,Y1)[artifact_name(RoboticArmArtifact)];
			grasp[artifact_name(RoboticArmArtifact)];
			move(X2,Y2)[artifact_name(RoboticArmArtifact)];
			release[artifact_name(RoboticArmArtifact)];
			-+item_position(X2,Y2).



+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot1",RoboticArmName,WorkspaceName) &
			artifact_available("www.Robot2",DriverName,WorkspaceName) &
			inRange(RoboticArmName,X1,Y1) &
			inRange(RoboticArmName,X1,Y2) <-
			//inRange(X1)[artifact_name(RoboticArmName)]  <-
			.print("Ready to deliver from (",X1,",",Y1,") to (",X1,",",Y2,") lets squise a sin " ,sin(1));
			move(X1,Y1)[artifact_name(DriverName)];
			rotateTowards(X1,Y1)[artifact_name(RoboticArmName)];
			grasp[artifact_name(RoboticArmName)];
			rotateTowards(X1,Y2)[artifact_name(RoboticArmName)];
			release[artifact_name(RoboticArmName)];
			mount[artifact_name(DriverName)].
			//-+item_position(X2,Y1).


+mounted : true <- .print("finally mounted").


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
