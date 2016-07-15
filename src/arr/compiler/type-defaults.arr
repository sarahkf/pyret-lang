provide *
provide-types *

import ast as A
import string-dict as SD
import srcloc as SL
import file("type-structs.arr") as TS

module-uri                = TS.module-uri
dependency                = TS.dependency
local                     = TS.local

type Type                 = TS.Type
t-name                    = TS.t-name(_, _, A.dummy-loc)
t-var                     = TS.t-var(_, A.dummy-loc)
t-arrow                   = TS.t-arrow(_, _, A.dummy-loc)
t-top                     = TS.t-top(A.dummy-loc)
t-bot                     = TS.t-bot(A.dummy-loc)
t-app                     = TS.t-app(_, _, A.dummy-loc)
t-record                  = TS.t-record(_, A.dummy-loc)
t-forall                  = TS.t-forall(_, _, A.dummy-loc)
t-data                    = TS.t-data(_, _, _, A.dummy-loc)

t-number                  = TS.t-number(A.dummy-loc)
t-string                  = TS.t-string(A.dummy-loc)
t-boolean                 = TS.t-boolean(A.dummy-loc)
t-array                   = TS.t-array(_, A.dummy-loc)
t-nothing                 = TS.t-nothing(A.dummy-loc)
t-srcloc                  = TS.t-srcloc(A.dummy-loc)
t-array-name              = TS.t-array-name

type TypeMember           = TS.TypeMember
t-member                  = TS.t-member(_, _)

type ModuleType           = TS.ModuleType
t-module                  = TS.t-module

type TypeVariant          = TS.TypeVariant
t-variant                 = TS.t-variant(_, _, _)
t-singleton-variant       = TS.t-singleton-variant(_, _)

s-atom                    = A.s-atom

t-number-binop = t-arrow([list: t-number, t-number], t-number)

eq-EqualityResult = t-name(module-uri("builtin://equality"), A.s-type-global("EqualityResult"))

# TODO(MATT): does this break things?
tva = t-var(A.global-names.make-atom("A"))
tvb = t-var(A.global-names.make-atom("B"))
tvc = t-var(A.global-names.make-atom("C"))
tvd = t-var(A.global-names.make-atom("D"))
tve = t-var(A.global-names.make-atom("E"))

fun make-default-aliases():
  default-aliases = [SD.mutable-string-dict:
    A.s-type-global("Nothing").key(), t-nothing,
    A.s-type-global("Method").key(), t-top,
    A.s-type-global("Object").key(), t-top,
    A.s-type-global("Function").key(), t-top,
    A.s-type-global("RawArray").key(), t-array-name,
    A.s-type-global("Number").key(), t-number,
    A.s-type-global("NumNonNegative").key(), t-number,
    A.s-type-global("NumNonPositive").key(), t-number,
    A.s-type-global("NumNegative").key(), t-number,
    A.s-type-global("NumPositive").key(), t-number,
    A.s-type-global("NumRational").key(), t-number,
    A.s-type-global("NumInteger").key(), t-number,
    A.s-type-global("Roughnum").key(), t-number,
    A.s-type-global("Exactnum").key(), t-number,
    A.s-type-global("String").key(), t-string,
    A.s-type-global("Boolean").key(), t-boolean]
  default-aliases
end

