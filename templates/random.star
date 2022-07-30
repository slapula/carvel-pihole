load("@ytt:struct", "struct")

# Version of a Linear Congruential Generator (LCG) random number generator.
#
# See: https://en.wikipedia.org/wiki/Linear_congruential_generator#Python_code

def _LCG__new(seed):
  self = { "seed": seed }

  modulus = 0x80000000
  a = 1103515245
  c = 12345

  def _LCG__next():
    self["seed"] = (a * self["seed"] + c) % modulus
    return self["seed"]
  end

  def _LCG__seed(seed):
    self["seed"] = seed
  end

  return struct.make(
    seed=_LCG__seed,
    next=_LCG__next)
end

_LCG__singleton = _LCG__new(1)

def _LCG__default_seed(seed):
  return _LCG__singleton.seed(seed)
end

def _LCG__default_randint():
  return _LCG__singleton.next()
end

def _choice(seq):
  return seq[_LCG__singleton.next() % len(seq)]
end

random = struct.make(
  LCG=_LCG__new,
  seed=_LCG__default_seed,
  randint=_LCG__default_randint,
  choice=_choice)