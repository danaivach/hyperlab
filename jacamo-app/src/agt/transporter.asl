/* Initial beliefs and rules */

environment_IRI("http://localhost:8080/environments/shopfloor").

environment_UI(floorMap).

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
	.wait(3000);
	.send(node_manager, achieve, environment_loaded(EnvIRI));
	logMessage("Transporter1","Loading environment...").


+environment_loaded(EnvIRI, WorkspacesNames) : true <-
	logMessage("Transporter1","Environment loaded:", EnvIRI);
	logMessage("------------------------------------------------------------------");
	logMessage("Transporter1","Place the item by clicking on a location on the map and I will transfer it back to (600,400)").

+environment_UI(MapName) : true <-
	lookupArtifact(MapName,MapId);
	+ui_available(MapName,MapId).

+search_engine_URI(SearchEngineURI) : crawler_URI(CrawlerURI) <-
	makeArtifact("se", "www.SearchEngineArtifact", [SearchEngineURI], SE);
	makeArtifact("ce", "www.CrawlerEngineArtifact", [CrawlerURI] , CE);
	?environment_IRI(EnvIRI);
	addSeed(EnvIRI)[CE];
	?crawl_env_resources(ContainsLink);
	registerLink(ContainsLink)[CE];
	?crawl_explains(ExplainsLink);
	registerLink(ExplainsLink)[CE];
	+search_engine_available.


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


+!pickAndPlace(ArtifactName, D1,D2) :  true <-
	rotate(D1)[artifact_name(ArtifactName)];
	grasp[artifact_name(ArtifactName)];
	rotate(D2)[artifact_name(ArtifactName)];
	release[artifact_name(ArtifactName)].


//deliver when current position is in range of R3 and the workload can be assigned to R3
+!deliver(X1,Y1,X2,Y2) : 
	thing_artifact_available(_,ThingArtifactName,WorkspaceName) &
	in_range(ThingArtifactName,X1,Y1) &
	in_range(ThingArtifactName,X2,Y2) <-
	logMessage("Transporter1", "Available artifact:", ThingArtifactName, ". Needed plan: pickAndPlace(D1,D2).");
	?location(ThingArtifactName,Xr,Yr);
	//uncomment when not using the PhantomX robot arm
	angularDisplacement(X1,Y1,Xr,Yr,D1);  
	angularDisplacement(X2,Y2,Xr,Yr,D2);
	/* 
	//uncomment when using the PhantomX robot arm
	angularDisplacement(X1,Y1,Xr,Yr,V1);  
	angularDisplacement(X2,Y2,Xr,Yr,V2);
	angularToDigital(V1,D1);  
	angularToDigital(V2,D2);
	*/
	!ensure_plan("pickAndPlace(D1,D2)",ThingArtifactName); 
	logMessage("Transporter1","Ready to deliver with", ThingArtifactName);
	!pickAndPlace(D1,D2);
	-+item_position(X2,Y2).

	
//deliver when current position is in range of R1 and the workload can be split to the 3 robots (R1,R2 and R3)
+!deliver(X1,Y1,X2,Y2) : artifact_available("www.Robot1",R1Name,_) &
	artifact_available("www.Robot2",R2Name,_) &
	thing_artifact_available(_,R3Name,_) &
	in_range(R1Name,X1,Y1)  &
	in_range(R3Name,X2,Y2)   <-
	logMessage("Transporter1","Available artifact: ",R1Name,". Needed plan: pickAndPlace(D1,D2).");
	logMessage("Transporter1","Available artifact: ",R2Name,". Needed plan: drive(X1,Y1,X2,Y2).");
	logMessage("Transporter1","Available artifact: ",R3Name,". Needed plan: pickAndPlace(D1,D2).");
	!ensure_plan("pickAndPlace(ArtifactName,D1,D2)",R1Name);
	!ensure_plan("drive(X1,Y1,X2,Y2)",R2Name);
	!ensure_plan("pickAndPlace(ArtifactName,D1,D2)",R3Name);
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

