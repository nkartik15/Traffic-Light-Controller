# 🚦 Traffic Light Controller

> A two-road traffic light FSM in Verilog — smart enough to skip the green light for an empty street.

A single always-block finite state machine that manages two intersecting roads with vehicle-sensor inputs, so a road doesn't get its green light "wasted" if nothing's there.

---

## 🗂️ What's Inside

```
traffic_light_controller.v   – The FSM (single module: traffic_light)
testbench.v                  – Clocked testbench that walks through every traffic scenario
```

Just two files, one clean design — no fluff.

---

## 🔧 How It Works

**Inputs**
- `clk` — system clock
- `Sa`, `Sb` — vehicle-present sensors for Road A and Road B

**Outputs**
- `Ra/Ga/Ya` — Red / Green / Yellow for Road A
- `Rb/Gb/Yb` — Red / Green / Yellow for Road B

**The FSM (13 states, `state[3:0]`):**

| States | Behavior |
|---|---|
| 0–4 | Road A green, Road B red — fixed 5-cycle minimum green time |
| 5 | Hold Road A green, **wait** until a vehicle shows up on Road B (`Sb == 1`) |
| 6 | Road A goes yellow (Road B still red) |
| 7–10 | Road B green, Road A red — fixed 4-cycle minimum green time |
| 11 | Hold Road B green, **wait** until Road A has traffic or Road B clears out |
| 12 | Road B goes yellow (Road A still red) → loops back to state 0 |

The clever bit is states 5 and 11: rather than cycling through green/yellow/red on a rigid timer regardless of traffic, the controller parks in a holding state and only advances once a sensor condition is met — giving Road A/B green time proportional to actual demand instead of blind round-robin timing.

A small combinational block re-derives a 2-bit `lightA`/`lightB` encoding (`R`/`Y`/`G`) from the individual output flags, mostly as a tidy internal representation of "what color is this road showing right now."

---

## 🧪 The Testbench

`testbench.v` drives the DUT through a full story arc:

1. No traffic on either road (baseline cycling)
2. A vehicle arrives on Road B → triggers the A→B switch
3. Vehicle leaves Road B
4. A vehicle arrives on Road A → triggers the B→A switch
5. Vehicle leaves Road A
6. Vehicles on **both** roads simultaneously
7. Sensors cleared

A `$monitor` call prints a live table of `State | Sa Sb | RA YA GA | RB YB GB` on every change, so you can watch the FSM react to traffic in real time in the simulator log.

---

## 💡 Notes

- This is a **Mealy-ish/Moore hybrid** in spirit — outputs are assigned per-state (Moore-style) but the *next-state* logic reacts directly to sensor inputs, which is what gives it the demand-responsive behavior.
- No all-red safety interval between yellow and the opposite road's green — worth adding if this were headed toward a real intersection rather than a class/portfolio project.
