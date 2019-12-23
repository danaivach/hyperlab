package www.infra;

import java.util.AbstractQueue;
import java.util.concurrent.ConcurrentLinkedQueue;

public class SimulationNotificationQueue {

	private static SimulationNotificationQueue queue;
	private AbstractQueue<SimulationNotification> notificationQueue;

	private SimulationNotificationQueue(){
		notificationQueue = new ConcurrentLinkedQueue<SimulationNotification>();
	}

	public static synchronized SimulationNotificationQueue getInstance(){
		if (queue == null) {
			queue = new SimulationNotificationQueue();
		}

		return queue;
	}
	
	public SimulationNotification poll() {
		return notificationQueue.poll();
	}

	public boolean add(SimulationNotification notification) {
		return notificationQueue.add(notification);
	}

}