//deliver when current position is in range of R1 and the workload can be split to the 2 robots (R1 and R2)
+!deliver(X1,Y1,X2,Y2) : 
	artifact_available("www.Robot1",R1Name,_) &
	artifact_available("www.Robot2",R2Name,_) &
	in_range(R1Name,X1,Y1) 
 <-     logMessage("Transporter1","Available artifact: ",R1Name,". Needed plan: pickAndPlace(D1,D2).");
	logMessage("Transporter1","Available artifact: ",R2Name,". Needed plan: drive(X1,Y1,X2,Y2).");
	!ensure_plan("pickAndPlace(ArtifactName,D1,D2)",R1Name);
	!ensure_plan("push(X1,Y1,X2,Y2)",R2Name);
	?location(R1Name,Xr1,Yr1);
	?range(R1Name,R1);
	angularDisplacement(X1,Y1,Xr1,Yr1,D1);
	angularDisplacement(X2,Y2,Xr1,Yr1,D2);
	lineCircleCloseIntersection(X2,Y2,Xr1,Yr1,R1,Xi1,Yi1);
	logMessage("Transporter1","Ready to deliver with artifact ", R1Name);
	!pickAndPlace(R1Name,D1,D2);
	logMessage("Transporter1","Ready to deliver with artifact ", R2Name);
	!push(Xi1,Yi1,X2,Y2);
	-+item_position(X2,Y2).


//deliver when current position is not in range of R3 and the workload can be split to 2 robots (R2 and R3)
+!deliver(X1,Y1,X2,Y2) : 
	thing_artifact_available(_,R3Name,_) &
	artifact_available("www.Robot2",R2Name,_) &
	in_range(R3Name,X2,Y2)
 <-	logMessage("Transporter1","Available artifact: ",R2Name,". Needed plan: push(X1,Y1,X2,Y2).");
	logMessage("Transporter1","Available artifact: ",R3Name,". Needed plan: pickAndPlace(D1,D2).");
	?location(R3Name,Xr3,Yr3);
	?range(R3Name,R3);
	!ensure_plan("push(X1,Y1,X2,Y2)",R2Name);
	!ensure_plan("pickAndPlace(ArtifactName,D1,D2)",R3Name);
	logMessage("Transporter1","Ready to deliver with artifact ", R2Name);
	lineCircleCloseIntersection(X1,Y1,Xr3,Yr3,R3,Xi3,Yi3);
	!push(X1,Y1,500,380);
	-+item_position(500,400).

//deliver when the workload can only be assigned to R2
+!deliver(X1,Y1,X2,Y2) : 
	artifact_available("www.Robot2",R2Name,_)
 <-	logMessage("Transporter1","Available artifact: ",R2Name,". Needed plan: push(X1,Y1,X2,Y2).");
	!ensure_plan("push(X1,Y1,X2,Y2)",R2Name);
	logMessage("Transporter1","Ready to deliver with artifact ", R2Name);
	!push(X1,Y1,X2,Y2);
	-+item_position(X2,Y2).



+!ensure_plan(Goal,ArtifactName) :.term2string(G,Goal) & .print(G) & in_library({+!G}) <-
	logMessage("Transporter1","-Plan library contains the plan for: ", ArtifactName).


+!ensure_plan(Goal,ArtifactName) : artifact_available("www.infra.ManualRepoArtifact",_,_) <-
	logMessage("Transporter1","-No plan in the library for:", ArtifactName);
	logMessage("Transporter1","--Find and consult the Manual of", ArtifactName);
	!findAndConsultManual(Goal,ArtifactName).


+!findAndConsultManual(Goal,ArtifactName) :  artifact_available(ArtifactClass,ArtifactName,_) &
	hasUsageProtocol(Goal,_,Content,ArtifactClass) <-
	logMessage("Transporter1", "--Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of class ", ArtifactName);
	.add_plan(Content);
	logMessage("Transporter1","--A new plan is added in the plan library").


+!findAndConsultManual(Goal,ArtifactName) : thing_artifact_available(_,ArtifactName,_) &
	hasUsageProtocol(Goal,_,Content,ArtifactName) <-
	logMessage("Transporter1","--Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of Thing Artifact ", ArtifactName);
	.add_plan(Content);
	logMessage("Transporter1","--A new plan is added in the plan library").


