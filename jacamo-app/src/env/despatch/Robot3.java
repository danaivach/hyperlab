package despatch;

import cartago.*;

public class Robot3 extends Artifact {
	void init(Object coordinates) {
		defineObsProperty("location", coordinates);
	}

	@OPERATION
	void pickAndPlace(Object[] source, Object[] destination){
		signal("pickedAndPlaced",source, destination);
	}

}
