import gohai.glvideo.*;
import VLCJVideo.*;
import processing.video.*;
import ddf.minim.*;
//sound parts
Minim minim;
AudioPlayer player;
PImage muteIcon,unmuteIcon;
PImage stoneblock,back_image;
PImage beginscr;
PImage levelSelectImage;
PImage settingsButton, quitButton, levelSelectScreen;
boolean isPlaying = true;
boolean isMuted = false;

int gridSize = 40;
boolean isGameOver = false;
int[][] board; // 0: empty, 1: block, 2: player, 3: enemy
int playerX, playerY;
int dir;
Boolean hasBlock=false;
boolean isBlockMoving = false;
float movingBlockX, movingBlockY;  // Current position of the moving block
float destBlockX, destBlockY;  // Destination position
float blockSpeed = 5;  // Speed at which block moves (adjust as needed)
int stunnedDuration=300;
int lastExecutedTime = 0;


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
    boolean isStunned;
    int stunnedCounter;
    int enemex,enemey;
    int enemySpeed=1;
    int nextX,nextY;

    Enemy(float x, float y,int speed) {
        this.enemySpeed = speed;
        this.x = x;
        this.y = y;
        enemex=int(x/gridSize);
        enemey=int(y/gridSize);
        this.direction = new int[]{1, 0}; // Default to moving right
        this.isStunned = false;
        this.stunnedCounter = 0;
    }

    void move() {
        if (!isStunned) {
            this.x += this.direction[0] * enemySpeed;
            this.y += this.direction[1] * enemySpeed;
            enemex=int(this.x/gridSize);
            enemey=int(this.y/gridSize);
        }
    }
    boolean checkCollisionWithPlayer() {
      if (!this.isStunned) {
        println("thisx,thisy"+this.x+" "+this.y+"plx,ply"+ playerX+" "+ playerY);
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
        ellipse(this.x+20 /*gridSize/2*/, this.y+20  /*gridSize/2*/, gridSize, gridSize);
        //ellipse(enemex*gridSize+20, enemey*gridSize+20, gridSize, gridSize);
    }
}
/* old function
void setuplevel(){
  if(level==1){
      enemies.add(new Enemy(width/4, height/2));
      //size(800, 800);
      board = new int[width/gridSize][height/gridSize];
      playerX = width/2;
      playerY = height/2;
      board[playerX/gridSize][playerY/gridSize] = 2; // set player start position
      for(int i=0;i<width/gridSize;i++){  ///set up the map
        board[i][2]=1; 
      }
      board[5][5]=1;
  }
  else{
    println("Invalid level "+level);
  }
  return;      
}*/
void setuplevel() {
  
  image(back_image, 0, 0, width, height);
  player.rewind(); 
  player.loop();
  if (level == 1) {
    JSONObject json = loadJSONObject("map.json"); // Load the JSON file
    JSONObject levelData = json.getJSONObject("level1"); // Get data for level1

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
      enemies.add(new Enemy(x, y, int(random(2,3)) ));
    }
  } else {
    println("Invalid level " + level);
  }
}

void setup() {
  beginscr = loadImage("Begin_Screen.jpg");
  muteIcon = loadImage("unmute.jpg");
  stoneblock = loadImage("block2.png");
  unmuteIcon = loadImage("mute.jpg");
  levelSelectImage = loadImage("levelSelectImage.png"); // Replace with your level selection image file
  levelSelectImage.resize(600,500); // Adjust size as needed
  back_image = loadImage("background.jpg");
  back_image.resize(1000,800);
  minim = new Minim(this);
  player = minim.loadFile("BGM.mp3");
  player.loop();

  //settingsButton = loadImage("settingsButton.jpg"); // Replace with your settings button image file
  quitButton = loadImage("quit.jpg"); // Replace with your quit button image file
  settingsButton = loadImage("setting.jpg");
  settingsButton.resize(50, 50); // Adjust size as needed
  quitButton.resize(100, 50); // Adjust size as needed

  size(1000, 800);
  startButton = loadImage("startButton.jpg"); // Load the start button image
  beginscr.resize(1000,800);
  background(beginscr);

  // Display the start button on the screen
  //image(startButton, width/2 - startButton.width/2, height/2 - startButton.height/2);
}

