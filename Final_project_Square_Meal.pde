import gohai.glvideo.*;
import VLCJVideo.*;
import processing.video.*;
import ddf.minim.*;

//sound parts
Minim minim;
AudioPlayer player;
PImage muteIcon,unmuteIcon;
PImage stoneblock,brickblock,back_image;
PImage beginscr,statusbar;
PImage levelSelectImage,instrucImage;
PImage settingsButton, quitButton, levelSelectScreen;
PImage[] coin = new PImage[10];
PImage[] Enemyleft = new PImage[10],Enemyright = new PImage[10],Playerleft = new PImage[10],Playerright = new PImage[10];
PImage monsterstun;
PImage monsterstun_1;
boolean isPlaying = true;
boolean isMuted = false;
int overallscore = 0;
boolean levelPassed = false;
boolean showinstru = false;
boolean pass = false;
int gridSize = 40;
boolean isGameOver = false;
int[][] board; // 0: empty, 1: block, 2: player, 3: enemy
int playerX, playerY;
int dir;
Boolean hasBlock = false;
Boolean showlevel = false;
boolean isBlockMoving = false;
float movingBlockX, movingBlockY;  // Current position of the moving block
float destBlockX, destBlockY;  // Destination position
float blockSpeed = 5;  // Speed at which block moves (adjust as needed)
int stunnedDuration = 300;
int lastExecutedTime = 0;
int passTime = -1; // -1 indicates that the level has not been passed yet
<<<<<<< HEAD
int statusbarh = 40;
=======
int anitime=0;
int statusbarh=40;
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867
int startgametime,mins;
int Enemy_num=0;
int settingsButtonX, settingsButtonY, settingsButtonWidth, settingsButtonHeight;
int quitButtonX, quitButtonY, quitButtonWidth, quitButtonHeight;

PImage startButton;
int level = 0;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
color c = color(100, 101, 120);

boolean checkAABBCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    float leftx1 ,rightx1;
    float upy1 ,downy1;
    float leftx2 ,rightx2;
    float upy2 ,downy2;
    leftx1 = x1; rightx1 = x1 + w1;
    leftx2 = x2; rightx2 = x2 + w2;
    upy1 = y1;   downy1 = y1 + h1;
    upy2 = y2;   downy2 = y2 + h2;
    
    if (rightx1 <=  leftx2 || rightx2 <=  leftx1) return false;
    if (downy1 <=  upy2 ||  upy1 >=  downy2) return false;
    return true;
}

class Enemy {
    float x, y;
    int[] direction;
    boolean isStunned,exist;
    int stunnedCounter;
    int enemex,enemey,score;
    int lastx,lasty;
    int enemySpeed = 1;
    int nextX,nextY;
    
