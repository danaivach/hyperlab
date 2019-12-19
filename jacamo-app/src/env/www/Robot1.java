package www;

import java.util.*;
import java.lang.Math;
import cartago.*;

public class Robot1 extends Artifact {

	final int range = 50;
	int location[] = {250,300};
	
	
	void init() {
		defineObsProperty("location","Robot1",location[0],location[1]);
		defineObsProperty("range","Robot1",range);
	}
	
	@OPERATION
	void rotateTowards(int x, int y){
		signal("rotating",180);
	}

	@OPERATION
	void grasp(){
		signal("grasping");
	}

	@OPERATION
	void release(){
		signal("releasing");
	}		

}
