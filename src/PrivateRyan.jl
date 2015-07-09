module PrivateRyan

using Lazy

export @___!!checked!!___

const private = symbol("@__!!private!!1__")
const public = symbol("@free")

secretname(n) = symbol("#__$(n)__")

mod(T) = error("T is not checked.")

macro ___!!checked!!___(ex)
  if isexpr(ex, :type)
    name = namify(ex.args[2])
    for (i, field) in enumerate(ex.args[3].args)
      isexpr(field, :line, LineNumberNode) && continue
      (isexpr(field, :macrocall) && field.args[1] in [public, private]) ||
        error("Field must be labelled as public or private")
      ispub = field.args[1] == public
      fieldname = namify(field.args[2])
      !ispub && (field.args[2] = replace(field.args[2], fieldname, secretname(fieldname)))
      ex.args[3].args[i] = field.args[2]
    end
    quote
      $(esc(ex))
      PrivateRyan.mod(::$(esc(name))) = $(current_module())
      $(esc(name))
    end

  elseif isexpr(ex, :.)
    T = esc(ex.args[1])
    f = secretname(ex.args[2].args[1])
    mod = current_module()
    quote
      $mod == mod($T) ||
        error("$($(Expr(:quote, ex))) can only be accessed from $(mod($T))")
      $T.$f
    end

  elseif isexpr(ex, :(=)) && isexpr(ex.args[1], :.)
    T = esc(ex.args[1].args[1])
    f = secretname(ex.args[1].args[2].args[1])
    mod = current_module()
    quote
      $mod == mod($T) ||
        error("$($(Expr(:quote, ex))) can only be accessed from $(mod($T))")
      $T.$f = $(esc(ex.args[2]))
    end

  else
    error("Unsupported syntax")
  end
end

end # module
