package www;
import cartago.*;

public class Robot2 extends Artifact {

	@OPERATION
	void move(int x,int y){
		signal("moving",x,y);
	}

	@OPERATION
	void mount(){
		signal("mounting");
		signal("mounted");
	}

	@OPERATION
	void release(){
		signal("releasing");
	}

}
