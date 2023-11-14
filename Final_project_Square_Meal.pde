import gohai.glvideo.*;
import VLCJVideo.*;
import processing.video.*;
import ddf.minim.*;
//sound parts
Minim minim;
AudioPlayer player;
PImage muteIcon,unmuteIcon;
PImage stoneblock,brickblock,back_image;
PImage beginscr;
PImage levelSelectImage,instrucImage;
PImage settingsButton, quitButton, levelSelectScreen;
boolean isPlaying = true;
boolean isMuted = false;
int overallscore=0;
boolean levelPassed = false;
boolean showinstru = false ;
boolean pass = false;
int gridSize = 40;
boolean isGameOver = false;
int[][] board; // 0: empty, 1: block, 2: player, 3: enemy
int playerX, playerY;
int dir;
Boolean hasBlock=false;
Boolean showlevel=false;
boolean isBlockMoving = false;
float movingBlockX, movingBlockY;  // Current position of the moving block
float destBlockX, destBlockY;  // Destination position
float blockSpeed = 5;  // Speed at which block moves (adjust as needed)
int stunnedDuration=300;
int lastExecutedTime = 0;
int passTime = -1; // -1 indicates that the level has not been passed yet



int settingsButtonX, settingsButtonY, settingsButtonWidth, settingsButtonHeight;
int quitButtonX, quitButtonY, quitButtonWidth, quitButtonHeight;

PImage startButton;
int level=0;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
color c = color(100, 101, 120);

boolean checkAABBCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  float leftx1 ,rightx1;
  float upy1 ,downy1;
  float leftx2 ,rightx2;
  float upy2 ,downy2;
  leftx1=x1; rightx1=x1+w1;
  leftx2=x2; rightx2=x2+w2;
  upy1=y1;   downy1=y1+h1;
  upy2=y2;   downy2=y2+h2;

  if(rightx1<=leftx2|| rightx2<=leftx1) return false;
  if(downy1<=upy2||upy1>=downy2) return false;
  return true;
}

class Enemy {
    float x, y;
    int[] direction;
    boolean isStunned,exist;
    int stunnedCounter;
    int enemex,enemey,score;
    int lastx,lasty;
    int enemySpeed=1;
    int nextX,nextY;

    Enemy(float x, float y,int speed,int score) {
        this.enemySpeed = speed;
        this.x = x;
        this.y = y;
        enemex=int(x/gridSize);
        lastx=enemex;
        enemey=int(y/gridSize);
        lasty=enemey;
        this.direction = new int[]{1, 0}; // Default to moving right
        this.isStunned = false;
        this.stunnedCounter = 0;
        this.exist = true ;
        this.score = score;
    }
    int getscore(){
      return this.score;
    }
    boolean checkexist(){
      return this.exist;
    }
    void move() {
        if (!isStunned) {
            this.x += this.direction[0] * enemySpeed;
            this.y += this.direction[1] * enemySpeed;
            enemex=int(this.x/gridSize);
            enemey=int(this.y/gridSize);
            if(board[lastx][lasty]==3)board[lastx][lasty]=0;
            lastx=enemex;lasty=enemey;
            if(board[enemex][enemey]==0)board[enemex][enemey]=3;
        }
    }
    boolean checkCollisionWithPlayer() {
      if (!this.isStunned) {
        //println("thisx,thisy"+this.x+" "+this.y+"plx,ply"+ playerX+" "+ playerY);
        return checkAABBCollision(this.x, this.y, gridSize, gridSize, playerX, playerY, gridSize, gridSize);
      }
      return false;
    }


