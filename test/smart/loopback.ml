open Lwt.Infix

type flow = { mutable i : Cstruct.t; mutable o : Cstruct.t; mutable c : bool }
type endpoint = string list
type error = |
type write_error = [ `Closed ]

let pp_error : error Fmt.t = fun _ppf -> function _ -> .
let closed_by_peer = "Closed by peer"
let pp_write_error ppf = function `Closed -> Fmt.string ppf closed_by_peer

let connect i =
  let i = String.concat "" i in
  let i = Cstruct.of_string i in
  Lwt.return_ok { i; o = Cstruct.create 0x1000; c = false }

let read flow =
  if Cstruct.len flow.i = 0 then (
    flow.c <- true;
    Lwt.return_ok `Eof)
  else
    let res = Cstruct.create 0x1000 in
    let len = min (Cstruct.len res) (Cstruct.len flow.i) in
    Cstruct.blit flow.i 0 res 0 len;
    flow.i <- Cstruct.shift flow.i len;
    Lwt.return_ok (`Data res)

let ( <.> ) f g x = f (g x)

let write flow str =
  if flow.c then Lwt.return_error `Closed
  else (
    flow.o <- Cstruct.append flow.o str;
    Lwt.return_ok ())

let writev flow sstr =
  let rec go = function
    | [] -> Lwt.return_ok ()
    | hd :: tl -> (
        write flow hd >>= function
        | Ok () -> go tl
        | Error _ as err -> Lwt.return err)
  in
  go sstr

let close flow =
  flow.c <- true;
  Lwt.return ()
