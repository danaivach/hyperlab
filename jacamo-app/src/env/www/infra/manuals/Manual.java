package www.infra.manuals;

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

	public List<UsageProtocol> getUsageProtocols(){
		return usageProtocols;

	}
} 
