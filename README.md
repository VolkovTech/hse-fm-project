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

- 1 - represents the intersection
- 0 - represents the absence of intersection


| *   | 0   | 1   | 2   | 3   | 4   | 5   |
|-----|-----|-----|-----|-----|-----|-----|
| 0   | 0   | 1   | 1   | 1   | 1   | 1   |
| 1   | 1   | 0   | 0   | 1   | 1   | 0   |							
| 2   | 1   | 0   | 0   | 1   | 0   | 0   |							
| 3   | 1   | 1   | 1   | 0   | 0   | 1   |							 
| 4   | 1   | 1   | 0   | 0   | 0   | 1   |
| 5   | 1   | 0   | 0   | 1   | 1   | 0   |

Eventually, it can be represented as an array of `rules`:

```bash
int rules[LANES_NUM] =
{
    31, // 0: 011111
    38, // 1: 100110						
    36, // 2: 100100
    57, // 3: 111001
    49, // 4: 110001
    38  // 5: 100110 (crosswalk)
}
```

We then store the intersection state in an integer variable, with “1” representing green light, and “0” for red.


## Promela model

Our lights are controlled by a common process for the whole intersection, which synchronizes traffic lights using semaphores. Only one traffic light can change the intersection state at any point in time.

In our model we have several process types:
car_spawner is responsible for generating the cars on the lanes;
pedestrian_spawner is responsible for generating the pedestrians on the lanes;
traffic_light is a model of a single traffic light;
intersection_controller sends tokens to control synchronization channels to control the intersection. This controller allows instances of traffic_light proctype  to check the state of the intersection and change it if possible;
init process (single instance) is used to bootstrap the crossroads simulation.

The intersection_controller goes through all traffic_light processes granting them control, to one process at a time:



```bash
spin -search -m100000 -ltl safety traffic.pml
```

```

```

```bash
spin -search -m1000000 -ltl fairness traffic.pml
```

```bash
spin -search -m1000000 -ltl liveness traffic.pml
```