    Enemy(float x, float y,int speed,int score) {
        this.enemySpeed = speed;
        this.x = x;
        this.y = y;
        enemex = int(x / gridSize);
        lastx = enemex;
        enemey = int(y / gridSize);
        lasty = enemey;
        this.direction = new int[]{1, 0}; // Default to moving right
        this.isStunned = false;
        this.stunnedCounter = 0;
        this.exist = true;
        this.score = score;
    }
    int getscore() {
        return this.score;
    }
    boolean checkexist() {
        return this.exist;
    }
    void move() {
        if (!isStunned) {
            this.x += this.direction[0] * enemySpeed;
            this.y += this.direction[1] * enemySpeed;
            enemex = int(this.x / gridSize);
            enemey = int(this.y / gridSize);
            if (board[lastx][lasty] ==  3)board[lastx][lasty] = 0;
            lastx = enemex;lasty = enemey;
            if (board[enemex][enemey] ==  0)board[enemex][enemey] = 3;
        }
    }
    boolean checkCollisionWithPlayer() {
        if(!this.isStunned) {
            //println("thisx,thisy"+this.x+" "+this.y+"plx,ply"+ playerX+" "+ playerY);
            return checkAABBCollision(this.x, this.y, gridSize, gridSize, playerX, playerY, gridSize, gridSize);
        }
        return false;
    } 
    void turnCounterClockwise() {
        if(millis() - lastExecutedTime < 250)return;
        lastExecutedTime = millis();
        if(this.direction[0] == 1 && this.direction[1] == 0) { // Moving right
            this.direction[0] = 0;
            this.direction[1] = -1; // Turn up
        } else if (this.direction[0] == 0 && this.direction[1] == -1) { // Moving up
            this.direction[0] = -1;
            this.direction[1] = 0; // Turn left
        } else if (this.direction[0] == -1 && this.direction[1] == 0) { // Moving left
            this.direction[0] = 0;
            this.direction[1] = 1; // Turn down
        } else if (this.direction[0] == 0 && this.direction[1] == 1) { // Moving down
            this.direction[0] = 1;
            this.direction[1] = 0; // Turn right
        }
        //this.x+=this.direction[0]*40;
        //this.y+=this.direction[1]*40;
    }
    void checkBoundary() {   //PERFECT I fix every bugs here 
        //Check for collision with game boundaries
        boolean hitBoundary = (this.x < 0 || this.x + gridSize  > width || this.y < 0 || this.y + gridSize + statusbarh   > height);
        if (this.x < 0) this.x = 0;
        if (this.x + gridSize > width) this.x = width - gridSize;
        if (this.y < 0) this.y = 0;
        if (this.y + gridSize > height - statusbarh) this.y = height - gridSize - statusbarh;
        
        //Check for collision with blocks on the board
        boolean hitBlock = false;
        for (int i = 0; i < board.length; i++) {
            for (int j = 0; j < board[0].length; j++) {
                if(board[i][j] == 1 || board[i][j] ==  5) {
                    float blockX = i * gridSize;
                    float blockY = j * gridSize;
                    if(checkAABBCollision(this.x, this.y, gridSize, gridSize, blockX, blockY, gridSize, gridSize)) {
                        hitBlock = true;
                        break;
                }
            }
        }
            if(hitBlock) {
                break;
            }
        }
        
        //If the enemy hits a boundary or a block, turn counterclockwise
        if(hitBoundary || hitBlock) {
            if (hitBlock) {
                if (direction[0] > 0) this.x -= (this.x % gridSize);
                if (direction[1] > 0) this.y -= (this.y % gridSize);
                if (direction[0] < 0) this.x += (gridSize - (this.x % gridSize));
                if (direction[1] < 0) this.y += (gridSize - (this.y % gridSize));
            } //if(direction[0]>0){this.x-=(this.x%gridSize);}else {this.x+=(this.x%gridSize);}
            //if(direction[1]>0){this.y-=(this.y%gridSize);}else {this.y+=(this.y%gridSize);}
            turnCounterClockwise();
        }
    }  
    void checkCollisionWithBlock() {
        if(isBlockMoving && checkAABBCollision(this.x, this.y, gridSize, gridSize, movingBlockX, movingBlockY, gridSize, gridSize)) {
            this.isStunned = true;
        }
    }  
    void update() {
        if (this.isStunned && this.stunnedCounter < stunnedDuration) {
            this.stunnedCounter++;
            if (this.stunnedCounter == stunnedDuration) {
                this.isStunned = false;
                this.stunnedCounter = 0;
            }
        }
    }
    void display() {
<<<<<<< HEAD
        if (this.isStunned) {
            fill(128, 0, 0); // Dark red for stunned enemy
        } else {
            fill(255, 0, 0); // Red for enemy
        }

        ellipse(this.x + 20, this.y + 20, gridSize, gridSize);
=======
        //fill(255, 0, 0); // Red for enemy
        if (this.isStunned) {
            //fill(128, 0, 0); // Dark red for stunned enemy
          if(this.direction[0]==-1)
            image(monsterstun,this.x,this.y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
          else
            image(monsterstun_1,this.x,this.y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
        }
        else if(this.direction[0]==-1)
          image(Enemyleft[Enemy_num],this.x,this.y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
        else
          image(Enemyright[Enemy_num],this.x,this.y,Enemyright[Enemy_num].width, Enemyright[Enemy_num].height);
        //ellipse(this.x+20, this.y+20, gridSize, gridSize);
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867
    }
}

int getTimestamp() {
    return (millis() % 1000);
}
<<<<<<< HEAD
=======


class Mirage extends Enemy {
    private boolean isHidden = false;
    private int hideCooldown = int(random(100,400));
    private int hideTimestamp = 0;
    private int lastHideTimestamp = 0;
    private int MAX_HIDE_DURATION = 20;
    private float HIDE_CHANCE = 4.34;
    
    //default properties
    private int enemex, enemey;
    private int lastx, lasty;
    
    Mirage(float x, float y, int speed, int score) {
        super(x, y, speed, score);
    }
    
    public void display() {
        if (this.isStunned) {
            fill(140, 84, 4); // Dark red for stunned enemy
        } else {
            fill(247, 165, 49); // Red for enemy
        }
        if(!this.isHidden)
          ellipse(this.x + 20, this.y + 20, gridSize, gridSize);
        else
          image(stoneblock,this.x,this.y,gridSize,gridSize*1.7);
    }

    private boolean checkHideStatus() {
        if (this.isHidden) {
           if (getTimestamp() > this.hideTimestamp) {
                this.isHidden = false;
                display();
                return false;
            }
            return true;
        }
        
        return false;
    }

    public void move() {
        if (checkHideStatus()) {
          unhide();
          return;
        }
        if (isStunned) {
          return;
        }
        if(!this.isHidden)
          hide();
        unhide();
        this.x += this.direction[0] * enemySpeed;
        this.y += this.direction[1] * enemySpeed;
        enemex = int(this.x / gridSize);
        enemey = int(this.y / gridSize);
        if (board[lastx][lasty] == 3) {
            board[lastx][lasty] = 0;
        }
        lastx = enemex;lasty = enemey;
        if (board[enemex][enemey] == 0) {
            board[enemex][enemey] = 3;
        }
    }

    private void hide() {
        if (this.isHidden) {
            return;
        }
        if (random(1,6) > this.HIDE_CHANCE) {
            return;
        }
        if ((getTimestamp() - this.lastHideTimestamp) < this.hideCooldown+10) {
            return;
        }
        //replace self with stone block here
        this.isHidden = true;
        this.hideTimestamp = getTimestamp();
        println("HIDE!");
    }

    private void unhide() {
        if (!isHidden||getTimestamp()-this.hideTimestamp<2) {
          println(getTimestamp()+" - "+this.hideTimestamp);
            return;
        }
        this.lastHideTimestamp = getTimestamp();
        this.isHidden = false;
        println("UNHIDE!");
        display();
        //deletes the stone block here
    }
}
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867


class Mirage extends Enemy {
    private boolean isHidden = false;
    private int hideCooldown = int(random(40));
    private int hideTimestamp = 0;
    private int lastHideTimestamp = 0;
    private int MAX_HIDE_DURATION = 20;
    private float HIDE_CHANCE = 4.34;
    
    //default properties
    private int enemex, enemey;
    private int lastx, lasty;
    
    Mirage(float x, float y, int speed, int score) {
        super(x, y, speed, score);
    }
    
    public void display() {
        if (this.isStunned) {
            fill(140, 84, 4); // Dark red for stunned enemy
        } else {
            fill(247, 165, 49); // Red for enemy
        }
        ellipse(this.x + 20, this.y + 20, gridSize, gridSize);
    }

    private boolean checkHideStatus() {
        if (this.isHidden) {
           if (getTimestamp() > this.hideTimestamp) {
                this.isHidden = false;
                display();
                return false;
            }
            return true;
        }
        
        return false;
    }

<<<<<<< HEAD
    public void move() {
        if (checkHideStatus()) {
            return;
        }
        if (isStunned) {
            return;
        }
        hide();
        this.x += this.direction[0] * enemySpeed;
        this.y += this.direction[1] * enemySpeed;
        enemex = int(this.x / gridSize);
        enemey = int(this.y / gridSize);
        if (board[lastx][lasty] == 3) {
            board[lastx][lasty] = 0;
        }
        lastx = enemex;lasty = enemey;
        if (board[enemex][enemey] == 0) {
            board[enemex][enemey] = 3;
        }
    }
=======
  // Get enemy data
  JSONArray enemiesData = levelData.getJSONArray("enemies");
  enemies.clear();
  for (int i = 0; i < enemiesData.size(); i++) {
    JSONObject enemyData = enemiesData.getJSONObject(i);
    String enemyType;
    if (enemyData.isNull("type")) {
            enemyType = "default";
    } else {
        enemyType = enemyData.getString("type");
    }

    float x = enemyData.getFloat("x");
    float y = enemyData.getFloat("y");
    int spd = enemyData.getInt("speed");
    int sco = enemyData.getInt("score");
    switch(enemyType) {
        case "default":
            enemies.add(new Enemy(x, y, spd,sco));
            break;

        case "mirage":
            enemies.add(new Mirage(x, y, spd, sco));
            break;
    }

  }
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867

    private void hide() {
        if (this.isHidden) {
            return;
        }
        if (random(10) > this.HIDE_CHANCE) {
            return;
        }
        if ((getTimestamp() - this.lastHideTimestamp) < this.hideCooldown) {
            return;
        }
        //replace self with stone block here
        this.isHidden = true;
        this.hideTimestamp = getTimestamp();
        println("HIDE!");
    }

    private void unhide() {
        if (!isHidden) {
            return;
        }
        this.lastHideTimestamp = getTimestamp();
        display();
        //deletes the stone block here
        this.isHidden = false;
        println("UNHIDE!");
    }
}

void loadlevel(int level) {
    overallscore = 0;
    if (level <=  0 ||  level > 6) {
        println("Invalid level " + level); return;
}
    JSONObject json = loadJSONObject("map.json"); // Load the JSON file
    JSONObject levelData = json.getJSONObject("level" + str(level)); // Get data for level1
    if (levelData ==  null) {
        println("Invalid level " + level); return;
}
    else{
        println("try to load level" + level);
}
    //Get the board data
    JSONArray boardData = levelData.getJSONArray("board");
    board = new int[width / gridSize][height / gridSize - 1];
    for (int i = 0; i < boardData.size(); i++) {
        JSONArray row = boardData.getJSONArray(i);
        for (int j = 0; j < row.size(); j++) {
            board[j][i] = row.getInt(j);
        }
}
    
    //Get player position
    playerX = levelData.getInt("playerX");
    playerY = levelData.getInt("playerY");
    
    //Get enemy data
    JSONArray enemiesData = levelData.getJSONArray("enemies");
    for (int i = 0; i < enemiesData.size(); i++) {
        JSONObject enemyData = enemiesData.getJSONObject(i);
        String enemyType;

        if (enemyData.isNull("type")) {
            enemyType = "default";
        } else {
            enemyType = enemyData.getString("type");
        }

        float x = enemyData.getFloat("x");
        float y = enemyData.getFloat("y");
        int spd = enemyData.getInt("speed");
        int sco = enemyData.getInt("score");
        switch(enemyType) {
            default:
            case "default":
                enemies.add(new Enemy(x, y, spd,sco));
                break;

            case "mirage":
                enemies.add(new Mirage(x, y, spd, sco));
                break;
        }
}
    
    println("loaded level successfully"); 
    startgametime = millis(); 
    mins = 0;
    
}
void setuplevel() {
    
    image(back_image, 0, 0, width, height);
    player.rewind(); 
    player.loop();
    isGameOver = false;
    if (level > 0) {
        
}
    loadlevel(level);
}

void setup() {
<<<<<<< HEAD
    oldenglish = loadFont("BerlinSansFB-Bold-48.vlw");
    instrucImage = loadImage("Instructions.png");
    instrucImage.resize(600,600);
    beginscr = loadImage("Begin_Screen.jpg");
    muteIcon = loadImage("unmute.jpg");
    stoneblock = loadImage("block2.png");
    brickblock = loadImage("block1.png");
    statusbar = loadImage("statusbar.png");
    brickblock.resize(50,78);
    unmuteIcon = loadImage("mute.jpg");
    levelSelectImage = loadImage("levelSelectImage.png"); // Replace with your level selection image file
    levelSelectImage.resize(600,500); // Adjust size as needed
    back_image = loadImage("background.jpg");
    back_image.resize(1000,840);
    textAlign(CENTER, CENTER);
    textSize(64);
    //Initialize circles with random positions and colors
    for (int i = 0; i < 3 * numCircles; i++) {
        circlePositions[i] = new PVector(random(width), random(height));
        circleSizes[i] = random(10, maxDiameter);
        circleColors[i] = color(random(255), random(255), random(255), 200);
}
    
    minim = new Minim(this);
    player = minim.loadFile("BGM.mp3");
    player.loop();
    
    //settingsButton = loadImage("settingsButton.jpg"); // Replace with your settings button image file
    quitButton = loadImage("quit.jpg"); // Replace with your quit button image file
    settingsButton = loadImage("setting.png");
    settingsButton.resize(110, 55); // Adjust size as needed
    quitButton.resize(100, 50); // Adjust size as needed
    statusbar.resize(1000,40);
    size(1000, 840);
    //startButton = loadImage("startButton.jpg"); // Load the start button image
    beginscr.resize(1000,840);
    background(beginscr);
    
    //Display the start button on the screen
    //image(startButton, width/2 - startButton.width/2, height/2 - startButton.height/2);
=======
  oldenglish = loadFont("BerlinSansFB-Bold-48.vlw");
  instrucImage = loadImage("Instructions.png");
  instrucImage.resize(600,600);
  beginscr = loadImage("Begin_Screen.jpg");
  muteIcon = loadImage("unmute.jpg");
  stoneblock = loadImage("block2.png");
  brickblock = loadImage("block1.png");
  statusbar = loadImage("statusbar.png");
  brickblock.resize(50,78);
  unmuteIcon = loadImage("mute.jpg");
  levelSelectImage = loadImage("levelSelectImage.png"); // Replace with your level selection image file
  levelSelectImage.resize(600,500); // Adjust size as needed
  back_image = loadImage("background.jpg");
  back_image.resize(1000,840);
  monsterstun = loadImage("monster_stunned.png");
  monsterstun_1 = loadImage("monster_stunned_1.png");
  monsterstun.resize(gridSize,gridSize);
  monsterstun_1.resize(gridSize,gridSize);
  for(int i=0;i<7;i++){
    String s = "monster"+str(i+1);
    String s2 = s;
    s+=".png";
    s2+="-1.png";
    Enemyleft[i] = loadImage(s);
    Enemyright[i] = loadImage(s2);
    Enemyleft[i].resize(gridSize,gridSize);
    Enemyright[i].resize(gridSize,gridSize);
  }
  for(int i=0;i<7;i++){
    String s = "player"+str(i+1);
    String s2 = s;
    s+=".png";
    s2+="-1.png";
    Playerleft[i] = loadImage(s);
    Playerright[i] = loadImage(s2);
    Playerleft[i].resize(gridSize,gridSize);
    Playerright[i].resize(gridSize,gridSize);
  }
  for(int i=0;i<8;i++){
    String s = "Coin_"+str(i+1)+".png";
    coin[i]=loadImage(s);
    coin[i].resize(gridSize,gridSize);
  }
  textAlign(CENTER, CENTER);
  textSize(64);
  // Initialize circles with random positions and colors
  for (int i = 0; i < 3*numCircles; i++) {
    circlePositions[i] = new PVector(random(width), random(height));
    circleSizes[i] = random(10, maxDiameter);
    circleColors[i] = color(random(255), random(255), random(255), 200);
  }

  minim = new Minim(this);
  player = minim.loadFile("BGM.mp3");
  player.loop();

  //settingsButton = loadImage("settingsButton.jpg"); // Replace with your settings button image file
  quitButton = loadImage("quit.jpg"); // Replace with your quit button image file
  settingsButton = loadImage("setting.png");
  settingsButton.resize(110, 55); // Adjust size as needed
  quitButton.resize(100, 50); // Adjust size as needed
  statusbar.resize(1000,40);
  size(1000, 840);
  //startButton = loadImage("startButton.jpg"); // Load the start button image
  beginscr.resize(1000,840);
  background(beginscr);

  // Display the start button on the screen
  //image(startButton, width/2 - startButton.width/2, height/2 - startButton.height/2);
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867
}

void mouseClicked() {
    //Check if the mouse was clicked on the start button
    if (level ==  0) { //in mainscreen
        if (showlevel) {   //level select screen options
           if (mouseX > 230 && mouseX < 312 && mouseY > 410 && mouseY < 515) {   //level 1 buttons
                level = 1; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
           if (mouseX > 325 && mouseX < 407 && mouseY > 410 && mouseY < 515) {   //level 2 buttons
                level = 2; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
           if (mouseX > 415 && mouseX < 497 && mouseY > 410 && mouseY < 515) {   //level 3 buttons
                level = 3; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
           if (mouseX > 505 && mouseX < 587 && mouseY > 410 && mouseY < 515) {   //level 4 buttons
                level = 4; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
           if (mouseX > 595 && mouseX < 677 && mouseY > 410 && mouseY < 515) {   //level 5 buttons
                level = 5; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
           if (mouseX > 685 && mouseX < 767 && mouseY > 410 && mouseY < 515) {   //level 5 buttons
                level = 6; // or any other level you want to start
                setuplevel(); // Load the level and start the game
        }
        }
        // Check if the Quit button is clicked
        if (mouseX > 860 && mouseX < 960 && mouseY > 700 && mouseY < 750 + statusbarh) {
            exit(); // Quit the game
        }
        if (mouseX > 730 && mouseX < 840 && mouseY > 695 && mouseY < 750 + statusbarh) {
            if (showinstru ==  false)showinstru = true; // Open settings - implement settings functionality
            else showinstru = false;
        }
        if (mouseX > width / 3 - 20 && mouseX < width / 2 + 180 && 
            mouseY > height - 110 && mouseY < height - 50) {
           // If clicked on the start button, let the user choose a level
            if (showlevel ==  false)
                showlevel = true;
            else
                showlevel = false;
        }
        
        // Mute button
        if (mouseX > 100 && mouseX < 180 && mouseY > height - 100 && mouseY < height - 20) {
           if (!isMuted) {
                player.setGain( - 80); 
                isMuted = true;
        } else {
                player.setGain(0); 
                player.setBalance(0);
                isMuted = false;
        }
        }
        
}
}

void draw() {
<<<<<<< HEAD
    background(0);
    if(!animationDone) {
        drawCircles();
} else if (animationDone && ! titledone) {
        displayTitle();
} else {
        if (level ==  0) {
            // Display the start button on the screen
            background(beginscr);
            if (isMuted)image(unmuteIcon, 100, height - 100, 80, 80);
            else image(muteIcon, 100, height - 100, 80, 80);
            
            image(settingsButton, 730, 695 + statusbarh); // Adjust position as needed
            image(quitButton, 860, 700 + statusbarh); // Adjust position as needed
            if (showlevel) image(levelSelectImage, 200, 75);
            if (showinstru) image(instrucImage, 200, 75);
            //image(startButton, 505, 410);
            
        } else if (level >=  1 &&  level <=  6) {
            if (!levelPassed && ! isGameOver) {
                background(back_image);
                // Draw the board
                for (int i = 0; i < board.length; i++) {
                    for (int j= 0; j < board[i].length; j++) {
                        if (board[i][j] == 1) { //block 1
                            image(stoneblock,i * gridSize,j * gridSize, gridSize * 1, gridSize * 1.7);
                            /*fill(100); // gray for blocks
                            rect(i*gridSize, j*gridSize, gridSize, gridSize);*/
                        }
                        if (board[i][j] == 2) {
                            fill(0, 255, 0); // green for player
                            ellipse(i * gridSize + gridSize / 2, j * gridSize + gridSize / 2, gridSize, gridSize);
                        }
                        if (board[i][j] ==  5) { //block 2
                            image(brickblock,i * gridSize,j * gridSize, gridSize * 1, gridSize * 1.7);
                        }
                        // ... Add drawing logic for other entities
                }
                }
                for (Enemy enemy : enemies) {
                    if (!enemy.checkexist()) continue;
                    enemy.checkBoundary();
                    enemy.move();
                    enemy.checkCollisionWithBlock();
                    enemy.update();
                    enemy.display();
                    
                   if (enemy.checkCollisionWithPlayer()) {
                        isGameOver= true;
                        passTime =millis();
                }
                }
                
               // Handle game over ( Old version )
                /*if (isGameOver) {
                fill(0);
                textSize(48);
                textAlign(CENTER, CENTER);
                text("GAME OVER", width / 2, height / 2);
                noLoop();  // Stop updating the game
        }*/
                //handle winnnig condiions
                pass =true;
                for (int i = 0;i < enemies.size();i++) {
                    Enemy monster = enemies.get(i);
                    if (monster.checkexist()) {pass = false;break;}
            }
                if (pass) {
                    levelPassed = true;
                    passTime= millis();
            }
                
               if (isBlockMoving) {
                    // Move the block towards its destination
                    movingBlockX += (destBlockX - movingBlockX) * blockSpeed * 0.01; // 0.01 is just a smoothing factor
                    movingBlockY += (destBlockY - movingBlockY) * blockSpeed * 0.01;
                    
                    // Checkif block has reached its destination (or very close)
                    if (dist(movingBlockX, movingBlockY, destBlockX, destBlockY) < 1) {
                        isBlockMoving = false;
                        board[floor(destBlockX / gridSize)][floor(destBlockY / gridSize)] = 1;  // Place the block at destination
                }
                    
                   // Draw the moving block
                    //fill(100);
                    //rect(movingBlockX, movingBlockY, gridSize, gridSize);
                    image(stoneblock,movingBlockX, movingBlockY, gridSize * 1, gridSize * 1.7);
                }
                image(statusbar,0,800);
                textSize(32);
                fill(40,200,73);
                mins = (int)((millis() - startgametime) / 1000 / 60);
                int sceond = (int)((millis() - startgametime) / 1000) % 60;
                text(mins + " : " + sceond ,380,815);
                text(overallscore,800,815);
=======
  background(0);
  if(millis()-anitime>100){
    anitime=millis();
    Enemy_num++;
    Enemy_num%=7;
  }
  if (!animationDone) {
    drawCircles();
  }else if(animationDone&&!titledone){
    displayTitle();
  }else {
    if(level==0){
    // Display the start button on the screen
      background(beginscr);
      if(isMuted)image(unmuteIcon, 100, height - 100, 80, 80);
      else image(muteIcon, 100, height - 100, 80, 80);

      image(settingsButton, 730, 695+statusbarh); // Adjust position as needed
      image(quitButton, 860, 700+statusbarh); // Adjust position as needed
      if(showlevel) image(levelSelectImage, 200, 75);
      if(showinstru) image(instrucImage, 200, 75);
      //image(startButton, 505, 410);

    }
    else if(level>=1&&level<=6){
      if(!levelPassed&&!isGameOver){
        background(back_image);
        // Draw the board
        for (int i = 0; i < board.length; i++) {
          for (int j = 0; j < board[i].length; j++) {
            if (board[i][j] == 1) { //block 1
              image(stoneblock,i*gridSize,j*gridSize, gridSize*1, gridSize*1.7);
              /*fill(100); // gray for blocks
              rect(i*gridSize, j*gridSize, gridSize, gridSize);*/
            }
            if (board[i][j] == 2) {
              //fill(0, 255, 0); // green for player
              if(dir==2||dir==3)
              image(Playerleft[Enemy_num],i*gridSize + gridSize/2-15, j*gridSize + gridSize/2-15,Playerleft[Enemy_num].width,Playerleft[Enemy_num].height);
              else image(Playerright[Enemy_num],i*gridSize + gridSize/2-15, j*gridSize + gridSize/2-15,Playerright[Enemy_num].width,Playerright[Enemy_num].height);
              //ellipse(i*gridSize + gridSize/2, j*gridSize + gridSize/2, gridSize, gridSize);
            }
            if(board[i][j]==5){ //block 2
              image(brickblock,i*gridSize,j*gridSize, gridSize*1, gridSize*1.7);
            }
            if(board[i][j]==6){
              image(coin,i*gridSize,j*gridSize
            }
            // ... Add drawing logic for other entities
          }
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867
        }
            else if (isGameOver) {
                fill(255);
                textSize(48);
                textAlign(CENTER, CENTER);
                text("Game Over you lose level " + level, width / 2, height / 2);
                //text("Your score is " + overallscore, width / 2, height / 2+50);
                
                if (millis() - passTime > 3000) {
                    levelPassed = false;
                    isGameOver= false;
                    level = 0;
                    setuplevel();
                }
        }
        else{
                fill(255);
                textSize(48);
                textAlign(CENTER, CENTER);
                text("Pass level " + level, width / 2, height / 2);
                text("Your score is " + overallscore, width / 2, height / 2 + 50);
                
                if (millis() - passTime > 3000) {
                    levelPassed = false;
                    level = 0;
                    setuplevel();
                }
        }
            
        }
}
}
int movex[] = { - 1,0,1,0};
int movey[] = {0,1,0, - 1};
void keyPressed() {
<<<<<<< HEAD
    if (level ==  0)return;
    int playerCellX = playerX / gridSize;
    int playerCellY = playerY / gridSize;
    if(keyCode == UP &&  dir!= 0)dir = 0;
    else if (keyCode == RIGHT && dir!= 1)dir = 1;
    else if (keyCode == DOWN  && dir!= 2)dir = 2;
    else if (keyCode == LEFT  && dir!= 3)dir = 3;
    else{
        if (keyCode == UP && playerY > 0 && board[playerCellX][playerCellY - 1] != 1 && board[playerCellX][playerCellY - 1] != 5) {
            playerY -= gridSize;dir = 0;}
        if (keyCode == DOWN && playerY < height - gridSize - statusbarh && board[playerCellX][playerCellY + 1] != 1 && board[playerCellX][playerCellY + 1] != 5) {
            playerY += gridSize;dir = 2;}
        if (keyCode == LEFT && playerX > 0 && board[playerCellX - 1][playerCellY] != 1 && board[playerCellX - 1][playerCellY] != 5) {
            playerX -= gridSize;dir = 3;}
        if (keyCode == RIGHT && playerX < width - gridSize && board[playerCellX + 1][playerCellY] != 1 && board[playerCellX + 1][playerCellY] != 5) {
            playerX += gridSize;dir = 1;}
}
    //println("Key pressed: " + dir);
    if(keyCode == 32 ||  key ==  ' ') {
        if (hasBlock &&  isBlockMoving ==  false) {
            // Try to throw the block
            int nextCellX = playerCellX + movey[dir];
            int nextCellY = playerCellY + movex[dir];
            
            // Find a suitable spot to throw the block, i.e., the first empty spot in the current direction
            while(nextCellX >= 0 && nextCellX < board.length && 
                nextCellY >= 0 && nextCellY < board[0].length && 
                board[nextCellX][nextCellY] != 1 && board[nextCellX][nextCellY] != 5) {
                nextCellX += movey[dir];
                nextCellY += movex[dir];
            }
            
            // Place the block in the last empty spot found
            if (nextCellX - movey[dir] >= 0 && nextCellX - movey[dir] < board.length && 
                nextCellY - movex[dir] >= 0 && nextCellY - movex[dir] < board[0].length) {
                //board[nextCellX - movey[dir]][nextCellY - movex[dir]] = 1;
                //hasBlock = false;
                isBlockMoving = true;
                hasBlock = false;
                
                movingBlockX = playerX;
                movingBlockY = playerY;
                destBlockX = (nextCellX - movey[dir]) * gridSize;
                destBlockY = (nextCellY - movex[dir]) * gridSize;
            }
        }  
        else if (!hasBlock) {
           // Check blocks around the player and swallow them
            
            int checkX = playerCellX + movey[dir];
            int checkY = playerCellY + movex[dir];
            if(checkX >= 0 && checkX < board.length && checkY >= 0 && checkY < board[0].length) {
                if (board[checkX][checkY] == 1) {  // If it's a stoneblock (player can't swallow brick block)
                    hasBlock = true;
                    board[checkX][checkY] = 0;  // Remove the block and make it a path
                }
                else{ // If it's a enemy
                    // Find and update the monster
                    for (int i = 0; i < enemies.size(); i++) {
                        Enemy monster = enemies.get(i);
                        int mx = Math.round(monster.x / gridSize);
                        int my = Math.round(monster.y / gridSize);
                        println("mx=" + mx + " my = " + my);
                       if (mx== checkX && my == checkY) {
                            overallscore += monster.getscore();
                            println("current score = " + overallscore);
                           // Update the monster state
                            monster.exist = false;
                            board[checkX][checkY] = 0;  // Remove the monster from the board
                            break;
                    }
                }
                    
                }
        }
    }
        
}
    
    board[playerCellX][playerCellY] = 0;  // remove player from previous position
    board[playerX / gridSize][playerY / gridSize] = 2;  // place player in new position
=======
  if(level==0)return;
  int playerCellX = playerX / gridSize;
  int playerCellY = playerY / gridSize;
  if (keyCode == UP &&dir!=0)dir=0;
  else if (keyCode == RIGHT && dir!=1)dir=1;
  else if (keyCode == DOWN  && dir!=2)dir=2;
  else if (keyCode == LEFT  && dir!=3)dir=3;
  else{
    if (keyCode == UP && playerY > 0 && board[playerCellX][playerCellY - 1] != 1&& board[playerCellX][playerCellY - 1] != 5) {
      playerY -= gridSize;dir=0;}
    if (keyCode == DOWN && playerY < height - gridSize-statusbarh && board[playerCellX][playerCellY + 1] != 1 && board[playerCellX][playerCellY + 1] != 5) {
      playerY += gridSize;dir=2;}
    if (keyCode == LEFT && playerX > 0 && board[playerCellX - 1][playerCellY] != 1 && board[playerCellX - 1][playerCellY] != 5) {
      playerX -= gridSize;dir=3;}
    if (keyCode == RIGHT && playerX < width - gridSize && board[playerCellX + 1][playerCellY] != 1 && board[playerCellX + 1][playerCellY] != 5) {
      playerX += gridSize;dir=1;}
  }
  //println("Key pressed: " + dir);
  if (keyCode == 32||key==' ' ) {
    if (hasBlock&&isBlockMoving==false) {
        // Try to throw the block
        int nextCellX = playerCellX + movey[dir];
        int nextCellY = playerCellY + movex[dir];
        
        // Find a suitable spot to throw the block, i.e., the first empty spot in the current direction
        while (nextCellX >= 0 && nextCellX < board.length && 
               nextCellY >= 0 && nextCellY < board[0].length && 
               board[nextCellX][nextCellY] !=1 && board[nextCellX][nextCellY] !=5) {
            nextCellX += movey[dir];
            nextCellY += movex[dir];
        }

        // Place the block in the last empty spot found
        if (nextCellX - movey[dir] >= 0 && nextCellX - movey[dir] < board.length &&
            nextCellY - movex[dir] >= 0 && nextCellY - movex[dir] < board[0].length) {
            //board[nextCellX - movey[dir]][nextCellY - movex[dir]] = 1;
            //hasBlock = false;
            isBlockMoving = true;
            hasBlock = false;

            movingBlockX = playerX;
            movingBlockY = playerY;
            destBlockX = (nextCellX - movey[dir]) * gridSize;
            destBlockY = (nextCellY - movex[dir]) * gridSize;
        }
    }  
    else if(!hasBlock){
      // Check blocks around the player and swallow them

          int checkX = playerCellX + movey[dir];
          int checkY = playerCellY + movex[dir];
          if (checkX >= 0 && checkX < board.length && checkY >= 0 && checkY < board[0].length) {
            if (board[checkX][checkY] == 1) {  // If it's a stoneblock (player can't swallow brick block)
              hasBlock = true;
              board[checkX][checkY] = 0;  // Remove the block and make it a path
            }
            else{ // If it's a enemy
            // Find and update the monster
              for (int i = 0; i < enemies.size(); i++) {
                  Enemy monster = enemies.get(i);
                  int mx=Math.round(monster.x / gridSize);
                  int my=Math.round(monster.y / gridSize);
                  println("mx="+ mx + " my = "+ my);
                  if (mx == checkX && my == checkY&&monster.exist) {
                      overallscore+=monster.getscore();
                      println("current score = "+overallscore);
                      // Update the monster state
                      monster.exist = false;
                      board[checkX][checkY] = 0;  // Remove the monster from the board
                      break;
                  }
              }
              
            }
          }
      }

  }

  board[playerCellX][playerCellY] = 0;  // remove player from previous position
  board[playerX / gridSize][playerY / gridSize] = 2;  // place player in new position
>>>>>>> 1191fa09acde067f13808b9b501e6e71df31b867
}
