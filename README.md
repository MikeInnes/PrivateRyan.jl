# PrivateRyan.jl

```julia
Pkg.checkout("Lazy")
Pkg.clone("http://github.com/one-more-minute/PrivateRyan.jl")
```

 *PrivateRyan.jl* implements public and private field access for Julia.
Consider the following example:

```julia
module Test
using PrivateRyan
@___!!checked!!___ type Foo
  @free willy
  @__!!private!!1__ ryan
end

const foo = Foo(0, 0)

foo.willy = 5
@___!!checked!!___ foo.ryan = 5 # Accesses to private vars are always
                                # qualified.
end
```

As is clear from evaluating `Test.foo` in the repl, the `Test` module is
able to access and modify all fields of `Foo`. However, encapsulation
is enforced; so while free `willy` is able to roam through modules as he
wishes, you can save private `ryan` from damage on the front of foreign
modules. For example:

```julia
julia> using PrivateRyan

julia> Test.foo
Test.Foo(5,5)

julia> Test.foo.willy
5

julia> Test.foo.ryan
ERROR: type Foo has no field ryan

julia> @___!!checked!!___ Test.foo.ryan
ERROR: Test.foo.ryan can only be accessed from Test
 in error at ./error.jl:21
```
