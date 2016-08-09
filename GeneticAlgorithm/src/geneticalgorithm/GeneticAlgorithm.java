/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package geneticalgorithm;

import java.util.*;

/**
 *
 * @author administrador
 */
public class GeneticAlgorithm {
    private static final int TIMESTEP_GOL = 45;

    class Individuo
    {
        //ArrayList<String> parametros = new ArrayList<String>();
        StringBuffer celulas;
        int fitnessValue = 0;
    }

    void printPopulation(ArrayList<Individuo> population)
    {

    }
//MUTACIONES
    boolean huboMutacion = false;

     void runAlgo()
     {
        int n = 20, iteraciones = 1000000, parametros = GoL.WIDTH * GoL.HEIGHT;

        Individuo[] population = new Individuo[n];
        generateRandomPopulation(n, parametros, population);

        //printPopulation(population);

        //Ejecutar el algoritmo genético
        for (int k = 0; k < iteraciones; k++) {

            evaluatePopulationFitness(population);

            generateNextPopulation(population);
            
            if(k % 500 == 0)        System.out.println("Iteración #" + k);
        }

        evaluatePopulationFitness(population);

        int index = 0, max = 0;

        //Encontrar el máximo de la población
        for (int i = 0; i < population.length; i++) {
            if (max < (population[i].fitnessValue)) {
                max = population[i].fitnessValue;
                index = i;
            }
        }

        System.out.println("Los valores encontrados que maximizan a la función son: ");

        for (int i = 0; i < population.length; i++)
        {
            System.out.println("*******************************INDIVIDUO #" + i + "  *******************************");
            //System.out.println(bin2dec((population[index].parametros).get(i)));
            decode(population[i]).printGrid();
        }


    }

    /* Método que genera una nueva población de tamaño n, con x parámetros para la función*/
     void generateRandomPopulation(int n, int x, Individuo[] population)
    {
	for (int i = 0; i < n; i++) {
            Individuo  ind = new Individuo();
            
            StringBuffer buff = new StringBuffer();
            
            for (int j = 0; j < x; j++) 
            {
                if(j < .75 * x)
                {
                    if(Math.random() < .35)
                    {
                        buff.append('1');
                    }
                    else
                    {
                        buff.append('0');
                    }
                }
                else
                {
                    buff.append('0');
                }
                //Generar un número aleatorio en el intervalo [0, n] y pasarlo a string binario
                //(ind.parametros).add(dec2bin((int) (Math.random() * n)));
            }
            ind.celulas = buff;
            population[i] = ind;
        }

    }

    /* Método que evalúa la adecuación de toda la población */
    void evaluatePopulationFitness(Individuo[] population)
    {
	for (int i = 0; i < population.length; i++)
        {
            population[i].fitnessValue = objectiveFunction(decode(population[i]));
        }
    }

    /* Método que decodifica los cromosomas (parámetros) de un individuo. 
     Regresa un vector de enteros, con los valores numéricos de cada uno. */

    //Las dimensiones del grid y del string (45 * 40) deben ser las mismas
    GoL decode(Individuo individuo)
    {
        GoL life = new GoL();
        
        for(int i = 0, k = 0; i < life.cells.length; i++)
        {
            for(int j = 0; j < life.cells[0].length - 1; j++, k++)
            {
                boolean alive = false;
                
                if(individuo.celulas.charAt(k) == '1')      alive = true;
                
                life.cells[i][j] = alive;
            }
        }
        
        return life;
    }

    /* Función objetivo, que también funciona como fitness function, en este caso.
     Los constraints son booleanos, los cuales tienen un valor de 1 si la condición se cumple, y 0, si no.
     Todos los valores booleanos se multiplican por el valor de la función objetivo. Si todos son 1 (todas las restricciones se cumplen),
     el valor es superior a 0. Si algún constraint NO se cumple, el resultado de la evaluación es 0. */
    int objectiveFunction(GoL life)
    {
        life.timestep_update(TIMESTEP_GOL);
        
        int z = life.liveCells + life.totalAvgDistance;
        
        return z;
    }


