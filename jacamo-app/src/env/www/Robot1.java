package www;

import java.util.concurrent.TimeUnit;
import java.lang.Math;
import cartago.*;

public class Robot1 extends Artifact {

	final int range = 50;
	int location[] = {250,400};
	
	
	void init() {
		defineObsProperty("location",location[0],location[1]);
		defineObsProperty("range",range);
	}
	
	@OPERATION
	void rotate(int degrees){
		waitL();
		signal("rotating", degrees);
	}

	@OPERATION
	void grasp(){
		waitL();
		signal("grasping");
	}

	@OPERATION
	void release(){
		waitL();
		signal("releasing");
	}		

	private void waitL(){
		try{
			TimeUnit.SECONDS.sleep(3);
		} catch (InterruptedException e) {}
	}

}
