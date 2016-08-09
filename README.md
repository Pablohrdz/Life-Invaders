# Life-Invaders
This is a crossover of the popular Game of Life and the arcade classic Space Invaders. Its purpose is to explore the implementation of genetic algorithms to generate random enemies in a way that makes the game more challenging than the original version, as well as more interactive and ultimately, more fun.

The user controls the spaceship and the aliens of the original game are repalced with Game of Life cells that evolve according to the game's rules. If any of these cells touch the player, the game ends, but the player can shoot these and kill them. The player wins when every cell is taken care of.

The genetic algorithm code is in a java source file, and the game itself is a Processing project. As of right now, one runs the genetic algorithm separately from the game, as a preprocessing step (since it's a very long process), and includes the results manually in the .pde file.
