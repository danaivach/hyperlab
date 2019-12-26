package www;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;


public class SearchEngineArtifact extends Artifact {
    
    private final int UNDEFINED = -1;
    
    String searchEngineUri;
    
	void init(String uri) {
	    this.searchEngineUri = uri;
	}
	
	@OPERATION
	void searchArtifact(String prefix, String subject, String predicate, String object, 
			OpFeedbackParam<String> subjectRes, OpFeedbackParam<String> predicateRes, OpFeedbackParam<String> objectRes) {
	    log("Searching on " + searchEngineUri);
	    HttpPost request = new HttpPost(searchEngineUri);
	    
	    // Build sparql query
	    if (subject == null || subject.equals("")) {
			subject = "?x";
		}
	    if (predicate == null || predicate.equals("")) {
			predicate = "?p";
		}
	    if (object == null || object.equals("")) {
			object = "?y";
		}
	    String spo = subject + " " + predicate + " " + object;
        String sparqlQuery = "@prefix " + prefix + " construct {" + spo + " } where {" + spo + "}";
        log(sparqlQuery);
        try {
            request.setEntity(new StringEntity(sparqlQuery));
            HttpClient client = HttpClientBuilder.create().build();
            HttpResponse response = client.execute(request);
            String resultString = EntityUtils.toString(response.getEntity());

          //  log("Response[" + response.getStatusLine().getStatusCode() + ": " + resultString);
          //  assuming only 1 artifact returned
             if (resultString.trim().length() > 0) {
           	
		resultString = resultString.replace("\n", "");
        	String[] splittedResult = resultString.split(" ");
		
                String resultObject = splittedResult[5].trim().replace("<", "").replace(">", "");
                String resultPredicate = splittedResult[4].trim().replace("<", "").replace(">", "");
                String resultSubject = splittedResult[3].substring(1).trim().replace("<", "").replace(">", "");
                objectRes.set(resultObject);
                subjectRes.set(resultPredicate);
                predicateRes.set(resultSubject);
			} else {
				failed("no result","no_result","query_returned_empty");
			}
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    	}


	
	@OPERATION
	void searchArtifactResource(String prefix, String subject, String predicate, String object, 
			OpFeedbackParam<String> subjectRes, OpFeedbackParam<String> predicateRes, OpFeedbackParam<String> objectRes) {
	    log("Searching on " + searchEngineUri);
	    HttpPost request = new HttpPost(searchEngineUri);
	    
	    // Build sparql query
	    if (subject == null || subject.equals("")) {
			subject = "?x";
		}
	    if (predicate == null || predicate.equals("")) {
			predicate = "?p";
		}
	    if (object == null || object.equals("")) {
			object = "?y";
		}
	    String spo = subject + " " + predicate + " " + object;
        String sparqlQuery = "@prefix " + prefix + " construct {" + spo + " } where {" + spo + "}";
        log(sparqlQuery);
        try {
            request.setEntity(new StringEntity(sparqlQuery));
            HttpClient client = HttpClientBuilder.create().build();
            HttpResponse response = client.execute(request);
            String resultString = EntityUtils.toString(response.getEntity());

            if (resultString.trim().length() > 0) {
      		List<String> lastTriple = getLastTriple(resultString);      
  		
		subjectRes.set(lastTriple.get(0));
		predicateRes.set(lastTriple.get(1));
		objectRes.set(lastTriple.get(2));
              } else {
		
		failed("no result","no_result","query_returned_empty");
              }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private List<String> getLastTriple(String resultString) {
	List<String> triple = new ArrayList<String>();

	resultString = resultString.replace("\n", "");
	resultString = resultString.replace("<", "");
	resultString = resultString.replace(">", "");
	resultString = resultString.replace(".", "");
        List<String> splittedResult = Arrays.asList(resultString.split(" "));
	int totalResources = splittedResult.size();

	triple.add(splittedResult.get(totalResources-3));
	triple.add(splittedResult.get(totalResources-2));
	triple.add(splittedResult.get(totalResources-1));

	return triple;	
    }
            	

    private List<String[]> removeBlankNodeTriples(List<String[]> triples){
	for (String[] triple : triples){
	    for (String resource : triple) {
		if (isBlankNode(resource)) {	
			triples.remove(triple);
			break;
		}
	    }
	}
	
	return triples;
     }
	
    
    private boolean isBlankNode(String result) {
	System.out.println(result);
	return result.contains("_:"); 
    }


}
