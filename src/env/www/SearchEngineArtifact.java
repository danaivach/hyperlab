package www;

import java.util.List;
import java.util.ArrayList;

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
	void searchArtifact(String prefix, String subject, String predicate, String object) {
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
	    String construct = " construct {" + spo + " } where {" + spo + "}";
        String sparqlQuery = prefix.length() > 0 ?  "@prefix " + prefix + construct : construct;
        log(sparqlQuery);
        try {
            request.setEntity(new StringEntity(sparqlQuery));
            HttpClient client = HttpClientBuilder.create().build();
            HttpResponse response = client.execute(request);
            String resultString = EntityUtils.toString(response.getEntity());
            //log("Response[" + response.getStatusLine().getStatusCode() + "] " + resultString);
            if (resultString.trim().length() > 0) {
            		List<String> resultList = new ArrayList<String>();
      	    		String[] resultLines = resultString.split("\n");
      	    		for (int i = 0; i < resultLines.length; i++) {
      	    			if (resultLines[i].length() < 1 || resultLines[i].contains("@prefix")) {
      	    				continue;
      	    			} 
      	    			String[] splittedLine = resultLines[i].split(" ");
      	    			String artifactUri = splittedLine[0].replace("<", "").replaceAll(">", "");
      	    			if (resultLines[i].contains("waterConsumption")) {
      	    				signal("water_artifact_found", artifactUri);
					} else if (resultLines[i].contains("energyConsumption")) {
  	    					signal("energy_artifact_found", artifactUri);
					} else if (resultLines[i].contains("OutsideWeatherArtifact")) {
	    					signal("weather_artifact_found", artifactUri);
					} else if (resultLines[i].contains("MusicPlayer")) {
						signal("music_artifact_found", artifactUri);
					}
      	    			else {
      	    				signal("artifact_found", artifactUri);
      	    			}
      			}
			} else {
				//failed("no result","no_result","query_returned_empty");
			}
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    	}
}

