import gohai.glvideo.*;
import VLCJVideo.*;
import processing.video.*;
import ddf.minim.*;

// Sound parts
Minim minim;
AudioPlayer bgmPlayer, coinplayer,swallowplayer;
PImage stoneblock, brickblock, back_image;
PImage beginscr, statusbar;
PImage levelSelectImage, instrucImage;
PImage levelSelectScreen;
PImage[] Enemyleft = new PImage[10], Enemyright = new PImage[10], Playerleft = new PImage[10], Playerright = new PImage[10];
PImage[] Coin = new PImage[10];
PImage monsterstun;
PImage monsterstun_1;

// Game state variables
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
int facing = 1;
Boolean hasBlock = false;
Boolean showlevel = false;
boolean isBlockMoving = false;
float movingBlockX, movingBlockY;  // Current position of the moving block
float destBlockX, destBlockY;  // Destination position
float blockSpeed = 5;  // Speed at which the block moves (adjust as needed)
int stunnedDuration = 300;
int lastExecutedTime = 0;
int passTime = -1; // -1 indicates that the level has not been passed yet
int anitime = 0;
int statusbarh = 40;
int startgametime, mins;
int Enemy_num = 0, Coin_num = 0;

int movex[] = { - 1,0,1,0};
int movey[] = {0,1,0, -1};

int level = 0;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
color c = color(100, 101, 120);

boolean checkAABBCollision(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
    float leftx1, rightx1;
    float upy1, downy1;
    float leftx2, rightx2;
    float upy2, downy2;
    leftx1 = x1;
    rightx1 = x1 + w1;
    leftx2 = x2;
    rightx2 = x2 + w2;
    upy1 = y1;
    downy1 = y1 + h1;
    upy2 = y2;
    downy2 = y2 + h2;
    
    if (rightx1 <= leftx2 || rightx2 <= leftx1) return false;
    if (downy1 <= upy2 || upy1 >= downy2) return false;
    return true;
}

int getTimestamp() {
    return(millis() % 1000);
}

