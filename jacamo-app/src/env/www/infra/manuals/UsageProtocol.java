package www.infra.manuals;

public class UsageProtocol {
	
	protected String name;
	protected String function;
	protected String preconditions;
	protected String body;

	public UsageProtocol(String name, String function, String preconditions, String body) {
		this.name = name;
		this.function = function;
		this.preconditions = preconditions;
		this.body = body;
	}

	public String getName(){
		return name;
	}

	public String getFunction(){
		return function;
	}

	public String getPreconditions(){
		return preconditions;
	}

	public String getBody(){
		return body;
	}

}
