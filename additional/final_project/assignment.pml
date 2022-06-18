// Group 2: D. Maximenko, M. Shmakov, A. Mohenu
 
// Lanes:
// 0-2: E
// 3-5: S
// 6-8: W
// 9-11: N
// 12: P (pedestrian crossing)
#define NUM_LANES_TOTAL 13
#define LAST_CAR_LANE 11
 
int state = 0;
// Ah, if only Promela had binary literals...
int conditions[NUM_LANES_TOTAL] =
{
    4096, // Lane  0: 1 000 000 000 000, intersects 12
    7440, // Lane  1: 1 110 100 010 000, intersects 4, 8, 10, 11, 12
    6320, // Lane  2: 1 100 010 110 000, intersects 4, 5, 7, 11, 12
    4096, // Lane  3: 1 000 000 000 000, intersects 12
    2182, // Lane  4: 0 000 000 000 110, intersects 1, 2, 7, 11
    1412, // Lane  5: 0 010 110 000 100, intersects 2, 7, 8, 10
    0,    // Lane  6: 0 000 000 000 000, no intersections
    5172, // Lane  7: 1 010 000 110 100, intersects 2, 4, 5, 10, 12
    3106, // Lane  8: 0 110 000 100 010, intersects 1, 5, 10, 11
    0,    // Lane  9: 0 000 000 000 000, no intersections
    418,  // Lane 10: 0 000 110 100 010, intersects 1, 5, 7, 8
    4374, // Lane 11: 1 000 100 010 110, intersects 1, 2, 4, 8, 12
    2191  // Lane 12: 0 100 010 001 111, intersects 0, 1, 2, 3, 7, 11
}
 
// Number of lanes in subconfiguration
#define NUM_LANES_SIMULATED 6
// Array that defines this subconfiguration
int lanes_nums[NUM_LANES_SIMULATED] = { 1, 5, 7, 10, 11, 12 }
 
mtype:light = { RED, GREEN }
mtype:light lights_color[NUM_LANES_TOTAL] =
{
    RED, RED, RED, RED, RED, RED, RED,
    RED, RED, RED, RED, RED, RED
}
 
mtype:actor = { CAR, PED }
// Channels for generating traffic actors
// Lanes 0-11 for cars,
// Lane 12 for pedestrians
chan lanes[NUM_LANES_TOTAL] = [1] of { mtype:actor }
 
// Control synchronization channels
chan control_send[NUM_LANES_TOTAL] = [0] of { int }
chan control_return[NUM_LANES_TOTAL] = [0] of { int }
 
proctype car_spawner (int lane) {
    assert(lane <= LAST_CAR_LANE);
    do
    :: lanes[lane]!CAR;
    od;
}
 
proctype pedestrian_spawner (int lane) {
    assert(lane > LAST_CAR_LANE && lane <= NUM_LANES_TOTAL);
    do
    :: lanes[lane]!PED;
    od;
}
 
proctype traffic_light (int lane) {
    int control_token;
    mtype:actor traffic_actor;
    do
    /// Wait until can turn on
    ::  lanes[lane]?[traffic_actor];
        do
        ::  control_send[lane]?control_token;
            assert(control_token == lane);
            //printf("Lane %d checks state: %d against condition %d\n", lane, state, conditions[lane]);
            if
            ::  ((state & conditions[lane]) == 0) ->
                //printf("Lane %d will change state to %d\n", lane, state | 1 << lane);
                state = state ^ 1 << lane;
                lights_color[lane] = GREEN;
                printf("Lane %d is good to go\n", lane);
            ::  else -> skip;
            fi;
            control_return[lane]!lane;
            if
            ::  lights_color[lane] == GREEN -> break;
            ::  else ->
                printf("Lane %d: could not turn GREEN\n", lane);
                skip;
            fi;
        od;
 
        /// Light is green, let cars pass
        lanes[lane]?traffic_actor;
        printf("Lane %d: passes a car/ped\n", lane);
 
        // lanes[lane]?num_cars;
        // do
        // ::  num_cars > 0 ->
        //     num_cars--;
        //     printf("Lane %d: passes a car/ped\n", lane);
        // ::  else -> break;
        // od;
       
        // do
        // ::  lanes[lane]?[traffic_actor] ->
        //     lanes[lane]?traffic_actor;
        //     printf("Lane %d: passes a car/ped\n", lane);
        // ::  else -> break;
        // od;
 
        /// Turn off
        control_send[lane]?control_token;
        assert(control_token == lane);
        lights_color[lane] = RED;
        //printf("Lane %d will change state to %d\n", lane, state & !(1 << lane));
        state = state ^ 1 << lane;
        printf("Lane %d: stopped\n", lane);
        control_return[lane]!lane;
    od;
}
 
proctype intersection_controller () {
    int next_lane_idx = 0;
    int next_lane = 0;
    int control_token = 0;
 
    do
    ::  next_lane = lanes_nums[next_lane_idx];
        control_send[next_lane]!next_lane;
        control_return[next_lane]?control_token;
        assert(control_token == next_lane)
        next_lane_idx = (next_lane_idx + 1) % NUM_LANES_SIMULATED;
    od;
}
 
init {
    run intersection_controller();
    printf("Controller spawned\n");
 
    int new_lane_idx = 0;
    int new_lane = 0;
    do
    ::  new_lane_idx < NUM_LANES_SIMULATED ->
        new_lane = lanes_nums[new_lane_idx];
        if
        ::  new_lane <= LAST_CAR_LANE ->
            run car_spawner(new_lane);
            //printf("Lane %d: started car spawner\n", new_lane);
        ::  else ->
            run pedestrian_spawner(new_lane);
            //printf("Lane %d: started pedestrian spawner\n", new_lane);
        fi;
        run traffic_light(lanes_nums[new_lane_idx]);
        //printf("Lane %d: started traffic light\n", new_lane);
        new_lane_idx++;
    ::  else ->
        break;
    od;
    printf("All processes started\n");
}
 
// Lanes: { 1, 5, 7, 10, 11, 12 }
mtype:actor dummy_actor;
#define sense(n) (lanes[n]?[dummy_actor])
#define allowed(n) (lights_color[n] == GREEN)
 
#define fair(n) ([]<> !(sense(n) && allowed(n)))
#define unfair(n) (<>[] (sense(n) && allowed(n)))
ltl fairness { fair(1) && fair(5) && fair(7) && fair(10) && fair(11) && fair(12) };
 
ltl safety {[]!(allowed(1) && (allowed(10) || allowed(11)) ||
                allowed(5) && (allowed(7) || allowed(10)) ||
                allowed(7) && allowed(10) ||
                allowed(12) && (allowed(1) || allowed(7) || allowed(11))) };
 
#define liv(n) ([] ((sense(n) && !allowed(n)) -> <> allowed(n)))
ltl liveness { liv(1) && liv(5) && liv(7) && liv(10) && liv(11) && liv(12) };
 
// ltl flive { (fair(1) && fair(5) && fair(7) && fair(10) && fair(11) && fair(12)) ->
//             (liv(1) && liv(5) && liv(7) && liv(10) && liv(11) && liv(12)) };
 
// ltl flive1 { (fair(1)) -> (liv(1)) };
