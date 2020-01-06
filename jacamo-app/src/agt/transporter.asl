/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

search_engine_URI("http://localhost:9090/searchEngine").
crawler_URI("http://localhost:9090/crawler").
crawl_env_resources("{'link': 'http://w3id.org/eve#contains'}").
crawl_explains("{'link': 'http://w3id.org/eve#explains'}").


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
	not .empty(P).


/*Initial goals */

!start.

/* General Plans */

/* Move item from its position to a destination */

+!start : environment_IRI(EnvIRI) <-
	logMessage("Transporter1","Hello WWWorld. This is Transporter1.0! Let's see if I can help in the environment:",EnvIRI);
	.wait(1000);
	.send(node_manager, achieve, environment_loaded(EnvIRI));
	logMessage("Transporter1","Loading environment...");
	!setUpSearchEngine.


+environment_loaded(EnvIRI, WorkspacesNames) : true <-
	logMessage("Transporter1","Environment loaded:", EnvIRI);
	logMessage("------------------------------------------------------------------");
	logMessage("Transporter1","Place the item by clicking on a location on the map and I will transfer it back to (600,400)").

+destination(X,Y) : true <- logMessage("Transporter1","Destination set to (",X,",",Y,")").

+item_position(X1,Y1): destination(X2,Y2) &
	X1=X2 & Y1=Y2 <-
	logMessage("Env", "Item reached its destination! You can place the item again by clicking on a location on the map.").


+item_position(X1,Y1): destination(X2,Y2) <-
	.print("Item in location (",X1,",",Y1,")");
	logMessage("Env","Item placed at position (",X1,",",Y1,")");
	!deliver(X1,Y1,X2,Y2).


+location(ArtifactName,Xr,Yr) : true <-
	.print(ArtifactName, " has property location at (", Xr,",", Yr,")").


+range(ArtifactName,R) :true <-
	.print(ArtifactName, " has property range ",R).

/*
+!push(X1,Y1,X2,Y2) : true <-
	move(X1,Y1);
	attach;
	move(X2,Y2);
	release.

*/
+!pickAndPlace(ArtifactName, D1,D2) :  true <-
	rotate(D1)[artifact_name(ArtifactName)];
	grasp[artifact_name(ArtifactName)];
	rotate(D2)[artifact_name(ArtifactName)];
	release[artifact_name(ArtifactName)].

/*
+!pickAndPlace(D1,D2): true <-
	.print("Plan: Deliver with Thing artifact ","Robot3");
	//TODO: These will be events from the Thing Artifact
	-+rotating("Robot3",D1);
	-+grasping("Robot3");
	-+rotating("Robot3",D2);
	-+releasing("Robot3").
	//act("http://example.com/Base",[["http://example.com/Value", 512]])[artifact_name(ThingArtifact)].
*/

+!deliver(X1,Y1,X2,Y2) : thing_artifact_available(_,ThingArtifactName,WorkspaceName) &
	hasAction(_,"http://example.com/Base")[artifact_name(_,ThingArtifactName)] &
	hasAction(_,"http://example.com/Gripper")[artifact_name(_,ThingArtifactName)] &
	in_range(ThingArtifactName,X1,Y1) &
	in_range(ThingArtifactName,X2,Y2) <-
	logMessage("Transporter1","I need a plan to deliver with the Thing artifact", ThingArtifactName);
	?location(ThingArtifactName,Xr,Yr);
	angularDisplacement(X1,Y1,Xr,Yr,D1);
	angularDisplacement(X2,Y2,Xr,Yr,D2);
	!ensure_plan(pickAndPlace(D1,D2),ThingArtifactName);
	logMessage("Transporter1","Ready to deliver with", ThingArtifactName);
	!pickAndPlace(D1,D2);
	-+item_position(X2,Y2).


