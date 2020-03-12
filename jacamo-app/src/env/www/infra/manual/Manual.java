package www.infra.manual;

import java.util.List;

public class Manual {

	protected String name;
	protected  List<UsageProtocol> usageProtocols;

	public Manual(String name, List<UsageProtocol> usageProtocols){
		this.name = name;
		this.usageProtocols = usageProtocols;
	}

	public String getName(){
		return name;
	}
	
	public void setName(String name){
		this.name = name;
	}

	public List<UsageProtocol> getUsageProtocols(){
		return usageProtocols;

	}

	public void setUsageProtocols(List<UsageProtocol> usageProtocols){
		this.usageProtocols = usageProtocols;
	}
} 
