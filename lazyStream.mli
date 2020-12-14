type 'a t = Nil | Cons of 'a * 'a t lazy_t
val empty: 'a t
val cons: 'a -> 'a t -> 'a t
val is_empty: 'a t -> bool
val from: 'a -> ('a -> 'a) -> 'a t
val from_int: int -> int -> int t
val from_char: char -> int -> char t
val range: 'a -> 'a -> ('a -> 'a) -> 'a t
val range_int: int -> int -> int -> int t
val range_char: char -> char -> int -> char t
val filter: ('a -> bool) -> 'a t -> 'a t
val find_all: ('a -> bool) -> 'a t -> 'a t
val append: 'a t -> 'a t -> 'a t
val append_lazy: 'a t -> 'a t lazy_t -> 'a t
val mapi: (int -> 'a -> 'b) -> 'a t -> 'b t
val map: ('a -> 'b) -> 'a t -> 'b t
val filter_map: ('a -> 'b option) -> 'a t -> 'b t
val flat_map: ('a -> 'b t) -> 'a t -> 'b t
val flat_map_lazy: ('a -> 'b t) -> 'a t -> 'b t
val map_mult: ('a -> 'c -> 'b) list -> ('a -> 'c) -> 'a t -> 'b t
val zip: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
val zip_long: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'a -> 'b -> 'c t
val hd: 'a t -> 'a
val tl: 'a t -> 'a t
val take: int -> 'a t -> 'a list
val take_all: 'a t -> 'a list
val drop: int -> 'a t -> 'a t
val to_seq: 'a t -> 'a Seq.t
val of_seq: 'a Seq.t -> 'a t
val to_list: 'a t -> 'a list
val of_list: 'a list -> 'a t
val to_string: char t -> string
val of_string: string -> char t
val to_bytes: char t -> bytes
val of_bytes: bytes -> char t
val to_channel: out_channel -> char t -> unit
val of_channel: in_channel -> char t
val repeat_elements: int -> 'a t -> 'a t
val cartesian_product: 'a t -> 'b t -> ('a * 'b) t
val rev: 'a t -> 'a t
val fold_left: ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b
val fold_right: ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b
val length: 'a t -> int
val compare_lengths: 'a t -> 'b t -> int
val nth_opt: 'a t -> int -> 'a option
val nth: 'a t -> int -> 'a
val init: int -> (int -> 'a) -> 'a t
val rev_append: 'a t -> 'a t -> 'a t
val rev_append_lazy: 'a t -> 'a t lazy_t -> 'a t
val concat: 'a t t -> 'a t
val concat_lazy: 'a t t lazy_t -> 'a t
val flatten: 'a t t -> 'a t
val flatten_lazy: 'a t t lazy_t -> 'a t
val iteri: (int -> 'a -> unit) -> 'a t -> unit
val iter: ('a -> unit) -> 'a t -> unit
val combine: 'a t -> 'b t -> ('a * 'b) t
val iter2: ('a -> 'b -> unit) -> 'a t -> 'b t -> unit
val map2: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
val rev_map2: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
val fold_left2: ('c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'c
val for_all: ('a -> bool) -> 'a t -> bool
val find_map: ('a -> 'b) -> 'b -> ('a -> bool) -> 'a t -> 'b
val exists: ('a -> bool) -> 'a t -> bool
val for_all2: ('a -> 'b -> bool) -> 'a t -> 'b t -> bool
val exists2: ('a -> 'b -> bool) -> 'a t -> 'b t -> bool
val mem: 'a -> 'a t -> bool
val memq: 'a -> 'a t -> bool
val find_opt: ('a -> bool) -> 'a t -> 'a option
val find: ('a -> bool) -> 'a t -> 'a
val partition: ('a -> bool) -> 'a t -> 'a t * 'a t
val assoc_opt: 'a -> ('a * 'b) t -> 'b option
val assoc: 'a -> ('a * 'b) t -> 'b
val assq_opt: 'a -> ('a * 'b) t -> 'b option
val assq: 'a -> ('a * 'b) t -> 'b
val mem_assoc: 'a -> ('a * 'b) t -> bool
val mem_assq: 'a -> ('a * 'b) t -> bool
val remove_assoc: 'a -> ('a * 'b) t -> ('a * 'b) t
val remove_assq: 'a -> ('a * 'b) t -> ('a * 'b) t
val split: ('a * 'b) t -> 'a t * 'b t
val sort: ('a -> 'a -> int) -> 'a t -> 'a t
val stable_sort: ('a -> 'a -> int) -> 'a t -> 'a t
val fast_sort: ('a -> 'a -> int) -> 'a t -> 'a t
val sort_uniq: ('a -> 'a -> int) -> 'a t -> 'a t
val merge: ('a -> 'a -> int) -> 'a t -> 'a t -> 'a t
