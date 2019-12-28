
package www;

import cartago.*;
import java.lang.Math;

public class SpatialCalculator extends Artifact {


	//computes the degrees of clock-wise rotation for transfering an axis from the line L{R(xr,yr),P1(0,y)} to the line L{R(xr,yr) and P2(x,y)}
	@OPERATION
	void angularDisplacement(int x, int y, int xr, int yr, OpFeedbackParam<Integer> degrees){
		double distance = distance(x,y,xr,yr);
		double rad = Math.atan2((y-yr),(x-xr));
		double deg = rad * (180.0 / Math.PI);
		deg = (deg >= 0.0 ? deg : 360.0 + deg);
		degrees.set((int) deg);
				
	}
	
	//computes the point I(xi,yi) on the circle R(xr,yr),r that is closest to the point P(x,y)
	@OPERATION
	void lineCircleCloseIntersection(int x, int y, int xr, int yr, int r, OpFeedbackParam<Integer> xi, OpFeedbackParam<Integer> yi){
		//line coefficients
		double m = (y-yr)/(x-xr);
		double d = y - m*x;
		//discriminant
		double dis = r*r*(m*m + 1) - Math.pow((yr - m*xr - d),2);
		//intersection points
		double xI1 = (xr + yr*m - d*m + Math.sqrt(dis))/(m*m + 1);
		double xI2 = (xr + yr*m - d*m - Math.sqrt(dis))/(m*m + 1);
		double yI1 = m*xI1 + d;
		double yI2 = m*xI2 + d;
		//closest intersection point
		if (distance(x,y,xI1,yI1) <= distance(x,y,xI2,yI2)) {
			xi.set((int) xI1);
			yi.set((int) yI1);
		}
		else {
			xi.set((int) xI2);
			yi.set((int) yI2);
		}
	}

	
	double distance(double x1, double y1, double x2, double y2) {
		return Math.sqrt(Math.pow(x1-x2,2) + Math.pow(y1-y2,2));
	}

}
