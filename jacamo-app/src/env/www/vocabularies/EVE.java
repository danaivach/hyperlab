package www.vocabularies;

import org.apache.commons.rdf.api.IRI;
import org.apache.commons.rdf.api.RDF;
import org.apache.commons.rdf.rdf4j.RDF4J;

public class EVE {

  private static final String PREFIX = "http://w3id.org/eve#";
  private static RDF rdfImpl = new RDF4J();
  
  public static IRI createIRI(String fragment) {
    return rdfImpl.createIRI(PREFIX + fragment);
  }
  
  public static final IRI Environment   = createIRI("Environment");
  public static final IRI Workspace     = createIRI("Workspace");
  public static final IRI Artifact      = createIRI("Artifact");
  public static final IRI Manual        = createIRI("Manual");

  public static final IRI contains              = createIRI("contains");
  public static final IRI hasName               = createIRI("hasName");
  public static final IRI hasCartagoArtifact    = createIRI("hasCartagoArtifact");
  public static final IRI hasInitParam          = createIRI("hasInitParam");
  public static final IRI hasManual             = createIRI("hasManual");
  public static final IRI hasUsageProtocol      = createIRI("hasUsageProtocol");
  public static final IRI hasFunction           = createIRI("hasFunction");
  public static final IRI hasPrecondition       = createIRI("hasPrecondition");
  public static final IRI hasBody               = createIRI("hasBody");
  public static final IRI explains              = createIRI("explains");  

  public static final IRI usesWebSubHub         = createIRI("usesWebSubHub");
}
