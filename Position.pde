class Position {
    public int X;
    public int Y;
    
    Position(int x, int y) {
        this.X = x;
        this.Y = y;
    }
}

class WindowsPosition extends Position {
    WindowsPosition(int x, int y) {
        super(x, y);
    }
    
    public BoardPosition toBoardPosition() {
        return new BoardPosition(int(X / gridSize), int(Y / gridSize));
    }
}

class BoardPosition extends Position{
    BoardPosition(int x, int y) {
        super(x, y);
    }
}