
#import "@local/mantys:1.0.0": *

#import "../src/finite.typ" as finite: cetz

#import "../src/util.typ"

// Customize the show-module function
#let show-module(
  name,
  scope: (:),
  outlined: false,
  ..tidy-args,
) = tidy-module(
  name,
  read("../src/" + name + ".typ"),
  show-outline: outlined,
  // include-examples-scope: true,
  // extract-headings: 3,
  ..tidy-args
)

// Nice display of CeTZ commands
#show "CETZ": a => package[CeTZ]
#let cetz-cmd = cmd.with(module: "cetz")
#let cetz-cmd- = cmd-.with(module: "cetz")
#let cetz-draw = cmd.with(module: "cetz.draw")
#let cetz-draw- = cmd-.with(module: "cetz.draw")

#show: mantys(
  ..toml("../typst.toml"),

  title: align(
    center,
    finite.automaton(
      (
        q0: (q1: none),
        q1: (q2: none),
        q2: (q3: none),
        q3: (q4: none),
        q4: (q5: none),
        q5: none,
      ),
      style: (
        q0: (label: "F", initial: ""),
        q1: (label: "I"),
        q2: (label: "N"),
        q3: (label: "I"),
        q4: (label: "T"),
        q5: (label: "E"),
        state: (label: (size: 20pt)),
      ),
    ),
  ),

  date: datetime.today(),
  abstract: [
    FINITE is a Typst package to draw transition diagrams for finite automata (finite state machines) with the power of CETZ.

    The package provides new elements for manually drawing states and transitions on any CETZ canvas, but also comes with commands to quickly create automata from a transition table.
  ],

  examples-scope: (
    scope: (
      cetz: cetz,
      finite: finite,
      util: util,
      automaton: finite.automaton,
    ),
  ),

  theme: themes.modern,
)

= Usage <sec:usage>

== Importing the package <subsec:importing>

Import the package in your Typst file:

#show-import(imports: "automaton")

== Manual installation <subsec:manual-install>

The package can be downloaded and saved into the system dependent local package repository.

Either download the current release from #github("jneug/typst-finite") and unpack the archive into your system dependent local repository folder#footnote[#std.link("https://github.com/typst/packages#local-packages")] or clone it directly:

#show-git-clone()

In either case, make sure the files are placed in a subfolder with the correct version number: #context document.use-value("package", (p) => raw(block:false, p.name + "/" + str(p.version)))

After installing the package, just import it inside your `typ` file:

#show-import(repository: "@local", imports: "automaton")

== Dependencies <subsec:dependencies>

FINITE loads #link("https://github.com/johannes-wolf/typst-canvas")[CETZ] and the utility package #link("https://github.com/jneug/typst-tools4typst")[#package[t4t]] from the `preview` package repository. The dependencies will be downloaded by Typst automatically on first compilation.

#custom-type("coordinate", color:silver)Whenever a #dtype("coordinate") type is referenced, a CETZ coordinate can be used. Please refer to the CETZ manual for further information on coordinate systems.

= Drawing automata <sec:drawing>

FINITE helps you draw transition diagrams for finite automata in your Typst documents, using the power of CETZ.