+!findAndConsultManual(Goal,ArtifactName) : search_engine_available <-
	logMessage("Transporter1","--No Manual or usage protocol was found for artifact", ArtifactName, "and goal:", Goal, "in the Manual repository");
	logMessage("Transporter1","---Let's use a search engine to discover Manuals for artifact", ArtifactName);
	?thing_artifact_available(ArtifactIRI,ArtifactName,_);
	.concat("<",ArtifactIRI,">",ArtifactIRIAcute);
	searchArtifactResource("eve: <http://w3id.org/eve#>","","eve:explains", ArtifactIRIAcute, SubjectResult, PredicateResult, ObjectResult)[SE];
	logMessage("Transporter1","---I discovered a Manual:", SubjectResult, "that explains" , ObjectResult);
	.send(node_manager, achieve, generateArtifactManual(SubjectResult, ArtifactName, true));
	.wait(3000);
	?hasUsageProtocol(Goal,"true",Content,ArtifactName);
	logMessage("Transporter1","---Found a usage protocol with an applicable plan for goal: ", Goal, " in the Manual of Artifact ", ArtifactName);
	.add_plan(Content);
	.print("A new plan is added in the plan library").

-!findAndConsultManual(Goal,ArtifactName) : true <-
	logMessage("Transporter1", "---No plan found in the environment for goal:", Goal);
	!askAgent(Goal).


+!askAgent(Goal) : true <-
	logMessage("Transporter1","----Hi Transporter 2.0! Do you have any plans for the goal: ", Goal,"?");
	.wait(3000);
	.concat("+!",Goal,AchievementGoal);
	.send(transporter2,askHow,AchievementGoal);
	logMessage("Transporter2","----There is a plan for you for goal: ", Goal).

-!ensurePlan(Goal,Artifact) : artifact_available("www.infra.ManualRepoArtifact",_,_) <-
	logMessage("Transporter1","----I looked at my plan library, search for artifact manuals and asked other agents. No plan was found for delivering the item. Hopefully, a new artifact or manual will be added in the environment. Please try again!").


//a new artifact is in the workspace
+artifact_enabled(ArtifactClassName,ArtifactName,WorkspaceName) : ui_available(MapName,MapID) <-
	logMessage("Transporter1","An artifact is available:", ArtifactName, "in workspace: ", WorkspaceName);
	joinWorkspace(WorkspaceName,WorkspaceArtId);
	+artifact_available(ArtifactClassName,ArtifactName,WorkspaceName);
	focusWhenAvailable(ArtifactName);
	lookupArtifact(ArtifactName,ArtID).
	//linkArtifacts(ArtID,"floorMap",MapID).

//a new thing artifact is in the workspace
+thing_artifact_enabled(ArtifactIRI, ArtifactName, WorkspaceName) : true <-
  	logMessage("Transporter1","A thing artifact is available:" ,ArtifactName, ArtifactIRI, "in workspace:", WorkspaceName);
  	joinWorkspace(WorkspaceName, WorkspaceArtId);
	+thing_artifact_available(ArtifactIRI, ArtifactName, WorkspaceName);
	focusWhenAvailable(ArtifactName);
	+location(ArtifactName,550,400);
	+range(ArtifactName,50).

//an artifact is not currently available
+change_artifact(ArtifactName,false) : artifact_available(ArtifactClassName,ArtifactName,WorkspaceName)
	& artifact_enabled(ArtifactIRI, ArtifactName, WorkspaceName) <- 
	logMessage("Transporter1","An artifact is unavailable:", ArtifactName, "in workspace: ", WorkspaceName);
	-artifact_available(ArtifactClassName,ArtifactName,WorkspaceName).

//a thing artifact is not currently available
+change_artifact(ArtifactName,false) : thing_artifact_available(ArtifactIRI,ArtifactName,WorkspaceName) 
	& thing_artifact_enabled(ArtifactIRI, ArtifactName, WorkspaceName) <- 
	logMessage("Transporter1","A thing artifact is unavailable:",ArtifactName, ArtifactIRI, "in workspace:", WorkspaceName);
	-thing_artifact_available(ArtifactIRI,ArtifactName,WorkspaceName).
	
//an artifact is currently available
+change_artifact(ArtifactName,true) : not artifact_available(ArtifactClassName,ArtifactName,WorkspaceName) 
	& artifact_enabled(ArtifactIRI, ArtifactName, WorkspaceName) <- 
	logMessage("Transporter1","An artifact is available:", ArtifactName, "in workspace: ", WorkspaceName);
	+artifact_available(ArtifactClassName,ArtifactName,WorkspaceName).

//a manual has been removed
+change_manual(ArtifactName,false) : true   <- 
	logMessage("Transporter1","A manual is unavailable:" ,ArtifactName).

//a manual is available
+change_manual(ArtifactName,true) : true <- 
	logMessage("Transporter1","A manual is available:" ,ArtifactName).

+hasAction(Ak,Aj): true <- .print("Action detected: ", Ak, " has action ", Aj).

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
