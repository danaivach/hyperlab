
package www;

import cartago.*;
import java.lang.Math;

public class SpatialCalculator extends Artifact {


	//computes the degrees of clock-wise rotation for transfering an axis from the line L{R(xr,yr),P1(0,y)} to the line L{R(xr,yr) and P2(x,y)}
	@OPERATION
	void angularDisplacement(int x, int y, int xr, int yr, OpFeedbackParam<Integer> degrees){
		double distance = Math.sqrt(Math.pow(x-xr,2) + Math.pow(y-yr,2));
		double rad = Math.atan2((y-yr),(x-xr));
		double deg = rad * (180.0 / Math.PI);
		deg = (deg > 0.0 ? deg : 360.0 + deg);
		degrees.set((int) deg);
				
	}
	
	//computes the point I(xi,yi) on the circle R(xr,yr),r that is closest to the point P(x,y)
	@OPERATION
	void lineCircleCloseIntersection(int x, int y, int xr, int yr, int r, OpFeedbackParam<Integer> xi, OpFeedbackParam<Integer> yi){
		double distance = Math.sqrt(Math.pow(x-xr,2) + Math.pow(y-yr,2));
		xi.set((int) (r*(xr-x)/distance));
		yi.set( ((yr-y)/(xr-x)) * (xi.get()-x) + y );
	}

}
