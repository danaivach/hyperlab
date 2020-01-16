package www.infra;

import java.io.IOException;
import java.io.StringReader;
import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.apache.commons.rdf.api.Graph;
import org.apache.commons.rdf.api.IRI;
import org.apache.commons.rdf.api.Literal;
import org.apache.commons.rdf.api.RDF;
import org.apache.commons.rdf.api.RDFTerm;
import org.apache.commons.rdf.api.RDFSyntax;
import org.apache.commons.rdf.api.Triple;
import org.apache.commons.rdf.api.BlankNodeOrIRI;
import org.apache.commons.rdf.rdf4j.RDF4J;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.impl.LinkedHashModel;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFHandlerException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.RDFParser;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.rio.helpers.StatementCollector;

import www.vocabularies.EVE;
import www.vocabularies.TD;

import www.infra.manual.Manual;
import www.infra.manual.UsageProtocol;

/*
 * Represents an Entity (e.g. a Thing or a Manual) stored in Yggdrasil
 */
public class WebEntity {
  private IRI entityIRI;
  private Graph entityGraph;
  private Optional<IRI> subscriptionIRI;

  private static final Logger LOGGER = Logger.getLogger(WebEntity.class.getName());

  public WebEntity(IRI entityIRI, Graph entityGraph, Optional<IRI> webSubHubIRI) {
    this.entityIRI = entityIRI;
    this.entityGraph = entityGraph;
    this.subscriptionIRI = webSubHubIRI;
  }

  public IRI getIRI() {
    return entityIRI;
  }

  public Graph getGraph() {
    return entityGraph;
  }

  public IRI getSubscriptionIRI() {
    return subscriptionIRI.get();
  }

  public boolean isMutable() {
    return subscriptionIRI.isPresent();
  }

  public boolean isThing() {
    IRI isA = (new RDF4J()).createIRI(org.eclipse.rdf4j.model.vocabulary.RDF.TYPE.stringValue());
    return entityGraph.stream(entityIRI, isA, TD.Thing).findAny().isPresent();
  }


  public boolean isManual() {
    IRI isA = (new RDF4J()).createIRI(org.eclipse.rdf4j.model.vocabulary.RDF.TYPE.stringValue());
    return entityGraph.stream(entityIRI, isA, EVE.Manual).findAny().isPresent();
  }

  public boolean hasManual() {
     Optional<BlankNodeOrIRI> eveManualNode = getBlankNodeOrIRIObject(entityIRI, EVE.hasManual);
     //the manual is only valid if it has a cartago-compiant name
     if (eveManualNode.isPresent()){

    	 Optional<Literal> eveManualName = getFirstObjectAsLiteral(entityGraph, eveManualNode.get(), EVE.hasName);
    	 return  eveManualName.isPresent();
     }
     else {
	return false;
     }
  }

  public Optional<String> getName() {
    Optional<String> eveName = getStringObject(entityIRI, EVE.hasName);

    if (eveName.isPresent()) {
      return eveName;
    }

    return getStringObject(entityIRI, TD.name);
  }


  public List<IRI> getMembers() {
    return entityGraph.stream(entityIRI, EVE.contains, null)
                        .map(Triple::getObject)
                        .filter(obj -> obj instanceof IRI)
                        .map(obj -> (IRI) obj)
                        .collect(Collectors.toList());
  }

  public Optional<IRI> getIRIObject(IRI subject, IRI predicate) {
    return entityGraph.stream(subject, predicate, null)
                        .map(Triple::getObject)
                        .filter(obj -> obj instanceof IRI)
                        .map(obj -> (IRI) obj)
                        .findFirst();
  }

  public Optional<BlankNodeOrIRI> getBlankNodeOrIRIObject(IRI subject, IRI predicate) {
    return entityGraph.stream(subject, predicate, null)
                        .map(Triple::getObject)
                        .filter(obj -> obj instanceof BlankNodeOrIRI)
                        .map(obj -> (BlankNodeOrIRI) obj)
                        .findFirst();
  }

  public Optional<IRI> getIRIObject(IRI predicate) {
    return getIRIObject(entityIRI, predicate);
  }

  public Optional<BlankNodeOrIRI> getBlankNodeOrIRIObject(IRI predicate){
	return getBlankNodeOrIRIObject(entityIRI,predicate);
  }

  public Optional<String> getStringObject(IRI subject, IRI predicate) {
    return entityGraph.stream(subject, predicate, null)
                        .findAny().map(Triple::getObject)
                        .filter(obj -> obj instanceof Literal)
                        .map(literalName -> ((Literal)literalName).getLexicalForm());
  }

  public Optional<String> getStringObject(IRI predicate) {
    return getStringObject(entityIRI, predicate);
  }

