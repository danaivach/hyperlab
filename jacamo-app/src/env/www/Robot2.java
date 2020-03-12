package www;
import cartago.*;
import java.util.concurrent.TimeUnit;

public class Robot2 extends Artifact {
	
	@OPERATION
	void move(int x,int y){
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

	@OPERATION
	void attach(){
		waitL();
		signal("attaching");
	}

	@OPERATION
	void detach(){
		waitL();
		signal("detaching");
	}
	
	private void waitL(){
		try{
			TimeUnit.SECONDS.sleep(2);
		} catch (InterruptedException e) {}
	}

}