fun make-default-types() block:
  default-typs = SD.make-mutable-string-dict()
  default-typs.set-now(A.s-global("builtins").key(), t-record([list:
      t-member("has-field", t-arrow([list: t-record(empty)], t-boolean)),
      t-member("trace-value", t-arrow([list: t-top, t-top], t-bot)),
      t-member("current-checker", t-arrow([list: ], t-record([list: # Cheat on these types for now.
          t-member("run-checks", t-bot),
          t-member("check-is", t-bot),
          t-member("check-is-refinement", t-bot),
          t-member("check-is-not", t-bot),
          t-member("check-is-not-refinement", t-bot),
          t-member("check-is-refinement", t-bot),
          t-member("check-is-not-refinement", t-bot),
          t-member("check-satisfies", t-bot),
          t-member("check-satisfies-not", t-bot),
          t-member("check-raises-str", t-bot),
          t-member("check-raises-not", t-bot),
          t-member("check-raises-other-str", t-bot),
          t-member("check-raises-satisfies", t-bot),
          t-member("check-raises-violates" , t-bot)
      ])))
  ]))

  # Need to be fixed to correct type:
  default-typs.set-now(A.s-global("ref-get").key(), t-top)
  default-typs.set-now(A.s-global("ref-set").key(), t-top)
  default-typs.set-now(A.s-global("ref-freeze").key(), t-top)
  default-typs.set-now(A.s-global("exn-unwrap").key(), t-top)
  default-typs.set-now(A.s-global("test-print").key(), t-forall([list: tva], t-arrow([list: tva], tva)))
  default-typs.set-now(A.s-global("print-error").key(), t-top)
  default-typs.set-now(A.s-global("display-error").key(), t-top)
  default-typs.set-now(A.s-global("brander").key(), t-top)
  default-typs.set-now(A.s-global("run-task").key(), t-top)
  default-typs.set-now(A.s-global("string-split").key(), t-top)
  default-typs.set-now(A.s-global("string-split-all").key(), t-top)
  default-typs.set-now(A.s-global("string-explode").key(), t-top)
  default-typs.set-now(A.s-global("string-index-of").key(), t-top)
  default-typs.set-now(A.s-global("string-to-code-points").key(), t-top)
  default-typs.set-now(A.s-global("string-from-code-points").key(), t-top)
  default-typs.set-now("isBoolean", t-arrow([list: t-top], t-boolean))
  default-typs.set-now("checkWrapBoolean", t-arrow([list: t-boolean], t-boolean))
  default-typs.set-now("throwNonBooleanCondition", t-arrow([list: t-srcloc, t-string, t-top], t-bot))
  default-typs.set-now("throwNoBranchesMatched", t-arrow([list: t-srcloc, t-string], t-bot))
  default-typs.set-now("throwUnfinishedTemplate", t-arrow([list: t-srcloc], t-bot))
  default-typs.set-now("not", t-arrow([list: t-boolean], t-boolean))
  default-typs.set-now(A.s-global("raise").key(), t-arrow([list: t-top], t-bot))
  default-typs.set-now("hasField", t-arrow([list: t-record(empty), t-string], t-boolean))
  default-typs.set-now(A.s-global("_times").key(), t-number-binop)
  default-typs.set-now(A.s-global("_minus").key(), t-number-binop)
  default-typs.set-now(A.s-global("_divide").key(), t-number-binop)
  default-typs.set-now(A.s-global("_plus").key(), t-number-binop)
  default-typs.set-now("makeSrcloc", t-arrow([list: t-srcloc], t-bot))
  default-typs.set-now(A.s-global("string-tonumber").key(), t-arrow([list: t-string], t-number))

  default-typs.set-now(A.s-global("_lessthan").key(), t-number-binop)
  default-typs.set-now(A.s-global("_lessequal").key(), t-number-binop)
  default-typs.set-now(A.s-global("_greaterthan").key(), t-number-binop)
  default-typs.set-now(A.s-global("_greaterequal").key(), t-number-binop)
  default-typs.set-now(A.s-global("print").key(), t-forall([list: tva], t-arrow([list: tva], tva)))
  default-typs.set-now(A.s-global("display").key(), t-forall([list: tva], t-arrow([list: tva], tva)))

  default-typs
end

fun make-default-data-exprs() block:
  default-data-exprs = SD.make-mutable-string-dict()
  default-data-exprs
end

# Begin hard-coded module types
rec t-list = t-name(module-uri("builtin://lists"), A.s-type-global("List"))
fun mk-list(a :: Type) -> Type:
  t-app(t-list, [list: a])
end

t-big-array = t-name(module-uri("builtin://arrays"), A.s-type-global("Array"))
fun mk-array(typ :: Type):
  t-app(t-big-array, [list: typ])
end

t-set = t-name(module-uri("builtin://sets"), A.s-type-global("Set"))
fun mk-set(typ :: Type):
  t-app(t-set, [list: typ])
end

t-torepr   = t-arrow([list: ], t-string)
t-tostring = t-arrow([list: ], t-string)

# Functions for adding hard-coded modules
module-const-equality = t-module("builtin://equality",
  t-record([list:
    t-member("EqualityResult", t-arrow([list: t-top], t-boolean)),
    t-member("is-EqualityResult", t-arrow([list: t-top], t-boolean)),
    t-member("Equal", eq-EqualityResult),
    t-member("is-Equal", t-arrow([list: t-top], t-boolean)),
    t-member("NotEqual", t-arrow([list: t-string], eq-EqualityResult)),
    t-member("is-NotEqual", t-arrow([list: t-top], t-boolean)),
    t-member("Unknown", eq-EqualityResult),
    t-member("is-Unknown", t-arrow([list: t-top], t-boolean)),
    t-member("equal-and", t-arrow([list: eq-EqualityResult, eq-EqualityResult], eq-EqualityResult)),
    t-member("equal-or", t-arrow([list: eq-EqualityResult, eq-EqualityResult], eq-EqualityResult)),
    t-member("to-boolean", t-arrow([list: eq-EqualityResult], t-boolean))
  ]),
  SD.make-string-dict()
    .set("EqualityResult", t-data(
      "EqualityResult",
      [list:
        t-singleton-variant("Equal", [list: ]),
        t-variant("NotEqual", [list: t-member("reason", t-string)], [list: ]),
        t-singleton-variant("Unknown", [list: ])],
      [list: ])
    ),
  SD.make-string-dict()
)

