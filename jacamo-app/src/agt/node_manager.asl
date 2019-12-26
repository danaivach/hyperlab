/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	.print("Hi from node_manager!");
	makeArtifact("notification-server", "www.infra.NotificationServerArtifact", [8081], _);
	start.

 
+!environment_loaded(EnvIRI)[source(Ag)] : environment_loaded(EnvIRI) <-
	.send(Ag, tell, environment_loaded(EnvIRI)).

+!environment_loaded(EnvIRI)[source(Ag)] : true <-
	.print("Received request from ", Ag, " to load enviornment: ", EnvIRI);
	makeArtifact("envar", "www.infra.WebEnvironmentArtifact", [EnvIRI], WebEnvArtID);
	focusWhenAvailable("envar");
	+web_environment_artifact_id(WebEnvArtID);
	getWorkspaceIRIs(WorkspaceIRIs);
	.print("Available workspaces: ", WorkspaceIRIs);
	!buildWorkspaces(WorkspaceIRIs);
	.print("Done, notifying agent ", Ag, " of created workspaces!");
	getWorkspaceNames(WorkspaceNames);
	.send(Ag, tell, environment_loaded(EnvIRI, WorkspaceNames)).


+!buildWorkspaces([]) : true .

+!buildWorkspaces([WorkspaceIRI | T]) : web_environment_artifact_id(WebEnvArtID) <-
	.print("Creating workspace ", WorkspaceIRI);
	getWorkspaceDetails(WorkspaceIRI, WorkspaceName, WorkspaceWebSubHubIRI, WorkspaceArtifactIRIs);
	.print("[Workspace: ", WorkspaceIRI, "] Name: ", WorkspaceName, ", available artifacts: ", WorkspaceArtifactIRIs);
	createWorkspace(WorkspaceName);
	joinWorkspace(WorkspaceName, WorkspaceArtId);
	!createCartagoArtifact(WorkspaceName,"manualRepo","www.infra.ManualRepoArtifact",[],MR);
	focusWhenAvailable("manualRepo");
	+artifact_details(WorkspaceIRI, WorkspaceName, WorkspaceArtifactIRIs, WorkspaceArtId);
	registerArtifactForNotifications(WorkspaceIRI, WebEnvArtID, WorkspaceWebSubHubIRI);
	!buildArtifacts(WorkspaceName, WorkspaceArtifactIRIs);
	!buildWorkspaces(T).


+!buildArtifacts(WorkspaceName, []) : true .

+!buildArtifacts(WorkspaceName, [ArtifactIRI | T]) : true <-
	getArtifactDetails(ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI);
	.print("[Artifact: ", ArtifactIRI, "] Name: ", ArtifactName, ", class name: ", ArtifactClassName, ", init params: ", InitParams, ", web sub hub IRI: ", WebSubHubIRI);
	!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI);
	!buildArtifacts(WorkspaceName, T).



+artifact_created(WorkspaceName, ArtifactIRI) : true <-
	.print("New artifact created in workspace ", WorkspaceName, ": ", ArtifactIRI);
	getArtifactDetails(ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI);
	.print("[Artifact: ", ArtifactIRI, "] Name: ", ArtifactName, ", class name: ", ArtifactClassName, ", init params: ", InitParams, ", web sub hub IRI: ", WebSubHubIRI);
	!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI).
	

+!generateNewArtifact(ArtifactIRI) : true <-
	.print("Creating new artifact: ", ArtifactIRI);
	getArtifactDetails(ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI);
	!makeArtifact(main, ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI).


+!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, true, _, _, HasManual, WebSubHubIRI)
	: .ground([WorkspaceName, ArtifactIRI, ArtifactName, WebSubHubIRI])
	<-
	.print("Got a thing artifact with a WebSubIRI!");
	!createThingArtifact(WorkspaceName, ArtifactName, ArtifactIRI, ArtID);
	registerArtifactForNotifications(ArtifactIRI, ArtID, WebSubHubIRI);
	!generateArtifactManual(ArtifactIRI,ArtifactName,HasManual);
	.print("Subscribed artifact ", ArtifactName, " for notifications! ", WebSubHubIRI).