void mouseClicked() {
  // Check if the mouse was clicked on the start button
  if(level==0){ //in mainscreen

    if (mouseX > 400 && mouseX < 600 && mouseY > 350 && mouseY < 450) {
            level = 1; // or any other level you want to start
            setuplevel(); // Load the level and start the game
    }

    if (mouseX > 750 && mouseX < 800 && mouseY > 700 && mouseY < 750) {
            // Open settings - implement settings functionality
    }

    // Check if the Quit button is clicked
    if (mouseX > 850 && mouseX < 950 && mouseY > 700 && mouseY < 750) {
        exit(); // Quit the game
    }
    if (mouseX > width/3 -20 && mouseX < width/2 + 180 &&
        mouseY > height -110 && mouseY < height-50 ) {
      // If clicked on the start button, let the user choose a level
      int chosenLevel = int(random(0,1)); // Generate a random level (you can modify this)
      level=chosenLevel;
      level=1;
      setuplevel();
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
  if(level==0){
  // Display the start button on the screen
    //image(startButton, width/2+180, height-50);
    if(isMuted)image(muteIcon, 100, height - 90, 80, 80);
    else image(unmuteIcon, 100, height - 90, 80, 80);

    image(settingsButton, 750, 700); // Adjust position as needed
    image(quitButton, 850, 700); // Adjust position as needed
    image(levelSelectImage, 200, 75);
  }
  else if(level==1){
    background(back_image);

    // Draw the board
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        if (board[i][j] == 1) {
          image(stoneblock,i*gridSize,j*gridSize, gridSize*1, gridSize*1.7);
          /*fill(100); // gray for blocks
          rect(i*gridSize, j*gridSize, gridSize, gridSize);*/
        }
        if (board[i][j] == 2) {
          fill(0, 255, 0); // green for player
          ellipse(i*gridSize + gridSize/2, j*gridSize + gridSize/2, gridSize, gridSize);
        }
        // ... Add drawing logic for other entities
      }
    }
    for (Enemy enemy : enemies) {
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
}
int movex[]={-1,0,1,0};
int movey[]={0,1,0,-1};
void keyPressed() {
  int playerCellX = playerX / gridSize;
  int playerCellY = playerY / gridSize;
  if (keyCode == UP)dir=0;if (keyCode == RIGHT)dir=1;if (keyCode == DOWN)dir=2;if (keyCode == LEFT)dir=3;
  if (keyCode == UP && playerY > 0 && board[playerCellX][playerCellY - 1] == 0) {
    playerY -= gridSize;dir=0;}
  if (keyCode == DOWN && playerY < height - gridSize && board[playerCellX][playerCellY + 1] == 0) {
    playerY += gridSize;dir=2;}
  if (keyCode == LEFT && playerX > 0 && board[playerCellX - 1][playerCellY] == 0) {
    playerX -= gridSize;dir=3;}
  if (keyCode == RIGHT && playerX < width - gridSize && board[playerCellX + 1][playerCellY] == 0) {
    playerX += gridSize;dir=1;}
  //println("Key pressed: " + dir);
  if (keyCode == 32||key==' ' ) {
    if (hasBlock) {
        // Try to throw the block
        int nextCellX = playerCellX + movey[dir];
        int nextCellY = playerCellY + movex[dir];
        
        // Find a suitable spot to throw the block, i.e., the first empty spot in the current direction
        while (nextCellX >= 0 && nextCellX < board.length && 
               nextCellY >= 0 && nextCellY < board[0].length && 
               board[nextCellX][nextCellY] !=1) {
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
    else{
      // Check blocks around the player and swallow them

          int checkX = playerCellX + movey[dir];
          int checkY = playerCellY + movex[dir];
          if (checkX >= 0 && checkX < board.length && checkY >= 0 && checkY < board[0].length) {
            if (board[checkX][checkY] == 1) {  // If it's a block
              hasBlock = true;
              board[checkX][checkY] = 0;  // Remove the block and make it a path
            }
          }
      }

  }

  board[playerCellX][playerCellY] = 0;  // remove player from previous position
  board[playerX / gridSize][playerY / gridSize] = 2;  // place player in new position
}