To draw an automaton, simply import #cmd[automaton] from FINITE and use it like this:
#example[```typ
  #automaton((
    q0: (q1:0, q0:"0,1"),
    q1: (q0:(0,1), q2:"0"),
    q2: none,
  ))
  ```]

As you can see, an automaton ist defined by a dictionary of dictionaries. The keys of the top-level dictionary are the names of states to draw. The second-level dictionaries have the names of connected states as keys and transition labels as values.

In the example above, the states `q0`, `q1` and `q2` are defined. `q0` is connected to `q1` and has a loop to itself. `q1` transitions to `q2` and back to `q0`. #cmd-[automaton] selected the first state in the dictionary (in this case `q0`) to be the Initial state and the last (`q2`) to be a final state.

See @aut-specs for more details on how to specify automata.

To modify how the transition diagram is displayed, #cmd-[automaton] accepts a set of options:
#example(breakable: true)[```typ
  #automaton(
    (
      q0: (q1:0, q0:"0,1"),
      q1: (q0:(0,1), q2:"0"),
      q2: (),
    ),
    initial: "q1",
    final: ("q0", "q2"),
    labels:(
      q2: "FIN"
    ),
    style:(
      state: (fill: luma(248), stroke:luma(120)),
      transition: (stroke: (dash:"dashed")),
      q0-q0: (anchor:top+left),
      q1: (initial:top),
      q1-q2: (stroke: 2pt + red)
    )
  )
  ```]

For larger automatons, the states can be arranged in different ways:
#example(breakable: true)[```typ
  #let aut = (:)
  #for i in range(10) {
    let name = "q"+str(i)
    aut.insert(name, (:))
    if i < 9 {
      aut.at(name).insert("q" + str(i + 1), none)
    }
  }
  #automaton(
    aut,
    layout: finite.layout.circular.with(offset: 45deg),
    style: (
      transition: (curve: 0),
      q0: (initial: top+left)
    )
  )
  ```]

See @using-layout for more details about layouts.

== Specifing finite automata <aut-specs>

Most of FINITEs commands expect a finite automaton specification ("spec" in short) as the first argument. These specifications are dictionaries defining the elements of the automaton.

If an automaton has only one final state, the spec can simply be a transition table. In other cases, the specification can explicitly define the various elements.


#custom-type("spec", color: rgb("#76d6ff"))
A specification (#dtype("spec")) can have these elements:
```typc
(
  transitions: (...),
  states: (...),
  inputs: (...),
  initial: "...",
  final: (...)
)
```

- `transitions` is a dictionary of dictionary in the format:
  ```typc
  (
    state1: (input1, input2, ...),
    state2: (input1, input2, ...),
    ...
  )
  ```
- `states` is an optional array with the names of all states. The keys of `transitions` are used by default.
- `inputs` is an optional array with all input values. The inputs found in `transitions` are used by default.
- `initial` is an optional name of the initial state. The first value in `states` is used by default.
- `final` is an optional array of final states. The last value in `states` is used by default.

The utility function #cmd(module:"util")[to-spec] can be used to create a full spec from a partial dictionary by filling in the missing values with the defaults.

== Command reference
#show-module("cmd")

== Styling the output

As common in CETZ, you can pass general styles for states and transitions to the #cetz-cmd-[set-style] function within a call to #cetz-cmd-[canvas]. The elements functions #cmd-[state] and #cmd-[transition] (see below) can take their respective styling options as arguments, to style individual elements.

#cmd[automaton] takes a #arg[style] argument that passes the given style to the above functions. The example below sets a background and stroke color for all states and draws transitions with a dashed style. Additionally, the state `q1` has the arrow indicating an initial state drawn from above instead from the left. The transition from `q1` to `q2` is highlighted in red.
#example(breakable: true)[```typ
  #automaton(
    (
      q0: (q1:0, q0:"0,1"),
      q1: (q0:(0,1), q2:"0"),
      q2: (),
    ),
    initial: "q1",
    final: ("q0", "q2"),
    style:(
      state: (fill: luma(248), stroke:luma(120)),
      transition: (stroke: (dash:"dashed")),
      q1: (initial:top),
      q1-q2: (stroke: 2pt + red)
    )
  )
  ```]

Every state can be accessed by its name and every transition is named with its initial and end state joined with a dash (`-`).

The supported styling options (and their defaults) are as follows:
- states:
  / #arg(fill: auto): Background fill for states.
  / #arg(stroke: auto): Stroke for state borders.
  / #arg(radius: .6): Radius of the states circle.
  - `label`:
    / #arg(text: auto): State label.
    / #arg(size: auto): Initial text size for the labels (will be modified to fit the label into the states circle).

- transitions
  / #arg(curve: 1.0): "Curviness" of transitions. Set to #value(0) to get straight lines.
  / #arg(stroke: auto): Stroke for transitions.
  - `label`:
    / #arg(text: ""): Transition label.
    / #arg(size: 1em): Size for label text.
    / #arg(color: auto): Color for label text.
    / #arg(pos: .5): Position on the transition, between #value(0) and #value(1). #value(0) sets the text at the start, #value(1) at the end of the transition.
    / #arg(dist: .33): Distance of the label from the transition.
    / #arg(angle: auto): Angle of the label text. #value(auto) will set the angle based on the transitions direction.

== Using #cmd-(module:"cetz")[canvas]

The above commands use custom CETZ elements to draw states and transitions. For complex automata, the functions in the #module[draw] module can be used inside a call to #cetz-cmd-[canvas].
#example(breakable: true)[```typ
  #cetz.canvas({
    import cetz.draw: set-style
    import finite.draw: state, transition

    state((0,0), "q0", initial:true)
    state((2,1), "q1")
    state((4,-1), "q2", final:true)
    state((rel:(0, -3), to:"q1.south"), "trap", label:"TRAP", anchor:"north-west")

    transition("q0", "q1", inputs:(0,1))
    transition("q1", "q2", inputs:(0))
    transition("q1", "trap", inputs:(1), curve:-1)
    transition("q2", "trap", inputs:(0,1))
    transition("trap", "trap", inputs:(0,1))
  })
  ```]

=== Element functions
#show-module("draw")

=== Anchors

States and transitions are created in a #cetz-draw[group]. States are drawn with a circle named `state` that can be referenced in the group. Additionally they have a content element named `label` and optionally a line named `initial`. These elements can be referenced inside the group and used as anchors for other CETZ elements. The anchors of `state` are also copied to the state group and are directly accessible.

Transitions have an `arrow` (#cetz-draw[line]) and `label` (#cetz-draw[content]) element. The anchors of `arrow` are copied to the group.

#example(breakable: true)[```typ
  #cetz.canvas({
    import cetz.draw: circle, line, content
    import finite.draw: state, transition

    state((0, 0), "q0")
    state((4, 0), "q1", final: true)

    transition("q0", "q1", label: $epsilon$)

    circle("q0.north-west", radius: .4em, stroke: none, fill: black)

    let magenta-stroke = 2pt + rgb("#dc41f1")
    circle("q0-q1.label.south", radius: .5em, stroke: magenta-stroke)
    line(
      name: "q0-arrow",
      (rel: (.6, .6), to: "q1.state.north-east"),
      (rel: (.1, .1), to: "q1.state.north-east"),
      stroke: magenta-stroke,
      mark: (end: ">"),
    )
    content(
      (rel: (0, .25), to: "q0-arrow.start"),
      text(fill: rgb("#dc41f1"), [*very important state*]),
    )
  })
  ``` ]

== Layouts <using-layout>

Layouts can be used to move states to new positions within a call to #cetz-cmd-[canvas]. They act #cetz-draw[group]s and have their own transform. Any other elements than states will keep their original coordinates, but be translated by the layout, if necessary.

FINITE ships with a bunch of layouts, to accomodate different scenarios.

=== Available layouts <available-layouts>
#show-module("layout", sort-functions: false)

=== Using layouts

Layouts are elements themselves. This means, they have a coordinate to be moved on the canvas and they can have anchors. Using layouts allows you to quickly create complex automata, without the need to pick each states coordinate by hand.
#example(breakable: true)[```typ
  #cetz.canvas({
    import cetz.draw: set-style
    import finite.draw: *

    set-style(state: (radius: .4))

    layout.grid(
      name: "grid",
      (0,0),
      columns:3, {
        set-style(state: (fill: green.lighten(80%)))
        for s in range(6) {
          state((), "a" + str(s))
        }
      })

    layout.linear(
      name: "line",
      (rel:(2,0), to:"grid.east"),
      dir: bottom, anchor: "center", {
        set-style(state: (fill: blue.lighten(80%)))
        for s in range(4) {
          state((), "b" + str(s))
        }
      })

    state((rel: (0, -1.4), to:"grid.south"), "TRAP", fill:red.lighten(80%), label:(size:8pt))

    transition("grid.a0", "TRAP", curve:-1)
    transition("line.b2", "TRAP")
    transition("grid.a5", "line.b0")
    transition("grid.a5", "line.b2", curve:-.2)
  })
  ```]


== Utility functions
#show-module("util", outlined: true)

== Doing other stuff with FINITE

Since transition diagrams are effectively graphs, FINITE could also be used to draw graph structures:
#example[```
  #cetz.canvas({
    import cetz.draw: set-style
    import finite.draw: state, transitions

    state((0,0), "A")
    state((3,1), "B")
    state((4,-2), "C")
    state((1,-3), "D")
    state((6,1), "E")

    transitions((
        A: (B: 1.2),
        B: (C: .5, E: 2.3),
        C: (B: .8, D: 1.4, E: 4.5),
        D: (A: 1.8),
        E: (:)
      ),
      C-E: (curve: -1.2))
  })
  ```]

= Showcase <sec:showcase>

#example[```typ
  #scale(80%, automaton((
      q0: (q1: 0, q2: 0),
      q2: (q3: 1, q4: 0),
      q4: (q2: 0, q5: 0, q6: 0),
      q6: (q7: 1),
      q1: (q3: 1, q4: 0),
      q3: (q1: 1, q5: 1, q6: 1),
      q5: (q7: 1),
      q7: ()
    ),
    layout: finite.layout.group.with(grouping: (
        ("q0",),
        ("q1", "q2", "q3", "q4", "q5", "q6"),
        ("q7",)
      ),
      spacing: 2,
      layout: (
        finite.layout.linear,
        finite.layout.grid.with(columns:3, spacing:2.6),
        finite.layout.linear
      )
    ),
    style: (
      transition: (curve: 0),
      q1-q3: (curve:1),
      q3-q1: (curve:1),
      q2-q4: (curve:1),
      q4-q2: (curve:1),
      q1-q4: (label: (pos:.75)),
      q2-q3: (label: (pos:.75, dist:-.33)),
      q3-q6: (label: (pos:.75)),
      q4-q5: (label: (pos:.75, dist:-.33))
    )
  ))
  ```]