module-const-arrays = t-module("builtin://arrays",
  t-record([list:
    t-member("array", t-top),
    t-member("build-array", t-forall([list: tva], t-arrow([list: t-arrow([list: t-number], tva), t-number], mk-array(tva)))),
    t-member("array-from-list", t-forall([list: tva], t-arrow([list: mk-list(tva)], mk-array(tva)))),
    t-member("is-array", t-forall([list: tva], t-arrow([list: t-top], t-boolean))),
    t-member("array-of", t-forall([list: tva], t-arrow([list: tva, t-number], mk-array(tva)))),
    t-member("array-set-now", t-forall([list: tva], t-arrow([list: mk-array(tva), t-number, tva], t-nothing))),
    t-member("array-get-now", t-forall([list: tva], t-arrow([list: mk-array(tva), t-number], tva))),
    t-member("array-length", t-forall([list: tva], t-arrow([list: mk-array(tva)], t-number))),
    t-member("array-to-list-now", t-forall([list: tva], t-arrow([list: mk-array(tva)], mk-list(tva))))
  ]),
  let tv-arg = [list: tva]:
    SD.make-string-dict()
      .set("Array", t-forall([list: tva],
        t-data(
          "Array",
          [list: ],
          [list:
              t-member("get-now", t-arrow([list: t-number], tva)),
              t-member("set-now", t-arrow([list: t-number, tva], t-nothing)),
              t-member("to-list-now", t-arrow(empty, mk-list(tva))),
              t-member("length", t-arrow(empty, t-number)),
              t-member("_torepr", t-torepr),
              t-member("_tostring", t-tostring)
        ])
      ))
  end,
  SD.make-string-dict()
    .set("Array", t-name(local, A.s-name(A.dummy-loc, "Array")))
)

set-constructor =
  t-record([list:
      t-member("make", t-forall([list: tva], t-arrow([list: t-array(tva)], mk-set(tva)))),
      t-member("make0", t-forall([list: tva], t-arrow([list: ], mk-set(tva)))),
      t-member("make1", t-forall([list: tva], t-arrow([list: tva], mk-set(tva)))),
      t-member("make2", t-forall([list: tva], t-arrow([list: tva, tva], mk-set(tva)))),
      t-member("make3", t-forall([list: tva], t-arrow([list: tva, tva, tva], mk-set(tva)))),
      t-member("make4", t-forall([list: tva], t-arrow([list: tva, tva, tva, tva], mk-set(tva)))),
      t-member("make5", t-forall([list: tva], t-arrow([list: tva, tva, tva, tva, tva], mk-set(tva))))
    ])

t-empty-set = t-forall([list: tva], mk-set(tva))

t-list-to-set = t-forall([list: tva], t-arrow([list: mk-list(tva)], mk-set(tva)))

module-const-sets = t-module("builtin://sets",
  t-record([list:
    t-member("set", set-constructor),
    t-member("list-set", set-constructor),
    t-member("tree-set", set-constructor),
    t-member("empty-set", t-empty-set),
    t-member("empty-list-set", t-empty-set),
    t-member("empty-tree-set", t-empty-set),
    t-member("list-to-set", t-list-to-set),
    t-member("list-to-list-set", t-list-to-set),
    t-member("list-to-tree-set", t-list-to-set)
  ]),
  let tv-set = mk-set(tva),
      tv-to-tv = t-arrow([list: tv-set], tv-set),
      tv-arg = [list: tva]:
    SD.make-string-dict()
      .set("Set", t-forall([list: tva],
        t-data(
          "Set",
          [list: ],
          [list:
              t-member("length", t-arrow(empty, t-number)),
              t-member("pick", t-arrow(empty, t-app(t-name(module-uri("builtin://pick"), A.s-type-global("Pick")), [list: tva, mk-set(tva)]))),
              t-member("_torepr", t-torepr),
              t-member("fold", t-forall([list: tvb], t-arrow([list: t-arrow([list: tvb, tva], tvb), tvb], tvb))),
              t-member("member", t-arrow([list: tva], t-boolean)),
              t-member("add", t-arrow([list: tva], tv-set)),
              t-member("remove", t-arrow([list: tva], tv-set)),
              t-member("to-list", t-arrow(empty, mk-list(tva))),
              t-member("union", tv-to-tv),
              t-member("intersect", tv-to-tv),
              t-member("difference", tv-to-tv),
              t-member("size", t-arrow(empty, t-number))
        ])
      ))
  end,
  SD.make-string-dict()
    .set("Set", t-name(local, A.s-name(A.dummy-loc, "Set")))
)

