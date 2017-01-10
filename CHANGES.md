# 0.0.6

* Remove `Flow#>>`.
* Add `Flow#add` which allows a low-level *strut*, a step that sits directly on the track with incoming interface `(last, input, options)` and outgoing `[new_track, input]`.
* `And`'s direction can now be configured via `:on_true` and `:on_false`, allowing to deviate to any kind of track.

# 0.0.5

* `Flow` doesn't inherit from `Array` anymore. Temporarily use `Uber::Delegates` to achieve the same interface. This will change in 0.1.x when `Insert` works against an array. This makes `Flow.new` the new canonical constructor which allows us to initialize `step@proc` properly.

# 0.0.3

* Improved insert semantics.

# 0.0.2

* Add `Pipetree::Flow`.
