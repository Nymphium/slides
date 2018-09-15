module State(S : sig type t end) = struct
  type t = S.t
  ;;

  effect Put : t -> unit;;
  effect Get : t

  let run init f =
    init |> match f () with
    | x -> (fun s -> (s, x))
    | effect (Put s') k ->
      (fun s -> continue k () s')
    | effect Get k ->
      (fun s -> continue k s s)
end

;;
effect Log : int -> unit

let ans =
  try begin
    let module S1 = State(struct type t = int end) in
    let incr () = S1.(perform @@ Put (perform Get + 1)) in
    S1.run 0 @@ fun () ->
    incr ();
    perform @@ Log (perform S1.Get);
    incr ();
    perform @@ Log (perform S1.Get)
  end
  with effect (Log msg) k ->
    print_int msg; continue k ()