module-const-lists = t-module("builtin://lists",
  t-record([list:
    t-member("List", t-arrow([list: t-top], t-boolean)),
    t-member("is-List", t-arrow([list: t-top], t-boolean)),
    t-member("empty", t-forall([list: tva], mk-list(tva))),
    t-member("is-empty", t-arrow([list: t-top], t-boolean)),
    t-member("link", t-forall([list: tva], t-arrow([list: tva, mk-list(tva)], mk-list(tva)))),
    t-member("is-link", t-arrow([list: t-top], t-boolean)),
    t-member("range", t-arrow([list: t-number, t-number], mk-list(t-number))),
    t-member("range-by", t-arrow([list: t-number, t-number, t-number], mk-list(t-number))),
    t-member("repeat", t-forall([list: tva], t-arrow([list: t-number, tva], mk-list(tva)))),
    t-member("filter", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-boolean), mk-list(tva)], mk-list(tva)))),
    t-member("partition", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-boolean), mk-list(tva)], t-record([list: t-member("is-true", mk-list(tva)), t-member("is-false", mk-list(tva))])))),
    t-member("find", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-boolean), mk-list(tva)], t-app(t-name(module-uri("builtin://option"), A.s-type-global("Option")), [list: tva])))),
    t-member("split-at", t-forall([list: tva], t-arrow([list: t-number, mk-list(tva)], t-record([list: t-member("prefix", mk-list(tva)), t-member("suffix", mk-list(tva))])))),
    t-member("any", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-boolean), mk-list(tva)], t-boolean))),
    t-member("all", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-boolean), mk-list(tva)], t-boolean))),
    t-member("all2", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: tva, tvb], t-boolean), mk-list(tva), mk-list(tvb)], t-boolean))),
    t-member("map", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: tva], tvb), mk-list(tva)], mk-list(tvb)))),
    t-member("map2", t-forall([list: tva, tvb, tvc], t-arrow([list: t-arrow([list: tva, tvb], tvc), mk-list(tva), mk-list(tvb)], mk-list(tvc)))),
    t-member("map3", t-forall([list: tva, tvb, tvc, tvd], t-arrow([list: t-arrow([list: tva, tvb, tvc], tvd), mk-list(tva), mk-list(tvb), mk-list(tvc)], mk-list(tvd)))),
    t-member("map4", t-forall([list: tva, tvb, tvc, tvd, tve], t-arrow([list: t-arrow([list: tva, tvb, tvc, tvd], tve), mk-list(tva), mk-list(tvb), mk-list(tvc), mk-list(tvd)], mk-list(tve)))),
    t-member("map_n", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: t-number, tva], tvb), t-number, mk-list(tva)], mk-list(tvb)))),
    t-member("map2_n", t-forall([list: tva, tvb, tvc], t-arrow([list: t-arrow([list: t-number, tva, tvb], tvc), t-number, mk-list(tva), mk-list(tvb)], mk-list(tvc)))),
    t-member("map3_n", t-forall([list: tva, tvb, tvc, tvd], t-arrow([list: t-arrow([list: t-number, tva, tvb, tvc], tvd), t-number, mk-list(tva), mk-list(tvb), mk-list(tvc)], mk-list(tvd)))),
    t-member("map4_n", t-forall([list: tva, tvb, tvc, tvd, tve], t-arrow([list: t-arrow([list: t-number, tva, tvb, tvc, tvd], tve), t-number, mk-list(tva), mk-list(tvb), mk-list(tvc), mk-list(tvd)], mk-list(tve)))),
    t-member("each", t-forall([list: tva], t-arrow([list: t-arrow([list: tva], t-top), mk-list(tva)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each2", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: tva, tvb], t-top), mk-list(tva), mk-list(tvb)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each3", t-forall([list: tva, tvb, tvc], t-arrow([list: t-arrow([list: tva, tvb, tvc], t-top), mk-list(tva), mk-list(tvb), mk-list(tvc)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each4", t-forall([list: tva, tvb, tvc, tvd], t-arrow([list: t-arrow([list: tva, tvb, tvc, tvd], t-top), mk-list(tva), mk-list(tvb), mk-list(tvc), mk-list(tvd)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each_n", t-forall([list: tva], t-arrow([list: t-arrow([list: t-number, tva], t-top), t-number, mk-list(tva)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each2_n", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: t-number, tva, tvb], t-top), t-number, mk-list(tva), mk-list(tvb)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each3_n", t-forall([list: tva, tvb, tvc], t-arrow([list: t-arrow([list: t-number, tva, tvb, tvc], t-top), t-number, mk-list(tva), mk-list(tvb), mk-list(tvc)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("each4_n", t-forall([list: tva, tvb, tvc, tvd], t-arrow([list: t-arrow([list: t-number, tva, tvb, tvc, tvd], t-top), t-number, mk-list(tva), mk-list(tvb), mk-list(tvc), mk-list(tvd)], t-name(module-uri("builtin://global"), A.s-type-global("Nothing"))))),
    t-member("fold", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: tva, tvb], tva), tva, mk-list(tvb)], tva))),
    t-member("fold2", t-forall([list: tva, tvb, tvc], t-arrow([list: t-arrow([list: tva, tvb, tvc], tva), tva, mk-list(tvb), mk-list(tvc)], tva))),
    t-member("fold3", t-forall([list: tva, tvb, tvc, tvd], t-arrow([list: t-arrow([list: tva, tvb, tvc, tvd], tva), tva, mk-list(tvb), mk-list(tvc), mk-list(tvd)], tva))),
    t-member("fold4", t-forall([list: tva, tvb, tvc, tvd, tve], t-arrow([list: t-arrow([list: tva, tvb, tvc, tvd, tve], tva), tva, mk-list(tvb), mk-list(tvc), mk-list(tvd), mk-list(tve)], tva))),
    t-member("fold_n", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: t-number, tva, tvb], tva), t-number, tva, mk-list(tvb)], tva))),
    t-member("list",
        t-record([list:
              t-member("make", t-forall([list: tva], t-arrow([list: t-array(tva)], mk-list(tva)))),
              t-member("make0", t-forall([list: tva], t-arrow([list: ], mk-list(tva)))),
              t-member("make1", t-forall([list: tva], t-arrow([list: tva], mk-list(tva)))),
              t-member("make2", t-forall([list: tva], t-arrow([list: tva, tva], mk-list(tva)))),
              t-member("make3", t-forall([list: tva], t-arrow([list: tva, tva, tva], mk-list(tva)))),
              t-member("make4", t-forall([list: tva], t-arrow([list: tva, tva, tva, tva], mk-list(tva)))),
              t-member("make5", t-forall([list: tva], t-arrow([list: tva, tva, tva, tva, tva], mk-list(tva))))
            ]))
  ]),
  let lotv = mk-list(tva),
      tv-arg = [list: tva]:
    SD.make-string-dict()
      .set("List", t-forall([list: tva],
        t-data(
          "List",
          [list:
            t-singleton-variant("empty", empty),
            t-variant("link", [list: t-member("first", tva), t-member("rest", mk-list(tva))], empty)
          ],
          [list:
            t-member("join-str", t-arrow([list: t-string], t-string)),
            t-member("sort", t-arrow(empty, lotv)),
            t-member("sort-by", t-arrow([list: t-arrow([list: tva, tva], t-boolean), t-arrow([list: tva, tva], t-boolean)], lotv)),
            t-member("_tostring", t-tostring),
            t-member("reverse", t-arrow(empty, lotv)),
            t-member("last", t-arrow(empty, tva)),
            t-member("append", t-arrow([list: lotv], lotv)),
            t-member("foldl", t-forall([list: tva, tvb], t-arrow([list: t-arrow([list: tva, tvb], tvb), tvb], tvb))),
            t-member("foldr", t-forall([list: tvb], t-arrow([list: t-arrow([list: tva, tvb], tvb), tvb], tvb))),
            t-member("member", t-arrow(tv-arg, t-boolean)),
            t-member("filter", t-arrow([list: t-arrow([list: tva], t-boolean)], lotv)),
            t-member("map", t-forall([list: tvb], t-arrow([list: t-arrow([list: tva], tvb)], mk-list(tvb)))),
            t-member("each", t-arrow([list: t-arrow([list: tva], t-top)], t-nothing)),
            t-member("length", t-arrow(empty, t-number)),
            t-member("_torepr", t-torepr),
            t-member("_match", t-top),
            t-member("_plus", t-arrow([list: lotv], lotv)),
            t-member("push", t-arrow([list: ], lotv)),
            t-member("split-at", t-arrow(tv-arg, t-record([list:
              t-member("prefix", lotv),
              t-member("suffix", lotv)
            ]))),
            t-member("take", t-arrow([list: t-number], lotv)),
            t-member("drop", t-arrow([list: t-number], lotv)),
            t-member("get", t-arrow([list: t-number], tva)),
            t-member("set", t-arrow([list: t-number, tva], lotv))
        ])
      ))
  end,
  SD.make-string-dict()
    .set("List", t-name(module-uri("builtin://lists"), A.s-name(A.dummy-loc, "List"))))