+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot1",R1Name,_) &
	artifact_available("www.Robot2",R2Name,_) &
	thing_artifact_available(_,R3Name,_) &
	in_range(R1Name,X1,Y1)  &
	in_range(R3Name,X2,Y2)   <-
	logMessage("Transporter1","I will need plans for artifacts ",R1Name,", ",R2Name, " and the driver artifact ",R2Name);
	!ensure_plan("pickAndPlace(ArtifactName,D1,D2)",R1Name);
	!ensure_plan("drive(X1,Y1,X2,Y2)",R2Name);
	?location(R1Name,Xr1,Yr1);
	?location(R3Name,Xr3,Yr3);
	?range(R1Name,R1);
	?range(R3Name,R3);
	angularDisplacement(X1,Y1,Xr1,Yr1,D1);
	angularDisplacement(X2,Y2,Xr1,Yr1,D2);
	lineCircleCloseIntersection(X2,Y2,Xr1,Yr1,R1,Xi1,Yi1);
	lineCircleCloseIntersection(Xi1,Yi1,Xr3,Yr3,R3,Xi3,Yi3);
	logMessage("Transporter1","Ready to deliver with artifact ", R1Name);
	!pickAndPlace(R1Name,D1,D2);
	logMessage("Transporter1","Ready to deliver with artifact ", R2Name);
	!drive(Xi1,Yi1,Xi3,Yi3);
	-+item_position(Xi3,Yi3).


+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot2",R2Name,WorkspaceName)&
	thing_artifact_available(_,R3Name,_)
 <-	logMessage("Transporter1","I will need a plan to push the item with the driver artifact ",R2Name);
	?location(R3Name,Xr3,Yr3);
	?range(R3Name,R3);
	.print("range ",R3);
	!ensure_plan("push(X1,Y1,X2,Y2)",R2Name);
	logMessage("Transporter1","Ready to deliver with artifact ", R2Name);
	lineCircleCloseIntersection(X1,Y1,Xr3,Yr3,R3,Xi3,Yi3);
	!push(X1-5,Y1-10,500,380);
	-+item_position(500,400).


+!ensure_plan(Goal,ArtifactName) :.term2string(G,Goal) & .print(G) & in_library({+!G}) <-
	logMessage("Transporter1","Plan library contains an available plan for goal: ", Goal).


+!ensure_plan(Goal,ArtifactName) : artifact_available("www.infra.ManualRepoArtifact",_,_) <-
	logMessage("Transporter1","No plan in the library for goal: ", Goal);
	logMessage("Transporter1","Let's find and consult the Manual of ", ArtifactName);
	!findAndConsultManual(Goal,ArtifactName).


+!findAndConsultManual(Goal,ArtifactName) :  artifact_available(ArtifactClass,ArtifactName,_) &
	hasUsageProtocol(Goal,_,Content,ArtifactClass) <-
	logMessage("Transporter1", "Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of class ", ArtifactName);
	.add_plan(Content);
	logMessage("Transporter1","A new plan is added in the plan library").


+!findAndConsultManual(Goal,ArtifactName) : thing_artifact_available(_,ArtifactName,_) &
	hasUsageProtocol(Goal,_,Content,ArtifactName) <-
	logMessage("Transporter1","Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of Thing Artfact ", ArtifactName);
	.add_plan(Content);
	logMessage("Transporter1","A new plan is added in the plan library").


+!findAndConsultManual(Goal,ArtifactName) : search_engine_available <-
	logMessage("Transporter1","No Manual or usage protocol was found for artifact", ArtifactName, "and goal:", Goal, "in the Manual repository");
	logMessage("Transporter1","Let's use a search engine to discover Manuals for artifact", ArtifactName);
	?thing_artifact_available(ArtifactIRI, ArtifactName , _);
	.concat("<",ArtifactIRI,">",ArtifactIRIAcute);
	searchArtifactResource("eve: <http://w3id.org/eve#>","","eve:explains", ArtifactIRIAcute, SubjectResult, PredicateResult, ObjectResult)[SE];
	logMessage("Transporter1","I discovered a Manual:", SubjectResult, "that explains" , ObjectResult);
	.send(node_manager, achieve, generateArtifactManual(SubjectResult, ArtifactName, true));
	.wait(3000);
	?hasUsageProtocol(_,"true",Content,ArtifactName);
	logMessage("Transporter1","Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of Artifact ", ArtifactName);
	.add_plan(Content);
	.print("A new plan is added in the plan library: ").

-!findAndConsultManual(Goal,ArtifactName) : true <-
	logMessage("Transporter1", "No plan found in the environment for goal:", Goal);
	!askAgent(Goal).
	

+!askAgent(Goal) : true <-
	logMessage("Transporter1","Hi Transporter 2.0! Do you have any plans for the goal: ", Goal,"?");
	.concat("+!",Goal,AchievementGoal);
	.send(transporter2,askHow,AchievementGoal);
	logMessage("Transporter2","There is a plan for you for goal: ", Goal).
	
