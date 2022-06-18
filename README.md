# FM Project

### Andrey Volkov - Configuration 12

Successful completion of the homework assignment involves:
1. Constructing a corresponding Promela model;
2. Verifying the model in Spin with respect to safety, liveness and fairness
properties (the scheme described in Section 4, in your case the corresponding
properties can be specified differently).

### Configuration 12

![12](img/configuration-12.png)

### Configuration 12 (numbered lanes)

![12](img/numbers.jpg)

### Intersection matrix


| *   | 0   | 1   | 2   | 3   | 4   | 5   |
|-----|-----|-----|-----|-----|-----|-----|
| 0   | 0   | 1   | 1   | 1   | 1   | 1   |
| 1   | 1   | 0   | 0   | 1   | 1   | 0   |							
| 2   | 1   | 0   | 0   | 1   | 0   | 0   |							
| 3   | 1   | 1   | 1   | 0   | 0   | 1   |							 
| 4   | 1   | 1   | 0   | 0   | 0   | 1   |
| 5   | 1   | 0   | 0   | 1   | 1   | 0   |




```bash
spin -search -DNOREDUCE -m400000 -ltl safety traffic.pml

spin -search -DNOREDUCE -m1000000 -ltl fairness traffic.pml

spin -search -DNOREDUCE -m1000000 -ltl liveness traffic.pml
```