t-option = lam(param :: Type):
  t-app(t-name(module-uri("builtin://option"), A.s-type-global("Option")), [list: param])
end

t-and-then =
  t-forall(
    [list: tva],
    t-arrow(
      [list:
        t-arrow([list: tva], t-option(tvb))
      ],
      t-option(tvb)))

module-const-option = t-module("builtin://option",
  t-record([list:
    t-member("Option", t-arrow([list: t-top], t-boolean)),
    t-member("is-Option", t-arrow([list: t-top], t-boolean)),
    t-member("none", t-forall([list: tva], t-option(tva))),
    t-member("is-none", t-arrow([list: t-top], t-boolean)),
    t-member("some", t-forall([list: tva], t-arrow([list: tva], t-option(tva)))),
    t-member("is-some", t-arrow([list: t-top], t-boolean))
  ]),
  SD.make-string-dict()
    .set("Option", t-forall([list: tva],
      t-data(
        "Option",
        [list:
          t-singleton-variant("none",
            [list:
              t-member("_match", t-top),
              t-member("_torepr", t-torepr),
              t-member("or-else", t-arrow([list: tva], tva)),
              t-member("and-then", t-and-then)
            ]
          ),
          t-variant("some",
            [list: t-member("value", tva)],
            [list:
              t-member("_match", t-top),
              t-member("_torepr", t-torepr),
              t-member("or-else", t-arrow([list: tva], tva)),
              t-member("and-then", t-and-then)
            ]
          )
        ],
        [list:
          t-member("and-then", t-and-then),
          t-member("or-else", t-arrow([list: tva], tva)),
          t-member("_torepr", t-torepr),
          t-member("_match", t-top)
      ])
    )),
  SD.make-string-dict()
    .set("Option", t-name(module-uri("builtin://option"), A.s-name(A.dummy-loc, "Option")))
)

