// CArtAgO artifact code for project playground2.0

package despatch;

import cartago.*;

public class Robot1 extends Artifact {
	void init(int initialValue) {
		defineObsProperty("location", initialValue);
	}

	@OPERATION
	void move() {
		ObsProperty location = getObsProperty("location");
		location.updateValue(location.intValue()+1);
		signal("moved");
	}
}

