package www.infra;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import org.apache.commons.rdf.api.IRI;
import org.apache.commons.rdf.api.Triple;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;

import cartago.Artifact;
import cartago.LINK;
import cartago.OPERATION;
import cartago.OpFeedbackParam;

import www.vocabularies.EVE;
/*
 * The mapping and connection point between Yggdrasil and Cartago
 */
public class WebEnvironmentArtifact extends Artifact {
  private String environmentIRI;
  private Optional<WebEntity> environment;
  private List<String> workspaceList;

  private static final Logger LOGGER = Logger.getLogger(WebEnvironmentArtifact.class.getName());


  private Map<String,WebEntity> workspaces;

  void init(String environmentIRI) {
    this.environmentIRI = environmentIRI;
    this.environment = Optional.empty();
    this.workspaceList = new ArrayList<String>();
    this.workspaces = new Hashtable<String,WebEntity>();
  }

  @OPERATION
  void getWorkspaceIRIs(OpFeedbackParam<String[]> workspaceIRIs) {
    fetchWorkspaceList();

    if (!workspaceList.isEmpty()) {
      String[] workspaceIRIArray = new String[workspaceList.size()];
      workspaceIRIArray = workspaceList.toArray(workspaceIRIArray);

      workspaceIRIs.set(workspaceIRIArray);
    }
  }

  @OPERATION
  void getWorkspaceDetails(String workspaceIRIStr, OpFeedbackParam<String> name,
      OpFeedbackParam<String> webSubHubIRI, OpFeedbackParam<String[]> artifactIRIs) {

    fetchWorkspaceList();

    if (workspaceList.contains(workspaceIRIStr)) {
      Optional<WebEntity> workspaceOpt = WebEntity.fetchEntity(workspaceIRIStr);

      if (workspaceOpt.isPresent()) {
        WebEntity workspaceEntity = workspaceOpt.get();
        workspaces.put(workspaceIRIStr, workspaceEntity);

        if (workspaceEntity.getName().isPresent()) {
          name.set(workspaceEntity.getName().get());
        }

        if (workspaceEntity.isMutable()) {
          webSubHubIRI.set(workspaceEntity.getSubscriptionIRI().getIRIString());
        }

        List<IRI> artifactList = workspaceEntity.getMembers();

        if (!artifactList.isEmpty()) {
          String[] artifactIRIArray = artifactList.stream()
                                        .map(iri -> iri.getIRIString())
                                        .toArray(String[]::new);
          artifactIRIs.set(artifactIRIArray);
        }
      }
    }
  }

  @OPERATION
  void getWorkspaceNames(OpFeedbackParam<String[]> workspaceNames) {
    Set<String> workspaceNamesSet = new HashSet<String>();

    fetchWorkspaceList();

    for (String workspaceIRI : workspaceList) {
      Optional<WebEntity> workspaceOpt = WebEntity.fetchEntity(workspaceIRI);

      if (workspaceOpt.isPresent()) {
        WebEntity workspace = workspaceOpt.get();
        workspaces.put(workspaceIRI, workspace);

        if (workspace.getName().isPresent()) {
          workspaceNamesSet.add(workspace.getName().get());
        }
      }
    }

    workspaceNames.set(workspaceNamesSet.stream().toArray(String[]::new));
  }

  @OPERATION
  void getArtifactIRIs(String workspaceIRI, OpFeedbackParam<String[]> artifactIRIs) {
    if (workspaceList.contains(workspaceIRI)) {
      Optional<WebEntity> workspaceOpt = WebEntity.fetchEntity(workspaceIRI);

      if (workspaceOpt.isPresent()) {
        workspaces.put(workspaceIRI, workspaceOpt.get());
        List<IRI> artifactList = workspaceOpt.get().getMembers();

        if (!artifactList.isEmpty()) {
          String[] artifactIRIArray = artifactList.stream()
                                        .map(iri -> iri.getIRIString())
                                        .toArray(String[]::new);

          artifactIRIs.set(artifactIRIArray);
        }
      }
    }
  }