module-const-error = t-module("builtin://error",
  t-record([list:
    t-member("RuntimeError", t-arrow([list: t-top], t-boolean)),
    t-member("is-RuntimeError", t-arrow([list: t-top], t-boolean)),
    t-member("message-exception", t-arrow([list: t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-message-exception", t-arrow([list: t-top], t-boolean)),
    t-member("no-branches-matched", t-arrow([list: t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-no-branches-matched", t-arrow([list: t-top], t-boolean)),
    t-member("internal-error", t-arrow([list: t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-internal-error", t-arrow([list: t-top], t-boolean)),
    t-member("field-not-found", t-arrow([list: t-top, t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-field-not-found", t-arrow([list: t-top], t-boolean)),
    t-member("lookup-non-object", t-arrow([list: t-top, t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-lookup-non-object", t-arrow([list: t-top], t-boolean)),
    t-member("extend-non-object", t-arrow([list: t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-extend-non-object", t-arrow([list: t-top], t-boolean)),
    t-member("non-boolean-condition", t-arrow([list: t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-non-boolean-condition", t-arrow([list: t-top], t-boolean)),
    t-member("non-boolean-op", t-arrow([list: t-top, t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-non-boolean-op", t-arrow([list: t-top], t-boolean)),
    t-member("generic-type-mismatch", t-arrow([list: t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-generic-type-mismatch", t-arrow([list: t-top], t-boolean)),
    t-member("outside-numeric-range", t-arrow([list: t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-outside-numeric-range", t-arrow([list: t-top], t-boolean)),
    t-member("plus-error", t-arrow([list: t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-plus-error", t-arrow([list: t-top], t-boolean)),
    t-member("numeric-binop-error", t-arrow([list: t-top, t-top, t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-numeric-binop-error", t-arrow([list: t-top], t-boolean)),
    t-member("cases-arity-mismatch", t-arrow([list: t-top, t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-cases-arity-mismatch", t-arrow([list: t-top], t-boolean)),
    t-member("cases-singleton-mismatch", t-arrow([list: t-top, t-boolean, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-cases-singleton-mismatch", t-arrow([list: t-top], t-boolean)),
    t-member("arity-mismatch", t-arrow([list: t-top, t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-arity-mismatch", t-arrow([list: t-top], t-boolean)),
    t-member("non-function-app", t-arrow([list: t-top, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-non-function-app", t-arrow([list: t-top], t-boolean)),
    t-member("bad-app", t-arrow([list: t-top, t-string, t-string, t-number, t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-bad-app", t-arrow([list: t-top], t-boolean)),
    t-member("uninitialized-id", t-arrow([list: t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-uninitialized-id", t-arrow([list: t-top], t-boolean)),
    t-member("module-load-failure", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-module-load-failure", t-arrow([list: t-top], t-boolean)),
    t-member("invalid-array-index", t-arrow([list: t-string, t-top, t-number, t-string], t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError")))),
    t-member("is-invalid-array-index", t-arrow([list: t-top], t-boolean)),
    t-member("user-break", t-name(module-uri("builtin://error"), A.s-type-global("RuntimeError"))),
    t-member("is-user-break", t-arrow([list: t-top], t-boolean)),
    t-member("ParseError", t-arrow([list: t-top], t-boolean)),
    t-member("is-ParseError", t-arrow([list: t-top], t-boolean)),
    t-member("parse-error-next-token", t-arrow([list: t-top, t-string], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-parse-error-next-token", t-arrow([list: t-top], t-boolean)),
    t-member("parse-error-eof", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-parse-error-eof", t-arrow([list: t-top], t-boolean)),
    t-member("parse-error-unterminated-string", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-parse-error-unterminated-string", t-arrow([list: t-top], t-boolean)),
    t-member("empty-block", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-empty-block", t-arrow([list: t-top], t-boolean)),
    t-member("bad-block-stmt", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-bad-block-stmt", t-arrow([list: t-top], t-boolean)),
    t-member("bad-check-block-stmt", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-bad-check-block-stmt", t-arrow([list: t-top], t-boolean)),
    t-member("fun-missing-colon", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-fun-missing-colon", t-arrow([list: t-top], t-boolean)),
    t-member("fun-missing-end", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-fun-missing-end", t-arrow([list: t-top], t-boolean)),
    t-member("args-missing-comma", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-args-missing-comma", t-arrow([list: t-top], t-boolean)),
    t-member("app-args-missing-comma", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-app-args-missing-comma", t-arrow([list: t-top], t-boolean)),
    t-member("missing-end", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-missing-end", t-arrow([list: t-top], t-boolean)),
    t-member("missing-comma", t-arrow([list: t-top], t-name(module-uri("builtin://error"), A.s-type-global("ParseError")))),
    t-member("is-missing-comma", t-arrow([list: t-top], t-boolean))
  ]),
  SD.make-string-dict()
    .set("RuntimeError",
      t-data(
        "RuntimeError",
        [list:
          t-variant("message-exception", [list: t-member("message", t-string)], empty),
          t-variant("no-branches-matched", [list: t-member("loc", t-top), t-member("expression", t-string)], empty),
          t-variant("internal-error", [list: t-member("message", t-top), t-member("info-args", t-top)], empty),
          t-variant("field-not-found", [list: t-member("loc", t-top), t-member("obj", t-top), t-member("field", t-string)], empty),
          t-variant("lookup-non-object", [list: t-member("loc", t-top), t-member("non-obj", t-top), t-member("field", t-string)], empty),
          t-variant("extend-non-object", [list: t-member("loc", t-top), t-member("non-obj", t-top)], empty),
          t-variant("generic-type-mismatch", [list: t-member("val", t-top), t-member("typ", t-string)], empty),
          t-variant("numeric-binop-error", [list: t-member("val1", t-top), t-member("val2", t-top), t-member("opname", t-top), t-member("opdesc", t-top), t-member("methodname", t-top)], empty),
          t-variant("cases-arity-mismatch", [list: t-member("branch-loc", t-top), t-member("num-args", t-top), t-member("actual-arity", t-top), t-member("cases-loc", t-top)], empty),
          t-variant("cases-singleton-mismatch", [list: t-member("branch-loc", t-top), t-member("should-be-singleton", t-boolean), t-member("cases-loc", t-top)], empty),
          t-variant("arity-mismatch", [list: t-member("fun-def-loc", t-top), t-member("fun-def-arity", t-top), t-member("fun-app-args", t-top)], empty),
          t-variant("non-function-app", [list: t-member("loc", t-top), t-member("non-fun-val", t-top)], empty),
          t-variant("uninitialized-id", [list: t-member("loc", t-top), t-member("name", t-string)], empty),
          t-variant("module-load-failure", [list: t-member("names", t-top)], empty),
          t-variant("invalid-array-index", [list: t-member("method-name", t-string), t-member("array", t-top), t-member("index", t-number), t-member("reason", t-string)], empty),
          t-singleton-variant("user-break", empty)
        ],
        [list:
          t-member("_torepr", t-torepr),
          t-member("_tostring", t-tostring),
          t-member("_match", t-top)
        ]))
    .set("ParseError", t-data(
      "ParseError",
      [list:
        t-variant("parse-error-next-token", [list: t-member("loc", t-top), t-member("next-token", t-string)], empty),
        t-variant("parse-error-eof", [list: t-member("loc", t-top)], empty),
        t-variant("parse-error-unterminated-string", [list: t-member("loc", t-top)], empty),
        t-variant("empty-block", [list: t-member("loc", t-top)], empty),
        t-variant("bad-block-stmt", [list: t-member("loc", t-top)], empty),
        t-variant("bad-check-block-stmt", [list: t-member("loc", t-top)], empty),
        t-variant("fun-missing-colon", [list: t-member("loc", t-top)], empty),
        t-variant("fun-missing-end", [list: t-member("loc", t-top)], empty),
        t-variant("args-missing-comma", [list: t-member("loc", t-top)], empty),
        t-variant("app-args-missing-comma", [list: t-member("loc", t-top)], empty),
        t-variant("missing-end", [list: t-member("loc", t-top)], empty),
        t-variant("missing-comma", [list: t-member("loc", t-top)], empty)
      ],
      [list:
        t-member("loc", t-top),
        t-member("_tostring", t-tostring),
        t-member("_torepr", t-torepr),
        t-member("_match", t-top)
      ])
    ),
  SD.make-string-dict()
    .set("Error", t-name(local, A.s-name(A.dummy-loc, "Error")))
)

module-const-either =
  t-module("pyret-builtin://either",
    t-record([list:
      t-member("Either", t-arrow([list: t-top], t-boolean)),
      t-member("is-Either", t-arrow([list: t-top], t-boolean)),
      t-member("left", t-forall([list: tva, tvb], t-arrow([list: tva], t-app(t-name(module-uri("builtin://either"), A.s-type-global("Either")), [list: tva, tvb])))),
      t-member("is-left", t-arrow([list: t-top], t-boolean)),
      t-member("right", t-forall([list: tva, tvb], t-arrow([list: tvb], t-app(t-name(module-uri("builtin://either"), A.s-type-global("Either")), [list: tva, tvb])))),
      t-member("is-right", t-arrow([list: t-top], t-boolean))
    ]),
    SD.make-string-dict()
      .set("Either", t-forall([list: tva, tvb],
        t-data(
          "Either",
          [list:
            t-variant("left",
              [list:
                t-member("v", tva)
              ],
              [list:
                t-member("_match", t-top),
                t-member("_torepr", t-torepr)
              ]
            ),
            t-variant("right",
              [list:
                t-member("v", tvb)
              ],
              [list:
                t-member("_match", t-top),
                t-member("_torepr", t-torepr)
              ]
            )
          ],
          [list:
            t-member("v", t-top),
            t-member("_torepr", t-torepr),
            t-member("_match", t-top)
        ])
      )),
    SD.make-string-dict()
      .set("Either", t-name(module-uri("builtin://either"), A.s-name(A.dummy-loc, "Either"))))

t-s-exp = t-name(module-uri("builtin://s-exp-structs"), A.s-type-global("S-Exp"))

s-exp-struct-mems = [list:
  t-member("s-list", t-arrow([list: mk-list(t-s-exp)], t-s-exp)),
  t-member("s-num", t-arrow([list: t-number], t-s-exp)),
  t-member("s-str", t-arrow([list: t-string], t-s-exp)),
  t-member("s-sym", t-arrow([list: t-string], t-s-exp)),
  t-member("is-s-list", t-arrow([list: t-top], t-boolean)),
  t-member("is-s-num", t-arrow([list: t-top], t-boolean)),
  t-member("is-s-str", t-arrow([list: t-top], t-boolean)),
  t-member("is-s-sym", t-arrow([list: t-top], t-boolean))
]

module-const-s-exp = t-module("builtin://s-exp",
  t-record(s-exp-struct-mems + [list:
    t-member("read-s-exp", t-arrow([list: t-string], t-s-exp))
  ]),
  SD.make-string-dict(),
  SD.make-string-dict()
    .set("S-Exp", t-s-exp)
)

module-const-s-exp-structs = t-module("builtin://s-exp-structs",
  t-record(s-exp-struct-mems),
  SD.make-string-dict()
    .set("S-Exp", t-data(
      "S-Exp",
      [list:
        t-variant("s-list",
          [list:
            t-member("exps", mk-list(t-s-exp))
          ],
          [list:
            t-member("_match", t-top),
            t-member("_torepr", t-torepr)
          ]
        ),
        t-variant("s-num",
          [list:
            t-member("n", t-number)
          ],
          [list:
            t-member("_match", t-top),
            t-member("_torepr", t-torepr)
          ]
        ),
        t-variant("s-str",
          [list:
            t-member("s", t-string)
          ],
          [list:
            t-member("_match", t-top),
            t-member("_torepr", t-torepr)
          ]
        ),
        t-variant("s-sym",
          [list:
            t-member("s", t-string)
          ],
          [list:
            t-member("_match", t-top),
            t-member("_torepr", t-torepr)
          ]
        )
      ],
      [list:
        t-member("_torepr", t-torepr)
      ])
    ),
  SD.make-string-dict()
)

fun make-default-modules() block:
  default-modules = SD.make-mutable-string-dict()
  default-modules.set-now("builtin://equality", module-const-equality)
  default-modules.set-now("builtin://lists", module-const-lists)
  default-modules.set-now("builtin://option", module-const-option)
  default-modules.set-now("builtin://error", module-const-error)
  default-modules.set-now("builtin://either", module-const-either)
  default-modules.set-now("builtin://arrays", module-const-arrays)
  default-modules.set-now("builtin://sets", module-const-sets)
  default-modules.set-now("builtin://s-exp", module-const-s-exp)
  default-modules.set-now("builtin://s-exp-structs", module-const-s-exp-structs)
  default-modules
end
