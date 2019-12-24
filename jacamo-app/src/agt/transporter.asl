/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").
//interactionsWkspIRI("http://localhost:8080/workspaces/interactionsWksp").

search_engine_URI("http://localhost:9090/searchEngine").
crawler_URI("http://localhost:9090/crawler").
has_manual_link("{'link': 'http://w3id.org/eve#hasManual'}").

/* Destination set to (600,400) */
destination(600,400).


/* True if (X,Y) is in range of Artifact */
in_range(ArtifactName,X,Y)
	:- location(ArtifactName,Xr,Yr) &
	range(ArtifactName,R) &
	(X-Xr)*(X-Xr) + (Y-Yr)*(Y-Yr) <= R*R.


/* True if there is a plan in list P for goal G in the library. */
in_library(G)
	:- .relevant_plans(G,P) & 
	not .empty(P) & 
	.print("A relevant plan is in the plan library: ", G).


/*Initial goals */

!start.

/* General Plans */

/* Move item from its position to a destination */

+!start : environment_IRI(EnvIRI) <-
	.print("Hello WWWorld. This is Transporter 1.0! Let's see if I can help in the environment: ",EnvIRI);
	.wait(1000);
	.send(node_manager, achieve, environment_loaded(EnvIRI));
	!setUpSearchEngine.


+environment_loaded(EnvIRI, WorkspacesNames) : true <-
	.print("Environment loaded: ", EnvIRI);
	.wait(3000).
//	!findAndConsultManual("identified","identified").


+item_position(X1,Y1): destination(X2,Y2) &
	X1=X2 & Y1=Y2 <-
	.print("Item is in its destination").


+item_position(X1,Y1): destination(X2,Y2) <-
	.print("Item in location (",X1,",",Y1,")");
	!deliver(X1,Y1,X2,Y2).


+location(ArtifactName,Xr,Yr) : true <-
	.print(ArtifactName, " has property location at (", Xr,",", Yr,")").


+range(ArtifactName,R) :true <-
	.print(ArtifactName, " has property range ",R).

+!push(X1,Y1,X2,Y2) : true <-
	move(X1,Y1);
	attach;
	move(X2,Y2);
	release.

+!pickAndPlace(ArtifactName, D1,D2) :  true <-
	rotate(D1)[artifact_name(ArtifactName)];
	grasp[artifact_name(ArtifactName)];
	rotate(D2)[artifact_name(ArtifactName)];
	release[artifact_name(ArtifactName)].


+!pickAndPlace(ThingArtifactName,D1,D2,D3): true <-
	.print("Plan: Deliver with Thing artifact ",ThingArtifactName);
	//TODO: These will be events from the Thing Artifact
	-+rotating(ThingArtifactName,D1);
	-+grasping(ThingArtifactName);
	-+rotating(ThingArtifactName,D2);
	-+releasing(ThingArtifactName).
	//act("http://example.com/Base",[["http://example.com/Value", 512]])[artifact_name(ThingArtifact)].

+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName,WorkspaceName) &
	hasAction(_,"http://example.com/Base")[artifact_name(_,ThingArtifactName)] &
	hasAction(_,"http://example.com/Gripper")[artifact_name(_,ThingArtifactName)] &
	in_range(ThingArtifactName,X1,Y1) &
	in_range(ThingArtifactName,X2,Y2) <-
	?location(ThingArtifactName,Xr,Yr);
	angularDisplacement(X1,Y1,Xr,Yr,D1);
	angularDisplacement(X2,Y2,Xr,Yr,D2);
	.print("Need Thing artifact to deliver from (",X1,",",Y1,") to (",X2,",",Y2,")");
	!pickAndPlace(ThingArtifactName,D1,D2,512);
	-+item_position(X2,Y2).


