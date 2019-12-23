package infra;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.Manual;
import cartago.OpFeedbackParam;

public class ManualRepoArtifact extends Artifact {
	
//	private HashMap<String,Manual> manuals;
	
	void init(){
		//this.manuals = new HashMap<String,Manual>();
	}

	@OPERATION
	void registerManual(String artifactClassName, String manualName, String usageProtocolName, String function, String precond, String body){
		
		String cartagoUsageProtFunc = ":function " + function + " " ;
		String cartagoUsageProtPrec = ":precond " + precond + " " ;
		String cartagoUsageProtBody = ":body { " + body + " } " ;
		String cartagoUsageProt = " usageprot " + usageProtocolName + " { " + cartagoUsageProtFunc 
							 			  + cartagoUsageProtPrec 
							 			  + cartagoUsageProtBody
						                          + " } " ;
	        String cartagoManualInput = " manual " + manualName + " { " + cartagoUsageProt + " } " ;
		try{
			Manual man = Manual.parse(cartagoManualInput);
			System.out.println("Look what I found in the man repo : " + man.getUsageProtocols().get(0).getBody());
		} catch (Exception e) { System.out.println(e); }
	} 

}