void loadlevel(int level) {
    overallscore = 0;
    if (level <= 0 || level > 6) {
        println("Invalid level " + level);
        return;
    }
    JSONObject json = loadJSONObject("map.json"); // Load the JSON file
    JSONObject levelData = json.getJSONObject("level" + str(level)); // Get data for level1
    if (levelData == null) {
        println("Invalid level " + level);
        return;
    } else {
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
                enemies.add(new Enemy(x, y, spd, sco));
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
    bgmPlayer.rewind();
    bgmPlayer.loop();
    isGameOver = false;
    if (level > 0) {
        
    }
    loadlevel(level);
}

void setup() {
    oldenglish = loadFont("BerlinSansFB-Bold-48.vlw");
    instrucImage = loadImage("Instructions.png");
    instrucImage.resize(600, 600);
    beginscr = loadImage("Begin_Screen.jpg");
    stoneblock = loadImage("block2.png");
    brickblock = loadImage("block1.png");
    statusbar = loadImage("statusbar.png");
    brickblock.resize(50, 78);
    levelSelectImage = loadImage("levelSelectImage.png"); // Replace with your level selection image file
    levelSelectImage.resize(600, 500); // Adjust size as needed
    back_image = loadImage("background.jpg");
    back_image.resize(1000, 840);
    monsterstun = loadImage("monster_stunned.png");
    monsterstun_1 = loadImage("monster_stunned_1.png");
    monsterstun.resize(gridSize, gridSize);
    monsterstun_1.resize(gridSize, gridSize);
    
    for (int i = 0; i < 7; i++) {
        String s = "monster" + str(i + 1);
        String s2 = s;
        s += ".png";
        s2 += "-1.png";
        Enemyleft[i] = loadImage(s);
        Enemyright[i] = loadImage(s2);
        Enemyleft[i].resize(gridSize, gridSize);
        Enemyright[i].resize(gridSize, gridSize);
    }
    
    for (int i = 0; i < 7; i++) {
        String s = "player" + str(i + 1);
        String s2 = s;
        s += ".png";
        s2 += "-1.png";
        Playerleft[i] = loadImage(s);
        Playerright[i] = loadImage(s2);
        Playerleft[i].resize(gridSize, gridSize);
        Playerright[i].resize(gridSize, gridSize);
    }
    
    for (int i = 0; i < 8; i++) {
        String s = "Coin_" + str(i + 1) + ".png";
        Coin[i] = loadImage(s);
        Coin[i].resize(gridSize, gridSize);
    }
    
    textAlign(CENTER, CENTER);
    textSize(64);
    
    //Initialize circles with random positions and colors
    for (int i = 0; i < 3 * numCircles; i++) {
        circlePositions[i] = new PVector(random(width), random(height));
        circleSizes[i] = random(10, maxDiameter);
        circleColors[i] = color(random(255), random(255), random(255), 200);
    }
    
    
    aboutButton = new Button(70, 730, 0.8, "about-1.png", "about-2.png", "about-3.png");
    volumeButton = new Button(760, 730, 0.8, "mute-1.png", "mute-2.png", "mute-3.png");
    quitButton = new Button(860, 50, 0.8, "quit-1.png", "quit-2.png", "quit-3.png");
    settingsButton = new Button(860, 730, 0.8, "settings-1.png", "settings-2.png", "settings-3.png");
    startButton = new Button(250, 730, 0.8, "start-1.png", "start-2.png", "start-3.png");
    
    minim = new Minim(this);
    bgmPlayer = minim.loadFile("BGM.mp3");
    bgmPlayer.setGain( -30);
    bgmPlayer.loop();
    coinplayer = minim.loadFile("gold_coin.wav");
    swallowplayer = minim.loadFile("Swallow.mp3");
    swallowplayer.setGain(30);
    
    statusbar.resize(1000, 40);
    size(1000, 840);
    beginscr.resize(1000, 840);
    background(beginscr);
}

void mouseClicked() {
    if (level == 0) { // in mainscreen
        if (showlevel) { // level select screen options
            if (mouseX > 230 && mouseX < 312 && mouseY > 410 && mouseY < 515) { // level 1 buttons
                level = 1; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
            if (mouseX > 325 && mouseX < 407 && mouseY > 410 && mouseY < 515) { // level 2 buttons
                level = 2; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
            if (mouseX > 415 && mouseX < 497 && mouseY > 410 && mouseY < 515) { // level 3 buttons
                level = 3; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
            if (mouseX > 505 && mouseX < 587 && mouseY > 410 && mouseY < 515) { // level 4 buttons
                level = 4; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
            if (mouseX > 595 && mouseX < 677 && mouseY > 410 && mouseY < 515) { // level 5 buttons
                level = 5; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
            if (mouseX > 685 && mouseX < 767 && mouseY > 410 && mouseY < 515) { // level 5 buttons
                level = 6; // or any other level you want to start
                setuplevel(); // Load the level and start the game
            }
        }
    }
}

void draw() {
    background(0);
    
    if (millis() - anitime > 100) {
        anitime = millis();
        Enemy_num++;
        Enemy_num %= 7;
        Coin_num++;
        Coin_num %= 8;
    }
    
    if (!animationDone) {
        drawCircles();
    } else if (animationDone && !titledone) {
        displayTitle();
    } else {
        if (level == 0) {
            background(beginscr);
            
            aboutButton.update();
            aboutButton.display();
            volumeButton.update();
            volumeButton.display();
            quitButton.update();
            quitButton.display();
            settingsButton.update();
            settingsButton.display();
            startButton.update();
            startButton.display();
            
            if (showlevel) {
                image(levelSelectImage, 200, 75);
            }
            
            if (showinstru) {
                image(instrucImage, 200, 75);
            }
        } else if (level >= 1 && level <= 6) {
            if (!levelPassed && !isGameOver) {
                background(back_image);
                
                // Draw the board
                for (int i = 0; i < board.length; i++) {
                    for (int j = 0; j < board[i].length; j++) {
                        if (board[i][j] == 1) {
                            image(stoneblock, i * gridSize, j * gridSize, gridSize * 1, gridSize * 1.7);
                        }
                        
                        if (board[i][j] == 2) {
                            if (facing == 1) {
                                image(Playerright[Enemy_num], i * gridSize, j * gridSize, gridSize, gridSize);
                            } else{
                                image(Playerleft[Enemy_num], i * gridSize, j * gridSize, gridSize, gridSize);
                            }
                        }
                        
                        if (board[i][j] == 5) {
                            image(brickblock, i * gridSize, j * gridSize, gridSize * 1, gridSize * 1.7);
                        }
                        
                        if (board[i][j] == 6) {
                            image(Coin[Coin_num], i * gridSize, j * gridSize, gridSize, gridSize);
                        }
                        // Add drawing logic for other entities
                    }
                }
                levelPassed = true;
                passTime = millis();
                for (Enemy enemy : enemies) {
                    if (!enemy.checkexist()) {
                        continue;
                    }
                    levelPassed = false;
                    enemy.checkBoundary();
                    enemy.move();
                    enemy.checkCollisionWithBlock();
                    enemy.update();
                    enemy.display();
                    
                    if (enemy.checkCollisionWithPlayer()) {
                        isGameOver = true;
                        passTime = millis();
                    }
                }
                
                if (isBlockMoving) {
                    movingBlockX += (destBlockX - movingBlockX) * blockSpeed * 0.01;
                    movingBlockY += (destBlockY - movingBlockY) * blockSpeed * 0.01;
                    
                    if (dist(movingBlockX, movingBlockY, destBlockX, destBlockY) < 1) {
                        isBlockMoving = false;
                        board[floor(destBlockX / gridSize)][floor(destBlockY / gridSize)] = 1;
                    }
                    
                    image(stoneblock, movingBlockX, movingBlockY, gridSize * 1, gridSize * 1.7);
                }
                
                image(statusbar, 0, 800);
                textSize(32);
                fill(40,200, 73);
                mins = (int)((millis() - startgametime) / 1000 / 60);
                int second = (int)((millis() - startgametime) / 1000) % 60;
                text(mins + " : " + second, 380, 815);
                text(overallscore, 800, 815);
            } else if (isGameOver) {
                fill(255);
                textSize(48);
                textAlign(CENTER, CENTER);
                text("Game Over you lose level " + level, width / 2, height / 2);
                
                if (millis() - passTime > 3000) {
                    levelPassed = false;
                    isGameOver = false;
                    level = 0;
                    setuplevel();
                }
            } else {
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

void keyPressed() {
    if (level == 0) return;
    int playerCellX = playerX / gridSize;
    int playerCellY = playerY / gridSize;
    
    if (keyCode == UP && dir != 0) dir = 0;
    else if (keyCode == RIGHT && dir != 1) { dir = 1; facing = 1; }
    else if (keyCode == DOWN && dir != 2) dir = 2;
    else if (keyCode == LEFT && dir != 3) { dir = 3; facing = 3; }
    else {
        if (keyCode == UP && playerY > 0 && board[playerCellX][playerCellY - 1] != 1 && board[playerCellX][playerCellY - 1] != 5) {
            if (board[playerCellX][playerCellY - 1] == 6) {
                board[playerCellX][playerCellY - 1] = 0;
                overallscore += 10;
                coinplayer.rewind();
                coinplayer.play();
            }
            playerY -= gridSize;
            dir = 0;
        }
        
        if (keyCode == DOWN && playerY < height - gridSize - statusbarh && board[playerCellX][playerCellY + 1] != 1 && board[playerCellX][playerCellY + 1] != 5) {
            if (board[playerCellX][playerCellY + 1] == 6) {
                board[playerCellX][playerCellY + 1] = 0;
                overallscore += 10;
                coinplayer.rewind();
                coinplayer.play();
            }
            playerY += gridSize;
            dir = 2;
        }
        
        if (keyCode == LEFT && playerX > 0 && board[playerCellX - 1][playerCellY] != 1 && board[playerCellX - 1][playerCellY] != 5) {
            if (board[playerCellX - 1][playerCellY] == 6) {
                board[playerCellX - 1][playerCellY] = 0;
                overallscore += 10;
                coinplayer.rewind();
                coinplayer.play();
            }
            playerX -= gridSize;
            dir = 3;
            facing = 3;
        }
        
        if (keyCode == RIGHT && playerX < width - gridSize && board[playerCellX + 1][playerCellY] != 1 && board[playerCellX + 1][playerCellY] != 5) {
            if (board[playerCellX + 1][playerCellY] == 6) {
                board[playerCellX + 1][playerCellY] = 0;
                overallscore += 10;
                coinplayer.rewind();
                coinplayer.play();
            }
            playerX += gridSize;
            dir = 1;
            facing = 1;
        }
    }
    
    if (keyCode == 32 || key == ' ') {
        if (hasBlock && !isBlockMoving) {
            int nextCellX = playerCellX + movey[dir];
            int nextCellY = playerCellY + movex[dir];
            
            while(nextCellX >= 0 && nextCellX < board.length && 
                nextCellY >= 0 && nextCellY < board[0].length && 
                board[nextCellX][nextCellY] != 1 && board[nextCellX][nextCellY] != 5) {
                nextCellX += movey[dir];
                nextCellY += movex[dir];
            }
            
            if (nextCellX - movey[dir] >= 0 && nextCellX - movey[dir] < board.length && 
                nextCellY - movex[dir] >= 0 && nextCellY - movex[dir] < board[0].length) {
                isBlockMoving = true;
                hasBlock = false;
                
                movingBlockX = playerX;
                movingBlockY = playerY;
                destBlockX = (nextCellX - movey[dir]) * gridSize;
                destBlockY = (nextCellY - movex[dir]) * gridSize;
            }
        } else if (!hasBlock) {
            int checkX = playerCellX + movey[dir];
            int checkY = playerCellY + movex[dir];
            
            if (checkX >= 0 && checkX < board.length && checkY >= 0 && checkY < board[0].length) {
                if (board[checkX][checkY] == 1) {
                    hasBlock = true;
                    board[checkX][checkY] = 0;
                } else {
                    for (int i = 0; i < enemies.size(); i++) {
                        Enemy monster = enemies.get(i);
                        int mx = Math.round(monster.x / gridSize);
                        int my = Math.round(monster.y / gridSize);
                        
                        if (mx == checkX && my == checkY && monster.exist&&monster.checkstun()) {
                            overallscore += monster.getscore();
                            swallowplayer.rewind();
                            swallowplayer.play();
                            monster.exist = false;
                            board[checkX][checkY] = 0;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    board[playerCellX][playerCellY] = 0;
    board[playerX / gridSize][playerY / gridSize] = 2;
}