+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot1",R1Name,WorkspaceName) &
	artifact_available("www.Robot2",R2Name,WorkspaceName) &
	in_range(R1Name,X1,Y1)  &
	not in_range(R1Name,X2,Y2) &
	in_library({+!drive(X1,Y1,X2,Y2)})  <- 
	.print("Ready to deliver with artifact ", R1Name);
	?location(R1Name,Xr,Yr);
	?range(R1Name,R);
	angularDisplacement(X1,Y1,Xr,Yr,D1);
	angularDisplacement(X2,Y2,Xr,Yr,D2);
	lineCircleCloseIntersection(X2,Y2,Xr,Yr,R,Xi,Yi);
	!pickAndPlace(R1Name,D1,D2);
	.print("Ready to deliver with artifact ", R2Name);
	!drive(300,400,500,400);
	-+item_position(500,400).

/*
+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot2",R2Name,WorkspaceName)
 <-	!push(X1-5,Y1-10,500,400);
	-+item_position(500,400).
*/

-!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot1",R1Name,WorkspaceName) &
	artifact_available("www.Robot2",R2Name,WorkspaceName) &
	in_range(R1Name,X1,Y1)  &
	not in_range(R1Name,X2,Y2) <-
	!findAndConsultManual("drive(X1,Y1,X2,Y2)",R2Name);
	!deliver(X1,Y1,X2,Y2).


+!findAndConsultManual(Goal,ArtifactName) :  hasUsageProtocol(_,_,Content) <-
	.print("Found an applicable plan for goal ", Goal, " in the manual of ", ArtifactName);
	.add_plan(Content);
	.print("A new plan is added in the plan library").


/*
+!findAndConsultManual(Goal,ArtifactName) : search_engine_available(SearchEngineId,CrawlerId) <-
	searchArtifact("eve: <http://w3id.org/eve#>","","eve:isRobot", "", SubjectResult, PredicateResult, ObjectResult)[SE];
	.print("found robot ", SubjectResult).

-!findAndConsultManual(Goal,ArtifactName) : search_engine_available(SearchEngineId,CrawlerId) <-
	.wait(3000);
	!findAndConsultManual("","").
*/

+!setUpSearchEngine : search_engine_URI(SearchEngineURI) &
	crawler_URI(CrawlerURI) <-
	?environment_IRI(IIRI);
	makeArtifact("se", "www.SearchEngineArtifact", [SearchEngineURI], SE);
	makeArtifact("ce", "www.CrawlerEngineArtifact", [CrawlerURI] , CE);
	addSeed("http://localhost:8080/workspaces/interactionsWksp")[CE];
//	?has_manual_link(HasManual);
//	registerLink()[CE];
	+search_engine_available(SE,CE).
 
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

+rotating(D) : true <-
	.print("Received signal: Robot1 rotating ", D, " degrees");
	robotArmRotate("robot1",D)[artifact_name(floorMap)].

+grasping : true <- 
	.print("Received signal: Robot1 grasping");
	robotArmGrasp("robot1")[artifact_name(floorMap)].

+releasing : true <- 
	.print("Received signal: Robot1 releasing");
	robotArmRelease("robot1")[artifact_name(floorMap)].

+loading : true <- 
	.print("Received signal: Robot2 loading");
	driverLoad("robot2")[artifact_name(floorMap)].

+unloading : true <- .print("Received signal: Robot2 unloading");
	driverRelease("robot2")[artifact_name(floorMap)].

+attaching : true <- .print("Received signal: Robot2 attaching");
	driverAttach("robot2")[artifact_name(floorMap)].

+detaching : true <- .print("Received signal: Robot2 detatching");
	driverRelease("robot2")[artifact_name(floorMap)].

+moving(X,Y) : true <- 
	.print("Received signal: Robot2 moving to (",X,",",Y,")");
	driverMove("robot2",X,Y)[artifact_name(floorMap)].

+rotating(ThingArtifactName,D) : true <- 
	.print("Received signal: ",ThingArtifactName," rotating ", D, " degrees");
	.wait(3000);
	robotArmRotate(ThingArtifactName,D)[artifact_name(floorMap)].

+grasping(ThingArtifactName) : true <- 
	.print("Received signal: ",ThingArtifactName," grasping");
	.wait(3000);
	robotArmGrasp(ThingArtifactName)[artifact_name(floorMap)].

+releasing(ThingArtifactName) : true <- 
	.print("Received signal: ",ThingArtifactName, " releasing");
	.wait(3000);
	robotArmRelease(ThingArtifactName)[artifact_name(floorMap)].


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
