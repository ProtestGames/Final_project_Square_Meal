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
int enemySpeed=2;
int stunnedDuration=300;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
class Enemy {
    float x, y;
    int[] direction;
    boolean isStunned;
    int stunnedCounter;

    Enemy(float x, float y) {
        this.x = x;
        this.y = y;
        this.direction = new int[]{1, 0}; // Default to moving right
        this.isStunned = false;
        this.stunnedCounter = 0;
    }

    void move() {
        if (!isStunned) {
            this.x += this.direction[0] * enemySpeed;
            this.y += this.direction[1] * enemySpeed;
        }
    }
    boolean checkCollisionWithPlayer() {
        if (!this.isStunned && dist(this.x, this.y, playerX, playerY) < gridSize) {
            return true;
        }
        return false;
    }


    void checkBoundary() {
        if (this.x <= 0 || this.x >= width - gridSize || board[(int)this.x/gridSize][(int)(this.y/gridSize)] == 1) {
            this.direction[0] = -this.direction[0];
            this.direction[1] = -this.direction[1];
        }
    }

    void checkCollisionWithBlock() {
        if (isBlockMoving && dist(this.x, this.y, movingBlockX, movingBlockY) < gridSize) {
            isBlockMoving = false; // Stop the block
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
        ellipse(this.x + gridSize/2, this.y + gridSize/2, gridSize, gridSize);
    }
}

void setup() {
  enemies.add(new Enemy(width/4, height/2));
  size(800, 800);
  board = new int[width/gridSize][height/gridSize];
  playerX = width/2;
  playerY = height/2;
  board[playerX/gridSize][playerY/gridSize] = 2; // set player start position
  for(int i=0;i<width/gridSize;i++){  ///set up the map
    board[i][2]=1; 
  }
  board[5][5]=1;
}

void draw() {
  background(255);

  // Draw the board
  for (int i = 0; i < board.length; i++) {
    for (int j = 0; j < board[i].length; j++) {
      if (board[i][j] == 1) {
        fill(100); // gray for blocks
        rect(i*gridSize, j*gridSize, gridSize, gridSize);
      }
      if (board[i][j] == 2) {
        fill(0, 255, 0); // green for player
        ellipse(i*gridSize + gridSize/2, j*gridSize + gridSize/2, gridSize, gridSize);
      }
      // ... Add drawing logic for other entities
    }
  }
  for (Enemy enemy : enemies) {
    enemy.move();
    enemy.checkBoundary();
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
    fill(100);
    rect(movingBlockX, movingBlockY, gridSize, gridSize);
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
  println("Key pressed: " + dir);
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