-!ensurePlan(Goal,Artifact) : artifact_available("www.infra.ManualRepoArtifact",_,_) <-
	logMessage("Transporter1","I looked at my plan library, search for artifact manuals and asked other agents. No plan was found for delivering the item. Hopefully, a new artifact or manual will be added in the environment. Please try again!"). 

+!setUpSearchEngine : search_engine_URI(SearchEngineURI) &
	crawler_URI(CrawlerURI) <-
	makeArtifact("se", "www.SearchEngineArtifact", [SearchEngineURI], SE);
	makeArtifact("ce", "www.CrawlerEngineArtifact", [CrawlerURI] , CE);
	?environment_IRI(EnvIRI);
	addSeed(EnvIRI)[CE];
	?crawl_env_resources(ContainsLink);
	registerLink(ContainsLink)[CE];
	?crawl_explains(ExplainsLink);
	registerLink(ExplainsLink)[CE];
	+search_engine_available.


+artifact_available("www.Robot1",ArtifactName,WorkspaceName) : true <-
	logMessage("Transporter1","An artifact is available:", ArtifactName, "in workspace: ", WorkspaceName);
	joinWorkspace(WorkspaceName,WorkspaceArtId);
	focusWhenAvailable(ArtifactName);
	?location(X,Y);
	?range(R);
	+location(ArtifactName,X,Y);
	+range(ArtifactName,R).

+artifact_available(_,ArtifactName,WorkspaceName) : true <-
	logMessage("Transporter1","An artifact is available:", ArtifactName, "in workspace: ", WorkspaceName);
	joinWorkspace(WorkspaceName,WorkspaceArtId);
	focusWhenAvailable(ArtifactName).


+thing_artifact_available(ArtifactIRI, ArtifactName, WorkspaceName) : true <-
  	logMessage("Transporter1","A thing artifact is available:" , ArtifactIRI, "in workspace:", WorkspaceName);
  	joinWorkspace(WorkspaceName, WorkspaceArtId);
	focusWhenAvailable(ArtifactName);
	+location(ArtifactName,550,400);
	+range(ArtifactName,50).


+hasAction(_,_): true <- .print("Action detected").

//Plans for using the GUI artifact: ShopFloorMap
+rotating(D) : true <-
	.print("Received signal: Robot1 rotating ", D, " degrees");
	robotArmRotate("robot1",D)[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot1 rotating",D,"degrees").

+grasping : true <-
	.print("Received signal: Robot1 grasping");
	robotArmGrasp("robot1")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot1 grasping").

+releasing : true <-
	.print("Received signal: Robot1 releasing");
	robotArmRelease("robot1")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot1 releasing").
	

+loading : true <-
	.print("Received signal: Robot2 loading");
	driverLoad("robot2")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot2 loading").

+unloading : true <- .print("Received signal: Robot2 unloading");
	driverRelease("robot2")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot2 unloading").

+attaching : true <- .print("Received signal: Robot2 attaching");
	driverAttach("robot2")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot2 attaching").

+detaching : true <- .print("Received signal: Robot2 detatching");
	driverRelease("robot2")[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot2 releasing").

+moving(X,Y) : true <-
	.print("Received signal: Robot2 moving to (",X,",",Y,")");
	driverMove("robot2",X,Y)[artifact_name(floorMap)];
	logMessage("Transporter1", "Robot2 moving to ( ",X,",",Y," )").

+rotating(ThingArtifactName,D) : true <-
	.print("Received signal: ",ThingArtifactName," rotating ", D, " degrees");
	.wait(3000);
	robotArmRotate(ThingArtifactName,D)[artifact_name(floorMap)];
	logMessage("Transporter1",ThingArtifactName,"rotating",D,"degrees").

+grasping(ThingArtifactName) : true <-
	.print("Received signal: ",ThingArtifactName," grasping");
	.wait(3000);
	robotArmGrasp(ThingArtifactName)[artifact_name(floorMap)];
	logMessage("Transporter1",ThingArtifactName,"grasping").

+releasing(ThingArtifactName) : true <-
	.print("Received signal: ",ThingArtifactName, " releasing");
	.wait(3000);
	robotArmRelease(ThingArtifactName)[artifact_name(floorMap)];
	logMessage("Transporter1",ThingArtifactName,"releasing").



{ include("$jacamoJar/templates/common-cartago.asl")}
{ include("$jacamoJar/templates/common-moise.asl")}
