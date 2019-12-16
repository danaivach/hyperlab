package www;

import java.util.*;
import java.lang.Math;
import cartago.*;

public class Robot1 extends Artifact {

	final int range = 50;
	int location[] = new int[]{250,300};
	
	@OPERATION
	void rotateTo(){
		signal("testing");
	}

	@OPERATION
	boolean inRange(int x, int y){
		boolean inRadius = Math.pow(x-location[0],2) + Math.pow(y-location[1],2) <= Math.pow(range,2);
		System.out.println("in radius " + inRadius);
		return true;
	}
	


}