  public static Optional<WebEntity> buildFromString(String entityIRI, String entityGraph, String hubIRI) throws IllegalArgumentException, IOException {
      RDF rdf4j = new RDF4J();

      IRI iri = rdf4j.createIRI(entityIRI);
      Graph graph = stringToGraph(entityGraph, entityIRI, RDFSyntax.TURTLE);
      Optional<IRI> hub = (hubIRI == null) ? Optional.empty() : Optional.of(rdf4j.createIRI(hubIRI));

      return Optional.of(new WebEntity(iri, graph, hub));
  }

  public static Optional<WebEntity> fetchEntity(String entityIRI) {
    RDF rdfImpl = new RDF4J();

    try {
      HttpClient client = HttpClientBuilder.create().build();
      HttpResponse response = client.execute(new HttpGet(entityIRI));
      int statusCode = response.getStatusLine().getStatusCode();

      if (statusCode == HttpStatus.SC_OK) {
        String payload = EntityUtils.toString(response.getEntity());

        if (payload != null && !payload.isEmpty()) {
          Graph graph = stringToGraph(payload, entityIRI, RDFSyntax.TURTLE);
          Optional<IRI> webSubHubIRI = Optional.empty();
          Header[] linkHeaders = response.getHeaders("Link");

          for (Header h : linkHeaders) {
            if (h.getValue().endsWith("rel=\"hub\"")) {
              String hubIRIStr = h.getValue().substring(1, h.getValue().indexOf('>'));
              webSubHubIRI = Optional.of(rdfImpl.createIRI(hubIRIStr));
            }
          }

          return Optional.of(new WebEntity((new RDF4J()).createIRI(entityIRI), graph, webSubHubIRI));
        }
      } else {
        LOGGER.severe("Retrieving entity failed (status code " + statusCode + "): " + entityIRI);
      }
    }
    catch (ClientProtocolException e) {
      LOGGER.severe(e.getMessage());
    }
    catch (IOException e) {
      LOGGER.severe(e.getMessage());
    }

    return Optional.empty();
  }

  private static Graph stringToGraph(String graphString, String baseIRI, RDFSyntax syntax) throws IllegalArgumentException, IOException {
    StringReader stringReader = new StringReader(graphString);

    // TODO: don't hardcode the RDF format
    RDFParser rdfParser = Rio.createParser(RDFFormat.TURTLE);
    Model model = new LinkedHashModel();
    rdfParser.setRDFHandler(new StatementCollector(model));

    try {
      rdfParser.parse(stringReader, baseIRI);
    }
    catch (RDFParseException e) {
      throw new IllegalArgumentException("RDF parse error: " + e.getMessage());
    }
    catch (RDFHandlerException e) {
      throw new IOException("RDF handler exception: " + e.getMessage());
    }
    finally {
      stringReader.close();
    }

    return (new RDF4J()).asGraph(model);
  }


  private static Optional<Manual> parseManualForArtifact(Graph graph, IRI entityIRI) {


	Optional<BlankNodeOrIRI> optManualNode = graph.stream(entityIRI, EVE.hasManual, null)
                        .map(Triple::getObject)
                        .filter(obj -> obj instanceof BlankNodeOrIRI)
                        .map(obj -> (BlankNodeOrIRI) obj)
                        .findFirst();

	BlankNodeOrIRI manualNode = optManualNode.get();

	Optional<Literal> name = getFirstObjectAsLiteral(graph, manualNode, EVE.hasName);

	Optional<String> manualName = (name.isPresent()) ? Optional.of(name.get().getLexicalForm()) : Optional.empty();

	List<UsageProtocol> usageProtocols = getUsageProtocolsForManual(graph, manualNode);

	return Optional.of(new Manual(manualName.get(), usageProtocols));

  }


  private static Optional<Manual> parseManual(Graph graph, IRI entityIRI) {


	BlankNodeOrIRI manualNode = (BlankNodeOrIRI) entityIRI;

	Optional<Literal> name = getFirstObjectAsLiteral(graph, manualNode, EVE.hasName);

	Optional<String> manualName = (name.isPresent()) ? Optional.of(name.get().getLexicalForm()) : Optional.empty();

	List<UsageProtocol> usageProtocols = getUsageProtocolsForManual(graph, manualNode);

	return Optional.of(new Manual(manualName.get(), usageProtocols));

  }

  private static List<UsageProtocol> getUsageProtocolsForManual(Graph graph, BlankNodeOrIRI manualIRI){
	List<UsageProtocol> usageProtocols = new ArrayList<UsageProtocol>();

        List<BlankNodeOrIRI> usageProtocolNodes = graph.stream(manualIRI,EVE.hasUsageProtocol,null)
					.filter(triple -> triple.getObject() instanceof BlankNodeOrIRI)
					.map(triple -> (BlankNodeOrIRI) triple.getObject())
					.collect(Collectors.toList());

	usageProtocolNodes.forEach(protNode -> {
		UsageProtocol usageProtocol = parseUsageProtocol(graph, protNode);
		if (usageProtocol != null){
			usageProtocols.add(usageProtocol);
		}
	});

	return usageProtocols;
  }

