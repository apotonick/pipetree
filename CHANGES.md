# 0.1.1

* Remove `uber` gem dependency as we don't need it here.

# 0.1.0

* Rename `Flow` to `Railway`.
* All "operators" like `Flow#&` are now optional in `Operator` and considered experimental. Single entry point to adding steps is `Flow#add`.
* Remove `Flow#>>`.
* Add `Flow#add` which allows a low-level *tie*, a step that sits directly on the track with incoming interface `(last, input, options)` and outgoing `[new_track, input]`.
* Make `Flow#_insert` private, as we now have `add`.
* `And`'s direction can now be configured via `:on_true` and `:on_false`, allowing to deviate to any kind of track.
* Remove the `Pipetree` array implementation and save it for future versions.

# 0.0.5

* `Flow` doesn't inherit from `Array` anymore. Temporarily use `Uber::Delegates` to achieve the same interface. This will change in 0.1.x when `Insert` works against an array. This makes `Flow.new` the new canonical constructor which allows us to initialize `step@proc` properly.

# 0.0.3

* Improved insert semantics.

# 0.0.2

* Add `Pipetree::Flow`.
