package www;

import cartago.Artifact;
import cartago.AgentId;
import cartago.OPERATION;
import cartago.INTERNAL_OPERATION;

import www.infra.WebsocketClientEndpoint;
import www.infra.SimulationNotification;
import www.infra.SimulationNotificationQueue;
import www.infra.AgentRegistry;

import java.net.URI;
import java.net.URISyntaxException;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClientBuilder;
import org.json.JSONObject;
import org.json.JSONException;

import java.util.AbstractQueue;
import java.util.concurrent.ConcurrentLinkedQueue;

public class ShopFloorMap extends Artifact{

	final static String UIAddress = "http://localhost:5000";
	private WebsocketClientEndpoint ws;

	public static final int NOTIFICATION_DELAY = 10;

	void init() {
		this.ws = new WebsocketClientEndpoint(URI.create("ws://localhost:40510"));

		execInternalOp("deliverNotifications");

		// add listener
		this.ws.addMessageHandler(new WebsocketClientEndpoint.MessageHandler() {
			public void handleMessage(String message) {
				//System.out.println("Websocket received: " + message);
				try {
					JSONObject jo = new JSONObject(message);
					if (jo.has("jacamo")) {
						jo = (JSONObject) jo.get("jacamo");
						if (jo.has("placeObject")) {
							jo = (JSONObject) jo.get("placeObject");
							int x = jo.getInt("x");
							int y = jo.getInt("y");
							System.out.println("Received request to placeObject at x: " + String.valueOf(x) + " / y:" + String.valueOf(y));

							//AgentId receiverId = AgentRegistry.getInstance().get("transporter1");
							SimulationNotificationQueue.getInstance().add(new SimulationNotification("transporter1","item_position",x,y));
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
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"rotate\":{\"degrees\":" + degrees + "}}}");
	}

	// attaches the ball to the robotArm (moves it to the end of the robot arm, when robotArm is rotated, the ball moves along until release is called)
	@OPERATION
	void robotArmGrasp(String artifactName){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"grasp\":true}}");
	}

	// releases the ball from the robotArm
	@OPERATION
	void robotArmRelease(String artifactName){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"grasp\":false}}");
	}

	// moves driver robot to coordinates x, y
	@OPERATION
	void driverMove(String artifactName, int x, int y){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"move\":{\"x\":" + x + ", \"y\":" + y + "}}}");
	}

	// loads ball on top of driver robot
	@OPERATION
	void driverLoad(String artifactName){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"load\":true}}");
	}

	// attaches ball in front of robot (robot now pushes it around while moving)
	@OPERATION
	void driverAttach(String artifactName){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"attach\":true}}");
	}

	// releases an either loaded or attached ball
	@OPERATION
	void driverRelease(String artifactName){
		this.ws.sendMessage("{\"" + artifactName.toLowerCase() + "\":{\"release\":true}}");
	}

	@OPERATION
	void logMessage(String origin, Object... args){
		String message = "hello";
		origin = "";
		for (Object obj : args){
			origin += (String.valueOf(obj)) + " ";
		}
		this.ws.sendMessage("{\"terminal\": {\"origin\":\"" + origin + "\", \"message\": \"" + message + "\"}}");
	}

	@OPERATION
	void registerToWkspSimulator(String agentName){
		//cannot find symbol getOpUserId()
		/*AgentId agentId = this.getOpUserId();
		AgentRegistry.getInstance().put(agentName, agentId);*/
	}

	@INTERNAL_OPERATION
	void deliverNotifications() {
		while(ws.isRunning()) {
			SimulationNotification notif = SimulationNotificationQueue.getInstance().poll();

			if (notif != null) {
				//if (notif.getAgentId() != null) {

				//	signal(notif.getAgentId(), notif.getObjDetectionMsg(), notif.getParamX(), notif.getParamY());
					signal(notif.getObjDetectionMsg(), notif.getParamX(), notif.getParamY());
				//}
			} else {
				await_time(NOTIFICATION_DELAY);
			}
		}
	}
}