  private static UsageProtocol parseUsageProtocol(Graph graph , BlankNodeOrIRI protNode) {
	Optional<Literal> nameLit = getFirstObjectAsLiteral(graph,protNode,EVE.hasName);
	Optional<String> name = (nameLit.isPresent()) ? Optional.of(nameLit.get().getLexicalForm()) : Optional.empty();

	Optional<Literal> functionLit = getFirstObjectAsLiteral(graph,protNode,EVE.hasFunction);
	Optional<String> function = (functionLit.isPresent()) ? Optional.of(functionLit.get().getLexicalForm()) : Optional.empty();

	Optional<Literal> precondLit = getFirstObjectAsLiteral(graph,protNode,EVE.hasPrecondition);
	Optional<String> precond = (precondLit.isPresent()) ? Optional.of(precondLit.get().getLexicalForm()) : Optional.empty();

	Optional<Literal> bodyLit = getFirstObjectAsLiteral(graph,protNode,EVE.hasBody);
	Optional<String> body = (bodyLit.isPresent()) ? Optional.of(bodyLit.get().getLexicalForm()) : Optional.empty();

	if(!name.isPresent()){
		LOGGER.severe("Malformed usage protocol: No name found for this protocol.");
		return null;
	}
 	else if (!function.isPresent() || !precond.isPresent() || !body.isPresent()){
		LOGGER.severe("Malformed usage protocol: Malformed or missing semantics for protocol " + name);
		return null;
	}

	return new UsageProtocol(name.get(),function.get(),precond.get(),body.get());
  }


  public String getManualName(){
    try{
	Manual manual = getManual();

	return manual.getName();

    }catch(ManualUnavailableException e){
	LOGGER.severe("Getting the Manual name for this artifact failed due to unavailable Manual");}
    return null;
  }


  public Map<String,List<String>> getUsageProtocols(){
	Map<String,List<String>> usageProtocols = new HashMap<String,List<String>>();

	try {
		Manual manual = getManual();

		for (UsageProtocol protocol : manual.getUsageProtocols()){
			List<String> details = new ArrayList<String>();
			String name = protocol.getName();

			details.add(protocol.getFunction());
			details.add(protocol.getPreconditions());
			details.add(protocol.getBody());
			usageProtocols.put(name,details);
        	}

		return usageProtocols;
	} catch (ManualUnavailableException e) {
	LOGGER.severe("Getting the usage protocols for this artifact failed due to unavailable Manual");}
	return null;
}

  public List<List<String>> getUsageProtocolDetails(){
	List<List<String>> usageProtDetails = new ArrayList<List<String>>();

	try {
		Manual manual = getManual();

		for (UsageProtocol protocol : manual.getUsageProtocols()){
			List<String> details = new ArrayList<String>();
			details.add(protocol.getFunction());
			details.add(protocol.getPreconditions());
			details.add(protocol.getBody());
			usageProtDetails.add(details);
    }

		return usageProtDetails;
	} catch (ManualUnavailableException e) {
	LOGGER.severe("Getting the usage protocol details for this artifact failed due to unavailable Manual");}
	return null;
  }


  public List<String> getUsageProtocolNames(){
	List<String> usageProtNames = new ArrayList<String>();

	try {
		Manual manual = getManual();

		for (UsageProtocol protocol : manual.getUsageProtocols()){

			String name = protocol.getName();
			usageProtNames.add(name);
        	}

		return usageProtNames;
	} catch (ManualUnavailableException e) {
	LOGGER.severe("Getting the usage protocols names for this artifact failed due to unavailable Manual");}
	return null;
  }

  private Manual getManual() throws ManualUnavailableException {
     Optional<Manual> eveManual;
     if (isManual()) {
     	eveManual = parseManual(entityGraph,entityIRI);
     }
     else {
	eveManual = parseManualForArtifact(entityGraph,entityIRI);
     }
     if (eveManual.isPresent()){
	return eveManual.get();
     }
     else throw new ManualUnavailableException();
  }



  private static Optional<Literal> getFirstObjectAsLiteral(Graph graph, BlankNodeOrIRI subject, IRI propertyIRI){
	Optional<RDFTerm> term = getFirstObject(graph,subject,propertyIRI);

	if(term.isPresent() && term.get() instanceof Literal) {
		return Optional.of((Literal) term.get());
	}

	return Optional.empty();
  }

  private static Optional<RDFTerm> getFirstObject(Graph graph, BlankNodeOrIRI subject, IRI propertyIRI){

	if (!graph.contains(subject,propertyIRI, null)){
		return Optional.empty();
	}
	RDFTerm object = graph.stream(subject,propertyIRI,null).findFirst().get().getObject();
	return Optional.of(object);

  }

  class ManualUnavailableException extends Exception {
    public ManualUnavailableException(){
        super("There is no available manual for this artifact");
      }
  }

}