+!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, true, _, _, HasManual, WebSubHubIRI)
	: .ground([WorkspaceName, ArtifactIRI, ArtifactName])
	<-
	.print("Got a thing artifact without a WebSubIRI!");
	!createThingArtifact(WorkspaceName, ArtifactName, ArtifactIRI, ArtID);
	!generateArtifactManual(ArtifactIRI,ArtifactName,HasManual).


+!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, false, ArtifactClassName, InitParams, HasManual, WebSubHubIRI)
	: .ground([WorkspaceName, ArtifactIRI, ArtifactName, ArtifactClassName, InitParams, WebSubHubIRI])
	<-
	.print("Got an artifact with a WebSubIRI!");
	!createCartagoArtifact(WorkspaceName, ArtifactName, ArtifactClassName, InitParams, ArtID);
	registerArtifactForNotifications(ArtifactIRI, ArtID, WebSubHubIRI);
	!generateArtifactManual(ArtifactIRI,ArtifactClassName,HasManual);
	.print("Subscribed artifact ", ArtifactName, " for notifications! ", WebSubHubIRI).


+!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, false, ArtifactClassName, InitParams, HasManual, WebSubHubIRI)
	: .ground([WorkspaceName, ArtifactIRI, ArtifactName, ArtifactClassName, InitParams])
	<-
	!createCartagoArtifact(WorkspaceName, ArtifactName, ArtifactClassName, InitParams, ArtID);
	!generateArtifactManual(ArtifactIRI,ArtifactClassName,HasManual).


+!makeArtifact(WorkspaceName, ArtifactIRI, ArtifactName, IsThing, ArtifactClassName, InitParams, HasManual, WebSubHubIRI) : true <-
	.print("Discovered an artifact I cannot create: ", ArtifactIRI).

	
+!createThingArtifact(WorkspaceName, ArtifactName, ArtifactIRI, ArtID) : true <-
	makeArtifact(ArtifactName, "www.ThingArtifact", [ArtifactIRI], ArtID);
	+artifact_details(ArtifactIRI, ArtifactName, ArtID);
	.broadcast(tell, thing_artifact_available(ArtifactIRI, ArtifactName, WorkspaceName)).


+!createCartagoArtifact(WorkspaceName, ArtifactName, ArtifactClassName, InitParams, ArtID) : true <-
	.print("Creating Cartago Artifact");
	makeArtifact(ArtifactName, ArtifactClassName, InitParams, ArtID);
	+artifact_details(ArtifactIRI, ArtifactName, ArtifactClassName, ArtID);
	.broadcast(tell, artifact_available(ArtifactClassName, ArtifactName, WorkspaceName)).


+!generateArtifactManual(EntityIRI, ArtifactClassOrName, true) : true <-
	.print("Creating new manual for: ", ArtifactClassOrName);
	getManualDetails(EntityIRI, ManualName , ManualUse, UseDetails);
	!registerArtifactManual(ArtifactClassOrName, ManualName, ManualUse, UseDetails).


+!generateArtifactManual(ArtifactIRI, ArtifactClassOrName, false) : true <-
	.print("No manual found for the artifact: ", ArtifactClassOrName).


+!registerArtifactManual(ArtifactClassOrName, ManualName, ManualUse, ManualDetails) : true <-
	.print("Found a manual for the artifact ", ArtifactClassOrName , ". Available usage protocols: ", ManualName);
	registerManual(ArtifactClassOrName, ManualName, ManualUse, ManualDetails).


+!relateArtifacts(ArtIRI1, ArtIRI2) : true <-
	//requestArtifactRelation(ArtIRI1, ArtIRI2);
	.print("Relate Artifacts").

