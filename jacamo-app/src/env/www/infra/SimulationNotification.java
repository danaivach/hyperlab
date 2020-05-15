package www.infra;

import cartago.AgentId;

	public class SimulationNotification {
		private AgentId agentId;	
		private String agentIdStr;
		private String objDetectionMsg;
		private String name;
		private boolean availability;
		private int paramX;
		private int paramY;
		
		public SimulationNotification(AgentId agentId, String objDetectionMsg, int paramX, int paramY){
			this.agentId = agentId;
			this.objDetectionMsg = objDetectionMsg;
			this.paramX = paramX;
			this.paramY = paramY;
		}

		public SimulationNotification(String agentIdStr, String objDetectionMsg, int paramX, int paramY){
			this.agentIdStr = agentIdStr;
			this.objDetectionMsg = objDetectionMsg;
			this.paramX = paramX;
			this.paramY = paramY;
		}

		public SimulationNotification(String agentIdStr, String objDetectionMsg, String name, boolean availability){
			this.agentIdStr = agentIdStr;
			this.objDetectionMsg = objDetectionMsg;
			this.name = name;
			this.availability = availability;
		}

		

		public AgentId getAgentId(){
			return agentId;
		}

		public String getObjDetectionMsg(){
			return objDetectionMsg;
		}

		public String getName(){
			return name;
		}

		public boolean getAvailability(){
			return availability;
		}

		public int getParamX(){
			return paramX;
		}

		public int getParamY(){
			return paramY;
		}
	}

	
