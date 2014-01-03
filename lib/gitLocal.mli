(*
 * Copyright (c) 2013 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Management of Git objects in the local filesystem. *)

open GitTypes

(** Read a complete repository state. Note: we only load the object
    references, not their contents. This is because we don't really want
    to store all the state in memory, especially when you can *huge* pack
    files. *)
val create: string -> t

(** Create a store from the current directory. *)
val current: unit -> t

(** Dump the state to stderr. This function is in this module because
    we need to be aware of the mapping model/filesystem to load file
    contents on demand. *)
val dump: t -> unit

(** Read the contents of a node. The result can be either a normal
    value or a packed value. *)
val read: t -> node -> value option

(** Return the references. *)
val refs: t -> (string * node) list

(** List of nodes. *)
val list: t -> node list

(** Successors (with labels). *)
val succ: t -> node -> ([`parent|`tag of string|`file of string] * node) list

(** Write a value. *)
val write: t -> value -> node

(** Write a value. *)
val write_and_check_inflated: t -> node -> string -> unit

(** Write a reference. *)
val write_reference: t -> string -> node -> unit