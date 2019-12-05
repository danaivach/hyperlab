package www;

import cartago.*;

public class Robot2 extends Artifact {
	void init(Object coordinates) {
		defineObsProperty("location", coordinates);
	}

	@OPERATION
	void initialize(String mode){
		signal("initialized", mode);
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
