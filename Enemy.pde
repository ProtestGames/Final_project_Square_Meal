class Enemy {
    WindowsPosition winPos;
    int[] direction;
    boolean isStunned, exist;
    int stunnedCounter;
    int score;
    BoardPosition currentPos;
    BoardPosition lastPos = new BoardPosition(0, 0);
    int enemySpeed;
    
    Enemy(float x, float y,int speed,int score) {
        this.enemySpeed = speed;
        this.winPos = new WindowsPosition(Math.round(x), Math.round(y));
        this.direction = new int[]{1, 0};
        // enemex = int(x / gridSize);
        // lastx = enemex;
        // enemey = int(y / gridSize);
        // lasty = enemey;
        this.currentPos = winPos.toBoardPosition();
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
    boolean checkstun(){
      return this.isStunned;
    }
    void move() {
        if (!isStunned) {
            this.winPos.X += this.direction[0] * enemySpeed;
            this.winPos.Y += this.direction[1] * enemySpeed; 
            // enemex = int(this.x / gridSize);
            // enemey = int(this.y / gridSize);
            this.currentPos = winPos.toBoardPosition();
            if (board[this.lastPos.X][this.lastPos.Y] == 3) {
                board[this.lastPos.X][this.lastPos.Y] = 0;
            }
            this.lastPos.X = this.currentPos.X;
            this.lastPos.Y = this.currentPos.Y;
            if (board[this.currentPos.X][this.currentPos.Y] == 0) {
                board[this.currentPos.X][this.currentPos.Y] = 3;
            }
        }
    }
    boolean checkCollisionWithPlayer() {
        if (!this.isStunned) {
            //println("thisx,thisy"+this.x+" "+this.y+"plx,ply"+ playerX+" "+ playerY);
            return checkAABBCollision(this.winPos.X, this.winPos.Y, gridSize, gridSize, playerX, playerY, gridSize, gridSize);
        }
        return false;
    }
    
    
    void turnCounterClockwise() {
        if (millis() - lastExecutedTime < 250)return;
        lastExecutedTime = millis();
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
        //Check for collision with game boundaries
        boolean hitBoundary = (this.winPos.X < 0 || this.winPos.X + gridSize > width || this.winPos.Y < 0 || this.winPos.Y + gridSize + statusbarh > height);
        if (this.winPos.X < 0) this.winPos.X = 0;
        if (this.winPos.X + gridSize > width) this.winPos.X = width - gridSize;
        if (this.winPos.Y < 0) this.winPos.Y = 0;
        if (this.winPos.Y + gridSize > height - statusbarh) this.winPos.Y = height - gridSize - statusbarh;
        
        //Check for collision with blocks on the board
        boolean hitBlock = false;
        for (int i = 0; i < board.length; i++) {
            for (int j = 0; j < board[0].length; j++) {
                if (board[i][j] == 1 || board[i][j] ==  5) {
                    float blockX = i * gridSize;
                    float blockY = j * gridSize;
                    if (checkAABBCollision(this.winPos.X, this.winPos.Y, gridSize, gridSize, blockX, blockY, gridSize, gridSize)) {
                        hitBlock = true;
                        break;
                    }
                }
            }
            if (hitBlock) {
                break;
            }
        }
        
        //If the enemy hits a boundary or a block, turn counterclockwise
        if (hitBoundary || hitBlock) {
            if (hitBlock) {
                if (direction[0] > 0) this.winPos.X -= (this.winPos.X % gridSize);
                if (direction[1] > 0) this.winPos.Y -= (this.winPos.Y % gridSize);
                if (direction[0] < 0) this.winPos.X += (gridSize - (this.winPos.X % gridSize));
                if (direction[1] < 0) this.winPos.Y += (gridSize - (this.winPos.Y % gridSize));
            } //if(direction[0]>0){this.x-=(this.x%gridSize);}else {this.x+=(this.x%gridSize);}
            //if(direction[1]>0){this.y-=(this.y%gridSize);}else {this.y+=(this.y%gridSize);}
            turnCounterClockwise();
        }
    }
    
    
    void checkCollisionWithBlock() {
        if (isBlockMoving && checkAABBCollision(this.winPos.X, this.winPos.Y, gridSize, gridSize, movingBlockX, movingBlockY, gridSize, gridSize)) {
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
            if (this.direction[0] == -1)
                image(monsterstun,this.winPos.X,this.winPos.Y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
            else
                image(monsterstun_1,this.winPos.X,this.winPos.Y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
        }
        else if (this.direction[0] == -1)
            image(Enemyleft[Enemy_num],this.winPos.X,this.winPos.Y,Enemyleft[Enemy_num].width, Enemyleft[Enemy_num].height);
        else
            image(Enemyright[Enemy_num],this.winPos.X,this.winPos.Y,Enemyright[Enemy_num].width, Enemyright[Enemy_num].height);
        //ellipse(this.x+20, this.y+20, gridSize, gridSize);
    }
}


class Mirage extends Enemy {
    private float HIDE_CHANCE = random(0,1);
    private int MAX_HIDE_DURATION = 20;

    private boolean isHidden = false;
    private int hideCooldown = int(random(5,20));
    private int hideTimestamp = 0;
    private int lastHideTimestamp = 0;
    private int hidetime = int(random(2,5));
    private PImage blockType;

    Mirage(float x, float y, int speed, int score, String blockType) {
        super(x, y, speed, score);
        switch(blockType){
            case "brick":
                this.blockType = brickblock;
                break;
            case "stone":
            default:
                this.blockType = stoneblock;
                break;
        }
    }
    
    public void display() {
        if (this.isStunned) {
          PImage stunAnimation = this.direction[0] == -1 ? miragestun : miragestun_1;
          image(stunAnimation, this.winPos.X, this.winPos.Y, stunAnimation.width, stunAnimation.height);
          return;
        } 
        if(!this.isHidden){
          PImage mirageAnimation = this.direction[0] == -1 ? mirleft[mirage_num] : mirright[mirage_num];
          image(mirageAnimation, this.winPos.X, this.winPos.Y, mirageAnimation.width, mirageAnimation.height);
          return;
        }
        image(this.blockType, this.winPos.X, this.winPos.Y, gridSize, gridSize * 1.7);
    }
    
    private boolean checkHideStatus() {
        if (!this.isHidden) return false;
        if ((getTimestamp() - this.hideTimestamp) <= this.hidetime) return true;
        unhide();
        return false;
    }

    public void checkCollisionWithBlock() {
      if (isBlockMoving && checkAABBCollision(this.winPos.X, this.winPos.Y, gridSize, gridSize, movingBlockX, movingBlockY, gridSize, gridSize)) {
        if(!this.isHidden){
          this.isStunned = true;
        }else{
          isBlockMoving = false;
          board[this.currentPos.X][this.currentPos.Y] = 1;
        }
      }
    }
    
    public void move() {
        if (checkHideStatus() || this.isStunned){
            return;
        }
        if(!(this.isHidden)&&millis()-this.hideTimestamp > 3) hide();
        this.winPos.X += this.direction[0] * enemySpeed;
        this.winPos.Y += this.direction[1] * enemySpeed;
        // enemex = int(this.winPos.X / gridSize);
        // enemey = int(this.winPos.Y / gridSize);
        this.currentPos = this.winPos.toBoardPosition();
        if (board[this.lastPos.X][this.lastPos.Y] == 3) {
            board[this.lastPos.X][this.lastPos.Y] = 0;
        }
        lastPos = currentPos;
        if (board[this.currentPos.X][this.currentPos.Y] == 0) {
            board[this.currentPos.X][this.currentPos.Y] = 3;
        }
    }
    
    private void hide() {
	println("try to hide");
        if (this.isHidden) {
            return;
        }
	println("not hidden");
        if (random(0,1) > this.HIDE_CHANCE) {
            return;
        }
	println("greater than HIDE_CHANCE");
        if ((getTimestamp() - this.lastHideTimestamp) < this.hideCooldown) {
            println(getTimestamp());
	    println("lastTS: " + this.lastHideTimestamp);
            println("Cooldown: " + this.hideCooldown);
	    return;
        }
	println("not cooling down");
        //replace self with stone block here
        this.isHidden = true;
        this.hideTimestamp = getTimestamp();
        display();
    }
    
    private void unhide() {
        if (!isHidden ||  getTimestamp() - this.hideTimestamp<2) return;
        this.lastHideTimestamp = getTimestamp();
        this.isHidden = false;
        display();
        //deletes the stone block here
    }
}
