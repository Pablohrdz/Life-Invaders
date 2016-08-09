//Puzzle Representation:
//Written by
//Jorge Gaspar
//Fadime Bekmambetova


float boxSize = 38;
float extraSize = 6.5;

//Modify these parameters!
float spacing = 1.16;            //separates cubies to be able to see inside pieces clearly
float brightness = 160;         //0 -> dark          255-> super bright
float transparency = 255;       //0 -> transparent   255-> opaque
float dead_transparency = 120;
float stroke_transparency = 90; //makes edges disappear if 0

//Board
int[][] cells = new int[50][60];
int[][] backup;// = new int[cells.length][cells[0].length];


float depth = 300;
color boxFill;
PShape grid;

//movement:
boolean move = true;
float rotX = 0;
float rotY = 0;
float rotZ = 0;
float dispX = 0.001;
float dispY = 0.001;
float dispZ = 0.001;
float limitX = PI/32;
float limitY = PI/16;
float limitZ = PI/16;

//GoL:
int changeRate = 10; //frames until change (60fps)
int tempChRate = changeRate;
int framesElapsed = 0;
int alive = 10;
int comp_limit = 13;

//Space Invaders:
int fireRate = 10;
int lastFire = fireRate;
int deaths = 0;
int ship = cells.length/2;
int power = 2; //how many cells are destroyed by each shot
int bulletLength = 3;
boolean died = false;
int framesDead = 0;
int animationFrames = 120;


void setup() {
  //rand init:
  
  size(1200, 600, P3D); //1200, 600
  //fullScreen(P3D);
  frameRate(60);
  grid = createShape(GROUP);
  //backup = copyThis(cells);
  
  int n = 5;
  /*for(int i = 1; i<= 8; i++){
    cells[i + n][20] = alive+1;
  }
  for(int i = 10; i<= 14; i++){
    cells[i + n][20] = alive+1;
  }
  for(int i = 18; i<= 20; i++){
    cells[i + n][20] = alive+1;
  }
  for(int i = 27; i<= 33; i++){
    cells[i + n][20] = alive+1;
  }
  for(int i = 35; i<= 39; i++){
    cells[i + n][20] = alive+1;
  }
  for(int i = 1; i < cells.length; i++){
    cells[i][15] = alive;
  }*/
  
  randomCells();
  
  build();
}




void draw() {
  //background: 255 -> white, 0 -> black
  background(0);
  pushMatrix();
  
  
  //LE code
  framesElapsed++;
  lastFire++;
  GoL_rules();
  placeShip();
  if( !died )    build();
  else           destroy();
  
  
  //hint(ENABLE_DEPTH_SORT);
  if (mousePressed){
    int x = (int)map(mouseX, 0, width, cells.length - 1, 0);
    int y = (int)map(mouseY, 0, height, cells[0].length - 1, comp_limit);
    //spacing = map(mouseX, 0, width, 1, 4.5);
    //transparency = map(mouseY, 0, height, 50, 400);
    cells[x][y] = alive + 1;
    build();
  }
  
  if(move){
    rotX += dispX;
    rotY += dispY;
    rotZ += dispZ;
    if (rotX > limitX || rotX < -limitX)  dispX = -dispX;
    if (rotY > limitY || rotY < -limitY)  dispY = -dispY;
    if (rotZ > limitZ || rotZ < -limitZ)  dispZ = -dispZ;
  }
  // Center and spin grid
  translate(width/2, height/12, -depth*1.5*spacing);
  rotateY(rotY);
  rotateX(PI/4+rotX);
  rotateZ(rotZ);
  
  //Parameters of ambientLight can be set to 0 to get all
  //pieces in the puzzle to be different shades of blue, red, etc...
  ambientLight(brightness, brightness, brightness);
  directionalLight(100, 100, 100, 1, 0, 0);
  directionalLight(80, 80, 80, 0, 1, 0);
  directionalLight(60, 60, 60, 0, 0, 1);
  directionalLight(90, 90, 90, 0, 0, -1);
  directionalLight(70, 70, 70, 0, -1, 0);
  directionalLight(50, 50, 50, -1, 0, 0);

  shape(grid);
  popMatrix();
  
  if (keyPressed && !died){
    if (keyCode == LEFT){
      ship++;
      if (ship == cells.length) ship = 0;
    }else if (keyCode == RIGHT){
      ship--;
      if (ship < 0) ship = cells.length - 1;
    }
    if (keyCode == SHIFT && lastFire > fireRate){
      int x1 = (ship + 1)%(cells.length);
      int x2 = (ship - 1)%(cells.length - 1);
      if (x2 < 0) x2 = cells.length - 1;
      for(int i = 0; i < bulletLength; i++){
        cells[x1][5+i] = -power;
        cells[x2][5+i] = -power;
      }
      lastFire = 0;
    }
  }
}

