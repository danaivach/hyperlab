package www;

import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.GridWorldView;
import jason.environment.grid.Location;
import cartago.*;

import java.util.*;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.util.Random;
import java.util.logging.Logger;
import javax.swing.BoxLayout;
import javax.swing.JPanel;

public class ShopFloorPlan extends Artifact {

    private ShopFloorModel model;
    private ShopFloorView  view;

    public void init() {
        model = new ShopFloorModel();
        view  = new ShopFloorView(model);
        model.setView(view);
    }

    @OPERATION void move(String art, int x, int y) throws Exception{
	model.move(art,x,y);
    }
    
    private static Term robot = new Atom("robot");
    private static Term product = new Atom("product");

    
    public class ShopFloorView extends GridWorldView {
	
	public ShopFloorView(ShopFloorModel model){
		super(model,"Shop Floor Plan", 600);
		setVisible(true);
		repaint();
    	}

	@Override
	public void initComponents(int width){
		super.initComponents(width);
		JPanel args = new JPanel();
		args.setLayout(new BoxLayout(args, BoxLayout.Y_AXIS));
		
	}

	@Override
	public void draw(Graphics g, int x, int y, int object){
		switch(object){
			case ShopFloorModel.R1: drawRobot(g,x,y); break;
			case ShopFloorModel.PRODUCT: drawProduct(g,x,y); break;
		}
	}

	public void drawRobot(Graphics g, int x, int y){
		g.setColor(Color.red);
		g.fillRect(x*cellSizeW +2, y*cellSizeH, cellSizeW, cellSizeH);
	}

	public void drawProduct(Graphics g, int x, int y){
		g.setColor(Color.yellow);
		g.fillRect(x*cellSizeW + 2, y*cellSizeH, cellSizeW, cellSizeH);
	}

    }

    public class ShopFloorModel extends GridWorldModel {
	
	public static final int R1 = 16;
	public static final int R2 = 64;
	public static final int PRODUCT = 32;
	private Map<Integer,List<Integer>> robots;
	private Map<Integer,List<Integer>> products;

	public ShopFloorModel(){
		super(15,15,1);
		add(ShopFloorModel.R1, 5,3);
		robots = new HashMap<Integer,List<Integer>>();
		List<Integer> location = new ArrayList<Integer>();
		location.add(5,3);
		robots.put(ShopFloorModel.R1,location);
	}

	boolean move(String art,int x,int y){
		List<Integer> l1 = robots.get(ShopFloorModel.R1);
		if(hasObject(ShopFloorModel.R1,l1.get(0),l1.get(1))){
			remove(ShopFloorModel.R1,l1.get(0),l1.get(1));
			add(ShopFloorModel.R1,x,y);
			return true;
		}
		return false;
		
	}
   }

} 
