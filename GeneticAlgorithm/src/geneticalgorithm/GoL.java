/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package geneticalgorithm;

/**
 *
 * @author administrador
 */
public class GoL {
    public static final int WIDTH = 45;
    public static final int HEIGHT = 40;
    
    boolean[][] cells = new boolean[WIDTH][HEIGHT];
    int totalAvgDistance = 0, minManhattan = 0, liveCells = 0;
    
    //Generar 1500 ejemplos aleatoriamente
    //Entrenar red con eso, en cada timestep
     
    //'n' es el número de timesteps
    void timestep_update(int N) 
    {
        liveCells = 0;
        totalAvgDistance = 0;
        //minManhattan = cells.length + cells[0].length;
        
        for(int n = 0; n < N; n++)
        {
        
            boolean[][] newCells = new boolean[WIDTH][HEIGHT];

            for(int i = 0; i < cells.length; i++)
            {
                for(int j = cells[0].length - 1; j > 0; j--)
                {
                    int a_living = adjacentLiving(i, j);

                    if(cells[i][j] == true)
                    {
                        if (a_living == 2 || a_living == 3) 
                        {
                            newCells[i][j] = true;
                            liveCells++;

                            //Calcular dist hacia abajo
                            totalAvgDistance += Math.abs(cells.length - i);

                        }
                        else
                        {
                            newCells[i][j] = false;
                            
                            //Calcular dist hacia abajo
                            //totalAvgDistance += Math.abs(cells.length - i);
                        }
                    }
                    else
                    {
                        if(a_living == 3)
                        {
                            newCells[i][j] = true;
                            totalAvgDistance += Math.abs(cells.length - i);
                            liveCells++;
                        }

                    }

                }
            }

            cells = newCells;
        }
        
        totalAvgDistance /= liveCells;
    }
    
    
    int adjacentLiving(int x, int y) 
    {
        int count = 0;
        for (int i = x - 1; i <= x + 1; i++) {
            int ic = i;
            if (i < 0) {
                ic = cells.length + i;
            } else if (i >= cells.length) {
                ic = i - cells.length;
            }
            for (int j = y - 1; j <= y + 1; j++) {
                if (j >= 0 && j < cells[0].length - 1) {
                    if (cells[ic][j] == true) {
                        count++;
                    }
                }
            }
        }
        if (cells[x][y] == true) {
            count--;
        }
        return count;
    }
    
    void printGrid()
    {
        System.out.println("PRINTING...");
        for(int i = 0; i < cells.length; i++)
        {
            for(int j = 0; j < cells[i].length; j++)
            {
                if(cells[i][j] == true)     System.out.print("1 ");
                else                        System.out.print("0 ");
            }
            
            System.out.println();
        }
        System.out.println("Avg dist -> " + totalAvgDistance);
        System.out.println("Total cells that lived -> " + liveCells);
        System.out.println("FIN PRINT");
    }
    
}