    void turnCounterClockwise() {
      if (millis() - lastExecutedTime < 250)return;
      lastExecutedTime=millis();
      if (this.direction[0] == 1 && this.direction[1] == 0) { // Moving right
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
      // Check for collision with game boundaries
      boolean hitBoundary = (this.x < 0 || this.x+gridSize  > width || this.y < 0 || this.y+gridSize   > height);
      if(this.x<0) this.x=0;
      if(this.x+gridSize>width) this.x=width-gridSize;
      if(this.y<0) this.y=0;
      if(this.y+gridSize>height) this.y=height-gridSize;

      // Check for collision with blocks on the board
      boolean hitBlock = false;
      for (int i = 0; i < board.length; i++) {
          for (int j = 0; j < board[0].length; j++) {
              if (board[i][j] == 1) {
                  float blockX = i * gridSize;
                  float blockY = j * gridSize;
                  if (checkAABBCollision(this.x, this.y, gridSize, gridSize, blockX, blockY, gridSize, gridSize)) {
                      hitBlock = true;
                      break;
                  }
              }
          }
          if (hitBlock) {
              break;
          }
      }

      // If the enemy hits a boundary or a block, turn counterclockwise
      if (hitBoundary || hitBlock) {
        if(hitBlock){
          if(direction[0]>0) this.x-=(this.x%gridSize);
          if(direction[1]>0) this.y-=(this.y%gridSize);
          if(direction[0]<0) this.x+=(gridSize - (this.x%gridSize));
          if(direction[1]<0) this.y+=(gridSize - (this.y%gridSize));
        }//if(direction[0]>0){this.x-=(this.x%gridSize);}else {this.x+=(this.x%gridSize);}
        //if(direction[1]>0){this.y-=(this.y%gridSize);}else {this.y+=(this.y%gridSize);}
          turnCounterClockwise();
      }
    }


    void checkCollisionWithBlock() {
      if (isBlockMoving && checkAABBCollision(this.x, this.y, gridSize, gridSize, movingBlockX, movingBlockY, gridSize, gridSize)) {
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
        fill(255, 0, 0); // Red for enemy
        if (this.isStunned) {
            fill(128, 0, 0); // Dark red for stunned enemy
        }
        ellipse(this.x+20, this.y+20, gridSize, gridSize);
    }
}


void loadlevel(int level){
  overallscore=0;
  if(level<=0||level>6){
    println("Invalid level "+level); return;
  }
  JSONObject json = loadJSONObject("map.json"); // Load the JSON file
  JSONObject levelData = json.getJSONObject("level"+str(level)); // Get data for level1
  if(levelData==null){
      println("Invalid level "+level); return;
  }
  else{
    println("try to load level"+level);
  }
  // Get the board data
  JSONArray boardData = levelData.getJSONArray("board");
  board = new int[width/gridSize][height/gridSize];
  for (int i = 0; i < boardData.size(); i++) {
    JSONArray row = boardData.getJSONArray(i);
    for (int j = 0; j < row.size(); j++) {
      board[j][i] = row.getInt(j);
    }
  }

  // Get player position
  playerX = levelData.getInt("playerX");
  playerY = levelData.getInt("playerY");

  // Get enemy data
  JSONArray enemiesData = levelData.getJSONArray("enemies");
  for (int i = 0; i < enemiesData.size(); i++) {
    JSONObject enemyData = enemiesData.getJSONObject(i);
    float x = enemyData.getFloat("x");
    float y = enemyData.getFloat("y");
    int spd = enemyData.getInt("speed");
    int sco = enemyData.getInt("score");
    enemies.add(new Enemy(x, y, spd,sco) );
  }

  println("loaded level successfully");  

}
void setuplevel() {
  
  image(back_image, 0, 0, width, height);
  player.rewind(); 
  player.loop();
  if(level>0){

  }
  loadlevel(level);
}

void setup() {
  oldenglish = loadFont("BerlinSansFB-Bold-48.vlw");
  instrucImage = loadImage("Instructions.png");
  instrucImage.resize(600,600);
  beginscr = loadImage("Begin_Screen.jpg");
  muteIcon = loadImage("unmute.jpg");
  stoneblock = loadImage("block2.png");
  brickblock = loadImage("block1.png");
  brickblock.resize(50,78);
  unmuteIcon = loadImage("mute.jpg");
  levelSelectImage = loadImage("levelSelectImage.png"); // Replace with your level selection image file
  levelSelectImage.resize(600,500); // Adjust size as needed
  back_image = loadImage("background.jpg");
  back_image.resize(1000,800);
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
  settingsButton = loadImage("setting.jpg");
  settingsButton.resize(50, 50); // Adjust size as needed
  quitButton.resize(100, 50); // Adjust size as needed

  size(1000, 800);
  //startButton = loadImage("startButton.jpg"); // Load the start button image
  beginscr.resize(1000,800);
  background(beginscr);

  // Display the start button on the screen
  //image(startButton, width/2 - startButton.width/2, height/2 - startButton.height/2);
}

void mouseClicked() {
  // Check if the mouse was clicked on the start button
  if(level==0){ //in mainscreen
    if(showlevel){   //level select screen options
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
    if (mouseX > 750 && mouseX < 800 && mouseY > 700 && mouseY < 750) {
            // Open settings - implement settings functionality
      if(showinstru==false)showinstru = true;
      else showinstru = false;
    }

    // Check if the Quit button is clicked
    if (mouseX > 850 && mouseX < 950 && mouseY > 700 && mouseY < 750) {
        exit(); // Quit the game
    }
    if (mouseX > width/3 -20 && mouseX < width/2 + 180 &&
        mouseY > height -110 && mouseY < height-50 ) {
      // If clicked on the start button, let the user choose a level
      if(showlevel ==false )
        showlevel = true;
      else
        showlevel = false;
    }

    // Mute button
    if (mouseX > 100 && mouseX < 180 && mouseY > height - 90 && mouseY < height - 10) {
      if (!isMuted) {
        player.setGain(-80); 
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
  background(0);
  if (!animationDone) {
    drawCircles();
  }else if(animationDone&&!titledone){
    displayTitle();
  }else {
    if(level==0){
    // Display the start button on the screen
      background(beginscr);
      if(isMuted)image(muteIcon, 100, height - 90, 80, 80);
      else image(unmuteIcon, 100, height - 90, 80, 80);

      image(settingsButton, 750, 700); // Adjust position as needed
      image(quitButton, 850, 700); // Adjust position as needed
      if(showlevel) image(levelSelectImage, 200, 75);
      if(showinstru) image(instrucImage, 200, 75);
      //image(startButton, 505, 410);

    }
    else if(level>=1&&level<=6){
      if(!levelPassed){
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
              fill(0, 255, 0); // green for player
              ellipse(i*gridSize + gridSize/2, j*gridSize + gridSize/2, gridSize, gridSize);
            }
            if(board[i][j]==5){ //block 2
              image(brickblock,i*gridSize,j*gridSize, gridSize*1, gridSize*1.7);
            }
            // ... Add drawing logic for other entities
          }
        }
        for (Enemy enemy : enemies) {
          if(!enemy.checkexist()) continue;
          enemy.checkBoundary();
          enemy.move();
          enemy.checkCollisionWithBlock();
          enemy.update();
          enemy.display();

          if (enemy.checkCollisionWithPlayer()) {
              isGameOver = true;
          }
        }

          // Handle game over
          if (isGameOver) {
              fill(0);
              textSize(48);
              textAlign(CENTER, CENTER);
              text("GAME OVER", width / 2, height / 2);
              noLoop();  // Stop updating the game
          }
          //handle winnnig condiions
          pass = true;
          for(int i=0;i<enemies.size();i++){
            Enemy monster = enemies.get(i);
            if(monster.checkexist()){pass=false;break;}
          }
          if(pass){
            levelPassed = true;
            passTime = millis();
          }

          if (isBlockMoving) {
            // Move the block towards its destination
            movingBlockX += (destBlockX - movingBlockX) * blockSpeed * 0.01; // 0.01 is just a smoothing factor
            movingBlockY += (destBlockY - movingBlockY) * blockSpeed * 0.01;

            // Check if block has reached its destination (or very close)
            if (dist(movingBlockX, movingBlockY, destBlockX, destBlockY) < 1) {
                isBlockMoving = false;
                board[floor(destBlockX/gridSize)][floor(destBlockY/gridSize)] = 1;  // Place the block at destination
          }
          
          // Draw the moving block
          //fill(100);
          //rect(movingBlockX, movingBlockY, gridSize, gridSize);
          image(stoneblock,movingBlockX, movingBlockY, gridSize*1, gridSize*1.7);

        }
      }
      else{
        fill(255);
        textSize(48);
        textAlign(CENTER, CENTER);
        text("Pass level " + level, width / 2, height / 2);
        text("Your score is " + overallscore, width / 2, height / 2+50);

        if (millis() - passTime > 3000) {
          levelPassed = false;
          level = 0;
          setuplevel();
        }
      }

    }
  }
}
int movex[]={-1,0,1,0};
int movey[]={0,1,0,-1};
void keyPressed() {
  if(level==0)return;
  int playerCellX = playerX / gridSize;
  int playerCellY = playerY / gridSize;
  if (keyCode == UP)dir=0;if (keyCode == RIGHT)dir=1;if (keyCode == DOWN)dir=2;if (keyCode == LEFT)dir=3;
  if (keyCode == UP && playerY > 0 && board[playerCellX][playerCellY - 1] != 1&& board[playerCellX][playerCellY - 1] != 5) {
    playerY -= gridSize;dir=0;}
  if (keyCode == DOWN && playerY < height - gridSize && board[playerCellX][playerCellY + 1] != 1 && board[playerCellX][playerCellY + 1] != 5) {
    playerY += gridSize;dir=2;}
  if (keyCode == LEFT && playerX > 0 && board[playerCellX - 1][playerCellY] != 1 && board[playerCellX - 1][playerCellY] != 5) {
    playerX -= gridSize;dir=3;}
  if (keyCode == RIGHT && playerX < width - gridSize && board[playerCellX + 1][playerCellY] != 1 && board[playerCellX + 1][playerCellY] != 5) {
    playerX += gridSize;dir=1;}
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
                  if (mx == checkX && my == checkY) {
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
}