  @OPERATION
  void getArtifactDetails(String artifactIRIStr, OpFeedbackParam<String> name,
      OpFeedbackParam<Boolean> isThing, OpFeedbackParam<String> className,
      OpFeedbackParam<String[]> initParams, OpFeedbackParam<Boolean> hasManual, OpFeedbackParam<String> webSubHubIRI) {

    Optional<WebEntity> artifactOpt = WebEntity.fetchEntity(artifactIRIStr);
    //TODO check if entity is artifact
    if (artifactOpt.isPresent()) {
      WebEntity artifact = artifactOpt.get();

      if (artifact.getName().isPresent()) {
        name.set(artifact.getName().get());
      }


      Optional<String> artfiactClassName = artifact.getStringObject(EVE.hasCartagoArtifact);

      if (artfiactClassName.isPresent()) {
        // We have a CArtAgO artifact description
        className.set(artfiactClassName.get());

        String[] artfiactInitParams =
            artifact.getGraph().stream(artifact.getIRI(), EVE.hasInitParam, null)
                                .map(Triple::getObject)
                                .map(obj -> obj.toString())
                                .toArray(String[]::new);

        if (artfiactInitParams.length > 0) {
          initParams.set(artfiactInitParams);
        } else {
          initParams.set(new String[0]);
        }


      }

      if (artifact.hasManual()){
	hasManual.set(true);
      } else {
	hasManual.set(false);
      }

      if (artifact.isThing()) {
        isThing.set(true);
      } else {
        isThing.set(false);
      }


      if (artifact.isMutable()) {
        webSubHubIRI.set(artifact.getSubscriptionIRI().getIRIString());
      }
    }
  }


  @OPERATION
  void getManualDetails(String entityIRIStr, OpFeedbackParam<String> manualName, OpFeedbackParam<List<String>> protocolNames,OpFeedbackParam<List<List<String>>> protocolDetails ){

    Optional<WebEntity> entityOpt = WebEntity.fetchEntity(entityIRIStr);

    if (entityOpt.isPresent()) {
      WebEntity entity = entityOpt.get();

      if (entity.hasManual() || entity.isManual()) {
	manualName.set(entity.getManualName());
	System.out.println(entity.getManualName());
	protocolNames.set(entity.getUsageProtocolNames());
	protocolDetails.set(entity.getUsageProtocolDetails());
      }
    }

  }


  @LINK
  void onNotification(Notification notification) {
    String entityIRI = notification.getEntityIRI();

    if (entityIRI.equals(environmentIRI)) {
      // TODO
    } else if (workspaceList.contains(entityIRI)) {
      try {
        WebEntity cachedWorkspace = workspaces.get(entityIRI);
        Optional<WebEntity> newWorkspaceOpt = WebEntity.buildFromString(entityIRI, notification.getMessage(), null);

        if (cachedWorkspace != null && newWorkspaceOpt.isPresent()) {
          WebEntity newWorkspace = newWorkspaceOpt.get();

          List<IRI> oldArtifactList = cachedWorkspace.getMembers();
          List<IRI> newArtifactList = newWorkspaceOpt.get().getMembers();

          Optional<String> workspaceName = newWorkspace.getName();

          if (workspaceName.isPresent()) {
            signalArtifactsCreated(workspaceName.get(), oldArtifactList, newArtifactList);
            // TODO: signal deleted artifacts
            // TODO: updated cached workspace, note that the notificaiton currently does not include
            // the WebSub hub IRI
          }
        }
      } catch (IllegalArgumentException | IOException e) {
        e.printStackTrace();
      }
    }
  }

  private void signalArtifactsCreated(String workspaceName, List<IRI> oldArtifactList, List<IRI> newArtifactList) {
    newArtifactList.removeAll(oldArtifactList);

    if (!newArtifactList.isEmpty()) {
      newArtifactList.stream()
        .map(artifactIRI -> artifactIRI.getIRIString())
        .forEach(artifactIRI -> {
          signal("artifact_created", workspaceName, artifactIRI);
        });
    }
  }

  private void fetchWorkspaceList() {
    environment = WebEntity.fetchEntity(environmentIRI);

    if (environment.isPresent()) {
      workspaceList = environment.get()
                        .getMembers().stream()
                        .map(iri -> iri.getIRIString())
                        .collect(Collectors.toList());
    }
  }

  @OPERATION
  void requestArtifactRelation(String artifactIRI1, String artifactIRI2) {
	  HttpClient client = HttpClientBuilder.create().build();
	  String url = "http://localhost:8080/artifacts/updateTriples/" + artifactIRI1.split("/")[artifactIRI1.split("/").length-1];
	  HttpPut request = new HttpPut();
	  String requestJson = "\"additionalTriples\" : [{\"predicate\": \"http://example.com:monitoredWith\", \"object\" : <" + artifactIRI2 + ">}]";
      StringEntity entity = new StringEntity(requestJson, "UTF-8");
      entity.setContentType("application/json");
      request.setEntity(entity);
      HttpResponse response;
	try {
		response = client.execute(request);
	      int statusCode = response.getStatusLine().getStatusCode();
	      LOGGER.severe("Relate Response: " + statusCode);
	} catch (ClientProtocolException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
  }
}
