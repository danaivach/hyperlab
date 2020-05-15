package www.infra;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.io.StringReader;
import java.util.Iterator;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.ObsProperty;
import cartago.OpFeedbackParam;
import cartago.manual.parser.ArtifactManualParser;

import www.infra.manual.Manual;
import www.infra.manual.UsageProtocol;

public class ManualRepoArtifact extends Artifact {
	
	private HashMap<String,Manual> manuals;
	
	void init(){
		this.manuals = new HashMap<String,Manual>();
	}
	
	@SuppressWarnings("unchecked")
	@OPERATION
	void registerManual(String artifactId, String manualName, Object protNamesOb, Object protDetailsOb){
		//hashmap does not comply	
		List<List<String>> protDetails = (List<List<String>>) protDetailsOb;	
		List<String> protNames = (ArrayList<String>) protNamesOb;
		Iterator<String> nameIt = protNames.iterator();
		Iterator<List<String>> detIt = protDetails.iterator();
		while (nameIt.hasNext() && detIt.hasNext()){
			registerUsageProtocol(artifactId, manualName, nameIt.next(), detIt.next());
		}
		defineObsProperty("hasManual" , artifactId, manualName);
	

	}

	@OPERATION
	void registerUsageProtocol(String artifactId, String manualName, String protName, List<String> protocolDetails){
		String function = protocolDetails.get(0);
		String precond = protocolDetails.get(1);
		String body = protocolDetails.get(2);
		registerUsageProtocol(artifactId, manualName, protName, function, precond, body);
 
	}

	@OPERATION
	void registerUsageProtocol(String artifactId, String manualName, String protName, String protFunction, String protPrecond, String protBody){
		parseManualCartago(manualName, protName, protFunction, protPrecond, protBody);
		UsageProtocol prot = new UsageProtocol(protName,protFunction,protPrecond,protBody);
		if (hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			m.setName(manualName);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			protocols.add(prot);
			m.setUsageProtocols(protocols);
			manuals.put(artifactId,m);
		}
		else {	
			List<UsageProtocol> protocols = new ArrayList<UsageProtocol>();
			protocols.add(prot);
			Manual m = new Manual(manualName,protocols);
			manuals.put(artifactId,m);		
			
		}
		updateProtocolPerception(artifactId,prot);
	}


	
	public boolean hasManual(String artifactId){
		return manuals.containsKey(artifactId);
	}
	

	@OPERATION
	void removeManual(String artifactId){
		if(hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			for(UsageProtocol prot : protocols){
				removeUsageProtocol(prot,artifactId);
			}
			manuals.remove(m);
			removeObsPropertyByTemplate("hasManual" , artifactId, m.getName());
		}
	}


	@OPERATION
	void removeUsageProtocol(String function, String artifactId){
		
		if (hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			for(UsageProtocol prot : protocols){
				if(function.equals(prot.getFunction())){
					removeUsageProtocol(prot,artifactId);
				}
			} 
		}
	}

	
	
	@OPERATION
	void removeUsageProtocol(String function, String preconditions, String artifactId){
		
		if (hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			for(UsageProtocol prot : protocols){
				if(function.equals(prot.getFunction()) && preconditions.equals(prot.getPreconditions())){
					System.out.println("here is one matching protocol");
					removeUsageProtocol(prot,artifactId);					
				}
			} 
		}
	}

	
	
	@OPERATION
	void removeUsageProtocol(String function, String preconditions, String body, String artifactId){
		
		if (hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			for(UsageProtocol prot : protocols){
				if(function.equals(prot.getFunction()) && preconditions.equals(prot.getPreconditions()) && body.equals(prot.getBody())){
					removeUsageProtocol(prot,artifactId);					
				}
			} 
		}
	}


	private void removeUsageProtocol(UsageProtocol usageProtocol, String artifactId){
		if(hasManual(artifactId)){
			Manual m = manuals.get(artifactId);
			List<UsageProtocol> protocols = m.getUsageProtocols();
			protocols.remove(usageProtocol);
			m.setUsageProtocols(protocols);
			manuals.put(artifactId,m);
			System.out.println("no error but no idea if works");
			removeProtocolPerception(artifactId,usageProtocol);
		}
	}

	private void updateProtocolPerception(String artifactId, UsageProtocol prot){
		String name = prot.getName();
		String function = prot.getFunction();
		String preconditions = prot.getPreconditions();
		String body = prot.getBody();
		String jasonPlan = "+!" + function + " : " + preconditions + " <- " + body + "." ;
		defineObsProperty("hasUsageProtocol" , function , preconditions, jasonPlan, artifactId);
		
	}

	private void removeProtocolPerception(String artifactId, UsageProtocol prot){
		String name = prot.getName();
		String function = prot.getFunction();
		String preconditions = prot.getPreconditions();
		String body = prot.getBody();
		String jasonPlan = "+!" + function + " : " + preconditions + " <- " + body + "." ;
		//removeObsPropertyByTemplate("hasUsageProtocol" , function , preconditions, jasonPlan, artifactId);
		System.out.println("if you didn`t get error congrats");
		
	}	


	public static void parseManualCartago(String manualName, String usageProtocolName, String function, String preconditions, String body){
		
		String cartagoUsageProtFunc = ":function " + function + " " ;
		String cartagoUsageProtPrec = ":precond " + preconditions + " " ;
		String cartagoUsageProtBody = ":body { " + body + " } " ;
		String cartagoUsageProt = " usageprot " + usageProtocolName + " { " + cartagoUsageProtFunc 
							 			  + cartagoUsageProtPrec 
							 			  + cartagoUsageProtBody
						                          + " } " ;
	        String cartagoManualInput = " manual " + manualName + " { " + cartagoUsageProt + " } " ;
		
		try{
			ArtifactManualParser parser = new ArtifactManualParser(new StringReader(cartagoManualInput));
			parser.parse();
		} catch (Exception e) { System.out.println("Manual content incompatible with Cartago: " + e); }
	} 

}
