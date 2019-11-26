
package despatch;

import java.util.*;
import cartago.*;

public class Robot1 extends Artifact {
	void init(Object coordinates) {
		defineObsProperty("location", coordinates);
	}

	@OPERATION
	void move(Object[] coordinates){
		ObsProperty location = getObsProperty("location");
		location.updateValue(coordinates);
		signal("moved", location.getValues());
	}

	@OPERATION
	void grasp(){
		signal("grasped");
	}

	@OPERATION
	void release(){
		signal("released");
	}
}

