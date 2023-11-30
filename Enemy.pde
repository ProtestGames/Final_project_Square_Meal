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
    boolean checkstun(){
      return this.isStunned;
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
      boolean hitBoundary = (this.x < 0 || this.x+gridSize  > width || this.y < 0 || this.y+gridSize+statusbarh   > height);
      if(this.x<0) this.x=0;
      if(this.x+gridSize>width) this.x=width-gridSize;
      if(this.y<0) this.y=0;
      if(this.y+gridSize>height-statusbarh) this.y=height-gridSize-statusbarh;

      // Check for collision with blocks on the board
      boolean hitBlock = false;
      for (int i = 0; i < board.length; i++) {
          for (int j = 0; j < board[0].length; j++) {
              if (board[i][j] == 1 || board[i][j]==5) {
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
    }
}

class Mirage extends Enemy {
    private boolean isHidden = false;
    private int hideCooldown = int(random(2,6));
    private int hideTimestamp = 0;
    private int lastHideTimestamp = 0;
    private int MAX_HIDE_DURATION = 20;
    private int hidetime = int(random(2,5));
    private float HIDE_CHANCE = 4.34;

    //default properties
    private int enemex, enemey;
    private int lastx, lasty;
    
    Mirage(float x, float y, int speed, int score) {
        super(x, y, speed, score);
    }
    
    public void display() {
        if (this.isStunned) {
          if(this.direction[0]==-1)
            image(miragestun,this.x,this.y,miragestun.width, miragestun.height);
          else
            image(miragestun_1,this.x,this.y,miragestun_1.width, miragestun_1.height);
        } 
        else {
          if(!this.isHidden){
            if(this.direction[0]==-1)
              image(mirleft[mirage_num],this.x,this.y,mirleft[mirage_num].width, mirleft[mirage_num].height);
            else
              image(mirright[mirage_num],this.x,this.y,mirright[mirage_num].width, mirright[mirage_num].height);
          }
          else
            image(stoneblock,this.x,this.y,gridSize,gridSize*1.7);
        }
    }

    private boolean checkHideStatus() {
        if (this.isHidden) {
           if (getTimestamp() - this.hideTimestamp>hidetime) {
                this.isHidden = false;
                display();
                return false;
            }
            return true;
        }
        
        return false;
    }
    public void checkCollisionWithBlock() {
      if (isBlockMoving && checkAABBCollision(this.x, this.y, gridSize, gridSize, movingBlockX, movingBlockY, gridSize, gridSize)) {
        if(!this.isHidden)
          this.isStunned = true;
        else{
          isBlockMoving = false;
          board[enemex][enemey] = 1;
        }
      }
    }

    public void move() {
        if (checkHideStatus()) {
          unhide();
          return;
        }
        if (isStunned) {
          return;
        }
        if(!this.isHidden&&millis()-this.hideTimestamp>3)
          hide();
        //unhide();
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
        println("try to hide");
        if (this.isHidden) {
            return;
        }
        if (random(1,6) > this.HIDE_CHANCE) {
            return;
        }
        if ((getTimestamp() - this.lastHideTimestamp) < this.hideCooldown) {
            println("current "+getTimestamp() +" lasthide "+this.lastHideTimestamp);
            return;
        }
        //replace self with stone block here
        this.isHidden = true;
        this.hideTimestamp = getTimestamp();
        println("HIDE!");
    }

    private void unhide() {
        if (!isHidden||getTimestamp()-this.hideTimestamp<2) {
          println("ishiden : "+isHidden);
          println(getTimestamp()+" - "+this.hideTimestamp);
          return;
        }
        else{
          this.lastHideTimestamp = getTimestamp();
          this.isHidden = false;
          println("UNHIDE!");
          display();
        //deletes the stone block here
        }
    }
}