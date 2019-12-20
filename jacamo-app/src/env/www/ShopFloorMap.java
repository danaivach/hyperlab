package www;

import cartago.*;
import www.infra.WebsocketClientEndpoint;

import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.json.JSONObject;
import org.json.JSONException;

public class ShopFloorMap extends Artifact{

	final static String UIAddress = "http://localhost:5000";
	private WebsocketClientEndpoint ws;

	void init() {
		this.ws = new WebsocketClientEndpoint(URI.create("ws://localhost:40510"));
		// add listener
		this.ws.addMessageHandler(new WebsocketClientEndpoint.MessageHandler() {
			public void handleMessage(String message) {
				System.out.println("Websocket received: " + message);
				try {
					JSONObject jo = new JSONObject(message);
					if (jo.has("jacamo")) {
						jo = (JSONObject) jo.get("jacamo");
						if (jo.has("placeObject")) {
							jo = (JSONObject) jo.get("placeObject");
							int x = jo.getInt("x");
							int y = jo.getInt("y");
							System.out.println("received request to placeObject at x: " + String.valueOf(x) + " / y:" + String.valueOf(y));
						}
					}
				} catch(JSONException e) {
					System.out.println("JSONException: failed to parse JSON message");
				}
			}
		});

	}

	// rotates the robotArm to the position [degrees]
	@OPERATION
	void robotArmRotate(String artifactName, int degrees){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"rotate\":{\"degrees\":" + degrees + "}}}");
	}

	// attaches the ball to the robotArm (moves it to the end of the robot arm, when robotArm is rotated, the ball moves along until release is called)
	@OPERATION
	void robotArmGrasp(String artifactName){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"grasp\":true}}");
	}

	// releases the ball from the robotArm
	@OPERATION
	void robotArmRelease(String artifactName){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"grasp\":false}}");
	}

	// moves driver robot to coordinates x, y
	@OPERATION
	void driverMove(String artifactName, int x, int y){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"move\":{\"x\":" + x + ", \"y\":" + y + "}}}");
	}

	// loads ball on top of driver robot
	@OPERATION
	void driverLoad(String artifactName){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"load\":true}}");
	}

	// attaches ball in front of robot (robot now pushes it around while moving)
	@OPERATION
	void driverAttach(String artifactName){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"move\":true}}");
	}

	// releases an either loaded or attached ball
	@OPERATION
	void driverRelease(String artifactName){
		this.ws.sendMessage("{\"" + artifactName + "\":{\"release\":true}}");
	}

}
