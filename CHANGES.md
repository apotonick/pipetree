# 0.0.5

* `Flow` doesn't inherit from `Array` anymore. Temporarily use `Uber::Delegates` to achieve the same interface. This will change in 0.1.x when `Insert` works against an array. This makes `Flow.new` the new canonical constructor which allows us to initialize `step@proc` properly.

# 0.0.3

* Improved insert semantics.

# 0.0.2

* Add `Pipetree::Flow`.
