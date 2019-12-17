package www;

import cartago.*;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;

public class ShopFloorMap extends Artifact{
	
	final static String UIAddress = "http://localhost:5000";

	@OPERATION
	void rotate(String artifactName, int degrees){
		HttpPost request = new HttpPost(UIAddress + "/" + artifactName + "/rotate");
		try{
			String payload = "{\n" + 
				" \"degrees\": " + degrees +"\n" +
			"}";
			request.setEntity(new StringEntity(payload));
			request.addHeader("content-type", "application/json");
			HttpClient client = HttpClientBuilder.create().build();
			HttpResponse response = client.execute(request);
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	@OPERATION 
	void move(String artifactName,int x, int y){
		HttpPost request = new HttpPost(UIAddress + "/" + artifactName + "/move");
		try {
			String payload = "{\n" +
				" \"x\": " + x + ",\n" +
				" \"y\": " + y + "\n" +
			"}"; 
			request.setEntity(new StringEntity(payload));
			request.addHeader("content-type", "application/json");
			HttpClient client = HttpClientBuilder.create().build();
			HttpResponse response = client.execute(request);
			//System.out.println("Response: " + response.getStatusLine().getStatusCode());
		} catch (Exception e){
			e.printStackTrace();
		}
	}
}
