package www;

import cartago.*;
import java.lang.Math;

public class SpatialCalculator extends Artifact {


	//computes the degrees of clock-wise rotation for transfering an axis from the line L{R(xr,yr),P1(0,y)} to the line L{R(xr,yr) and P2(x,y)}
	@OPERATION
	void angularDisplacement(int x, int y, int xr, int yr, OpFeedbackParam<Integer> degrees){
		double r = Math.sqrt(Math.pow(x-xr,2) + Math.pow(y-yr,2));
		System.out.println(r);
		System.out.println(Math.asin(Math.abs(y-yr)/r));
		int d = (int) Math.toDegrees(Math.asin((y-yr)/r));
		degrees.set(d > 0 ? d : d + 360);
	}

}