void keyPressed(){
  if (key == 'm'){
    move = !move;
  }else if (key == 'p'){    //pause
    if(looping) noLoop();
    else        loop();
  }else if (key == '+'){    //higher generation rate
    changeRate++;
    println("New changeRate: " + changeRate);
  }else if (key == '-'){    //lower generation rate
    changeRate--;
    if (changeRate == 1) changeRate = 2;
    println("New changeRate: " + changeRate);
  }else if (key == 'r'){    //reset
    reset();
  }else if (key == 'a'){
    randomCells();
  }
}

void build(){
  grid = createShape(GROUP);
  // Build grid using multiple translations
  for (int i = 0; i < cells.length; i++){
    for (int j = 0; j < cells[0].length; j++){
   
      if(cells[i][j] >= alive){              //Live Cells
        stroke(0, stroke_transparency);
        boxFill = color(200, 10 + 180*(cells[i][j] - alive), 0, transparency);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize + extraSize, boxSize + extraSize, boxSize + extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else if(cells[i][j] >= 0){ //show empty cubies
        noStroke();
        if(cells[i][j] != 0){
          boxFill = color(80, 180, 255, dead_transparency*cells[i][j]/alive);
          fill(boxFill);
        }else{
          noFill();
        }
        PShape cube = createShape(BOX, boxSize*cells[i][j]/alive, boxSize*cells[i][j]/alive, boxSize*cells[i][j]/alive);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else if (cells[i][j] == -1 - power){    //Ship
        stroke(100, stroke_transparency);
        boxFill = color(255, 255);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize + extraSize, boxSize + extraSize, boxSize + extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else{                   //bullets
        noStroke();
        boxFill = color(80, 255, 80, -dead_transparency*cells[i][j]/power);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize - extraSize, boxSize - extraSize, boxSize - extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
      }
    }
  }
  
  //Line that separates computer from player
  for(int i = 0; i < cells.length; i++){
    stroke(120, 180, 80, 255);
    noFill();
    PShape cube = createShape(BOX, boxSize, boxSize, boxSize);
    cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - comp_limit)*boxSize*spacing, 0);
    grid.addChild(cube);
  }
  
  grid.scale(max(width, height)/(max(cells.length, cells[0].length)*boxSize));
}

void GoL_rules(){
  backup = copyThis(cells);
  for (int i = 0; i < cells.length; i ++){
    for (int j = cells[0].length - 1; j > 0; j--){
      if( cells[i][j - 1] < 0 && cells[i][j - 1] >= -power){ //bullets underneath
        if(cells[i][j] >= alive){  backup[i][j] = cells[i][j - 1] + 1; println(backup[i][j]);}  //kill cell and reduce power
        else        {backup[i][j] = cells[i][j - 1];        println(backup[i][j]);}           //move bullet upwards
        backup[i][j - 1] = 0;
        if (j == cells[0].length - 1) backup[i][j] = 0;
      }
      
      
      if (framesElapsed >= changeRate){
        //Conway's Game of Life Rules:
        int a_living = adjacentLiving(i, j);      
        if (cells[i][j] >= alive){
          if(a_living == 2 || a_living == 3)       backup[i][j] = alive;
          else                                     backup[i][j] = alive - 1;
        }else{
          if(a_living == 3){
            backup[i][j] = alive;
            if (cells[i][j] == -power - 1){    //if we hit the spaceship
              dead();
            }
          }
          else if (backup[i][j] > 0)    backup[i][j]--; // >0, not !=0
        }
      }
    }
  }
  if (framesElapsed >= changeRate) framesElapsed = 0;
  cells = copyThis(backup);
}

void placeShip(){
  for(int i = 0 ; i < cells.length; i ++){
    for (int j = 0; j < 6; j++){
      if (cells[i][j] == -power - 1)  cells[i][j] = 0;
    }
  }
  for (int i = 0; i < 4; i ++){
    for (int j = -i; j <= i; j++){
      int x = (ship + j)%cells.length;
      if (x < 0)        x = cells.length -1;
      if (cells[x][5-1] < alive)  cells[x][5 - i] = - power - 1;
      else  dead();    //We moved onto a living cell
    }
  }
}

int adjacentLiving(int x, int y){
  int count = 0;
  for (int i = x - 1; i <= x + 1; i++){
    if(i >= 0 && i < cells.length - 1){
      for (int j = y - 1; j <= y + 1; j++){
        if(j >= 0 && j < cells[0].length - 1){
          if(cells[i][j] >= alive)   count++;
        }
      }
    }
  }
  if(cells[x][y] >= alive)   count--;
  return count;
}

void reset(){
  cells = new int[cells.length][cells[0].length];
}

void dead(){
  if (!died)   tempChRate = changeRate;
  died = true;
  changeRate = 1;
}

void destroy(){
  grid = createShape(GROUP);
  framesDead++;
  // Build grid using multiple translations
  for (int i = 0; i < cells.length; i++){
    for (int j = 0; j < cells[0].length; j++){
        
      if(cells[i][j] >= alive){              //Live cells
        stroke(2*framesDead, 255);
        boxFill = color(200, 0, 0, transparency - framesDead*2);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize + extraSize, boxSize + extraSize, boxSize + extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else if(cells[i][j] >= 0){            //show empty cubies
        noStroke();
        if(cells[i][j] != 0){
          boxFill = color(80, 180, 255, dead_transparency*cells[i][j]/alive - framesDead*2);
          fill(boxFill);
        }else{
          noFill();
        }
        PShape cube = createShape(BOX, boxSize*cells[i][j]/alive, boxSize*cells[i][j]/alive, boxSize*cells[i][j]/alive);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else if (cells[i][j] == -1 - power){    //Ship
        stroke(120 + framesDead, framesDead*3);
        boxFill = color(200 - framesDead/3, 200 - 2*framesDead, 200 - 2*framesDead, transparency - framesDead*2);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize + extraSize, boxSize + extraSize, boxSize + extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
        
      }else{ //bullets
        noStroke();
        boxFill = color(80, 255, 80, -dead_transparency*cells[i][j]/power);
        fill(boxFill);
        PShape cube = createShape(BOX, boxSize - extraSize, boxSize - extraSize, boxSize - extraSize);
        cube.translate((cells.length/2 - i)*boxSize*spacing, (cells[0].length/2 - j)*boxSize*spacing, 0);
        grid.addChild(cube);
      }
    }
  }
  grid.scale((1 + 3*framesDead/animationFrames)*max(width, height)/(max(cells.length, cells[0].length)*boxSize));
  if(framesDead == animationFrames){
    changeRate = tempChRate;
    reset();
    died = false;
    framesDead = 0;
  }
}

void randomCells(){
  for (int i = 0; i < cells.length; i++){
    for (int j = comp_limit; j < cells[0].length; j++){
      cells[i][j] = (int)random(alive + 2);
    }
  }
}

int[][] copyThis(int[][] array1){
  int[][] array2 = new int[array1.length][array1[0].length];
  for(int i = 0; i < array1.length; i ++){
    for(int j = 0; j < array1[0].length; j++){
      array2[i][j] = array1[i][j];
    }
  }
  
  return array2;
}