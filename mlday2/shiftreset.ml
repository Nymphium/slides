let mult_k k x =
  let k = Obj.clone_continuation k in
  let rec m k x =
    try continue k x with Invalid_argument "continuation already taken" ->
      m (Obj.clone_continuation k) x
  in m k x

let compose f g = fun x -> g (f x)

(* delimcc implementation *)
module type DELIMCC = sig
  type 'a prompt

  val new_prompt : unit -> 'a prompt
  val push_prompt : 'a prompt -> (unit -> 'a) -> 'a
  val shift0 : 'a prompt -> (('b -> 'a) -> 'a) -> 'b
end

module DelimccOne : DELIMCC = struct
  type 'a prompt = {
    take : 'b. (('b -> 'a) -> 'a) -> 'b;
    push : (unit -> 'a) -> 'a;
  }

  let new_prompt (type a) : unit -> a prompt = fun () ->
    let module M = struct effect Prompt : (('b -> a) -> a) -> 'b end in
    let take f = perform (M.Prompt f) in
    let push th = try th () with effect (M.Prompt f) k -> f @@ continue k
    in
    {take; push}

  let push_prompt {push} = push
  let take_subcont {take} = take

  let shift0 p f = take_subcont p @@ fun k -> f k
end

module DelimccMult : DELIMCC = struct
  type 'a prompt = {
    take : 'b. (('b -> 'a) -> 'a) -> 'b;
    push : (unit -> 'a) -> 'a;
  }

  let new_prompt (type a) : unit -> a prompt = fun () ->
    let module M = struct effect Prompt : (('b -> a) -> a) -> 'b end in
    let take f = perform (M.Prompt f) in
    let push th = try th () with effect (M.Prompt f) k -> f @@ mult_k k
    in
    {take; push}

  let push_prompt {push} = push
  let take_subcont {take} = take

  let push_subcont k v = k v

  let shift0 p f = take_subcont p @@ fun sk -> f (fun c -> push_subcont sk c)
end

(* translate {{{ *)
module Translate(D: DELIMCC) : sig
  type ('a, 'b) free
  type 'a thunk = unit -> 'a
  val newi : unit -> 'a D.prompt
  val op : ('a, 'b) free D.prompt -> 'a -> 'b
  val handler : ('g, 'g) free D.prompt ->
    ('g -> 'o) -> ('g * ('g -> 'o) -> 'o) -> 'g thunk -> 'o
  val handle : ('a thunk -> 'b) -> 'a thunk -> 'b
end = struct
  type 'a thunk = unit -> 'a
  type ('a, 'b) effh = ('a thunk -> 'b)

  type ('f, 'r) free =
    | Pure of 'r
    | Free of 'f * ('r -> ('f, 'r) free)

  let with_free f ph fh =
    match f with
    | Pure r -> ph r
    | Free(a, k) -> fh a k

  let newi () = D.new_prompt ()

  let op p e = D.shift0 p @@ fun k -> Free(e, k)

  let handler = fun
    (p : ('a, 'b) free D.prompt)
    (valh : ('g -> 'o))
    (oph : (('a * ('b -> 'o)) -> 'o))
    (th : 'a thunk)
    ->
      let rec h : ('a, 'b) free -> 'c = fun freer ->
        with_free freer
          (fun r -> valh r)
          (fun v k -> oph (v, compose k h))
      in
      let freer =
        D.push_prompt p (fun () -> let r = th () in Pure r)
      in
      h freer

  let handle : ('a, 'b) effh -> 'a thunk -> 'b = fun h e -> h @@ e
end

let ans =
  let module M = Translate(DelimccOne) in
  let open M in
  let readerh p v = (handler p
                       (fun v -> (fun _ -> v))
                       (fun (x, k) -> (fun s ->
                            let z = x + s in k z s))) v
  in
  let p = newi () in
  let hr =
    handle (readerh p) @@ fun () ->
    (let x = op p 1 in
     let y = op p x in y)
  in hr 10
(* }}} *)

