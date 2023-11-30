Button aboutButton;
Button volumeButton;
Button quitButton;
Button settingsButton;
Button startButton;

class Button {
    PImage idleImage;
    PImage hoverImage;
    PImage clickImage;
    float x, y, w, h;
    boolean isHovered = false;
    boolean isClicked = false;
    
    Button(float x, float y, float scale, String idlePath, String hoverPath, String clickPath) {
        this.x = x;
        this.y = y;
        
        idleImage = loadImage(idlePath);
        hoverImage = loadImage(hoverPath);
        clickImage = loadImage(clickPath);
        
        this.w = idleImage.width * scale;
        this.h = idleImage.height * scale;
    }
    
    void changeImg(String idlePath, String hoverPath, String clickPath) {
        idleImage = loadImage(idlePath);
        hoverImage = loadImage(hoverPath);
        clickImage = loadImage(clickPath);
    }
    
    void display() {
        if (isClicked) {
            image(clickImage, x, y, w, h);
        } else if (isHovered) {
            image(hoverImage, x, y, w, h);
        } else {
            image(idleImage, x, y, w, h);
        }
    }
    
    boolean isMouseOver() {
        return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
    }
    
    void update() {
        if (isMouseOver()) {
            isHovered = true;
        } else {
            isHovered = false;
        }
    }
    
    boolean mouseClicked() {
        if (isMouseOver()) {
            isClicked = true;
            return true;
        }
        return false;
    }
    
    void reset() {
        isClicked = false;
    }
}

void mousePressed() {
    if (aboutButton.mouseClicked()) {
        showAbout = !showAbout;
    }
    if (volumeButton.mouseClicked()) {
        if (!isMuted) {
            volumeButton.changeImg("unmute-1.png","unmute-2.png","unmute-3.png");
            bgmPlayer.setGain( -80);
        } else {
            volumeButton.changeImg("mute-1.png","mute-2.png","mute-3.png");
            bgmPlayer.setGain( -30);
        }
        isMuted = !isMuted;
    }
    if (quitButton.mouseClicked()) {
        exit();
    }
    if (settingsButton.mouseClicked()) {
        showinstru = !showinstru;
    }
    if (startButton.mouseClicked()) {
        showlevel = !showlevel;
    }
}

void mouseReleased() {
    aboutButton.reset();
    volumeButton.reset();
    quitButton.reset();
    settingsButton.reset();
    startButton.reset();
}