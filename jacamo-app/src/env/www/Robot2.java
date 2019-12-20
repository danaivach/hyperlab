package www;
import cartago.*;
import java.util.concurrent.TimeUnit;

public class Robot2 extends Artifact {

	@OPERATION
	void move(int x,int y){
		waitL();
		signal("moving",x,y);
	}

	@OPERATION
	void load(){
		waitL();
		signal("loading");
	}

	@OPERATION
	void unload(){
		waitL();
		signal("unloading");
	}

	private void waitL(){
		try{
			TimeUnit.SECONDS.sleep(3);
		} catch (InterruptedException e) {}
	}

}