    /* Método de cruza (relación binaria) 
     Este método utiliza memoria del heap, por lo que liberarla es responsabilidad de quien la llame. */
    void generateNextPopulation(Individuo[] population)
{
	double[] accumFitness = new double[population.length];

	int totalFitness = 0;

        //Obtener fitness total de la población
        for (int i = 0; i < population.length; i++) 
        {
            totalFitness += (population[i].fitnessValue);
        }

        //cout << "Fitness obtenido" << endl;

        //Obtener acumulación de probabilidad
        accumFitness[0] = (population[0].fitnessValue) / (totalFitness * 1.0);

        for (int i = 1; i < population.length; i++) 
        {
            accumFitness[i] = ((population[i].fitnessValue) / (totalFitness * 1.0)) + accumFitness[i - 1];
        }

        //cout << "Probab acumulada lista" << endl;

        ArrayList<Integer> parents = new ArrayList<Integer>();

        //Seleccionar a los padres
        for (int i = 0; i < population.length * 2; i++) {
            //Número aleatorio con precisión de 6 dígitos
            double random = (Math.random() * 1000000) / 1000000;
            
            int maxIndex = 0;
            
            //Posición del padre
            for(int j = 0; j < accumFitness.length; j++)
            {
                if(accumFitness[j] >= random)   
                {
                    maxIndex = j;
                    break;
                }
            }
            
            parents.add(maxIndex);
        }

        //cout << "Padres seleccionados. Tamaño de vector padres: " << parents.size() << endl;

        ArrayList<Individuo> newPopulation = new ArrayList<Individuo>();

	//int parameters = (population[0].parametros).size();
        
        //Cruzar a 2 individuos
        for (int i = 0; i < parents.size(); i += 2) {
            Individuo padre =  population[parents.get(i)];
            //cout << "padre" << endl;
            Individuo madre =  population[parents.get(i + 1)];
            //cout << "madre" << endl;
            Individuo hijo = new Individuo();

            //cout << "hijo" << endl;
            hijo.celulas = mate(padre.celulas, madre.celulas);
            /*
            //Cruzar cada uno de sus parámetros
            for (int j = 0; j < parameters; j++)
            {
                //cout << j << endl;
                (hijo.parametros).add(mate((padre.parametros).get(j), (madre.parametros).get(j)));
            }
            */

            //newPopulation.push_back(hijo);
            newPopulation.add(hijo);
        }

        //cout << "Caro" << endl;


        for (int i = 0; i < newPopulation.size(); i++) 
        {
            population[i] = newPopulation.get(i);
            //cout << population[i] << endl;
        }

    }


    /* Método para cruzar a dos cromosomas.
     Los puntos de corte son aleatorios para ambos cromosomas, de modo que puedan salir strings más largos
     que los de la población inicial. Se realiza una partición en el primer string y se itera desde 0 hasta la partición. 
     Posteriormente, se realiza otra partición para el segundo string, pero se itera desde esa partición hasta el final de éste.
     Ambas partes se pegan y generan al nuevo cromosoma. */
    StringBuffer mate(StringBuffer s1, StringBuffer s2) {
        //Con los +1 y -1 te aseguras de que el punto de partición esté después del primer elemento o uno antes del último.
        int partitionPoint1 = (int)(Math.random() * (s1.length() - 1));
        //int partitionPoint2 = (int)(Math.random() * (s2.length() - 1));
        
        //if(partitionPoint1 == 0)                    partitionPoint1 = 1;
        //if(partitionPoint2 == s2.length() - 1)      partitionPoint1 = s2.length() - 2;
        
        StringBuffer result = new StringBuffer();

        //Mutación con probabilidad de 0.002


        for (int i = 0; i < partitionPoint1; i++) {
            result.append(s1.charAt(i));
        }

        for (int i = partitionPoint1; i < s2.length(); i++) {
            result.append(s2.charAt(i));
        }

        int mutacion = (int)(Math.random() * 1000);

        if (mutacion <= 2) {
            //string resMutado = "";

            int genMutado = (int)(Math.random() * result.length() - 1);

            huboMutacion = true;
         
            
            if (result.charAt(genMutado) == '0')
            {
                result.setCharAt(genMutado, '1');
            } else
            {
                result.setCharAt(genMutado, '0');
            }
        }

        return result;
    }

    /* Método para pasar de decimal a binario */
    String dec2bin(int dec) {
        String bin = "";


        while (dec > 0) {
            bin = (dec % 2) + bin;
            dec /= 2;
            //cout << "sfasdf"<< endl;
        }

        return bin;
    }

    /* Método para pasar de binario a decimal */
    int bin2dec(String binary) {
        int dec = 0;

        for (int i = binary.length() - 1; i >= 0; i--) {
            if (binary.charAt(i) == '1') {
                dec += (1 << i);
            }
        }

        return dec;
    }
}
