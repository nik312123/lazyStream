type 'a t = Nil | Cons of 'a * 'a t lazy_t

let empty: 'a t = Nil

let is_empty (s: 'a t): bool = s = Nil

let cons (el: 'a) (s: 'a t): 'a t = Cons (el, lazy s)

let rec from (start: 'a) (next: 'a -> 'a): 'a t =
    Cons (start, lazy (from (next start) next))

let from_int (start: int) (inc: int): int t = from start ((+) inc)

let from_char (start: char) (inc: int): char t = from start (fun c -> Char.code c + inc |> Char.chr)

let rec range (start: 'a) (finish: 'a) (next: 'a -> 'a): 'a t =
    if start = finish then Cons (finish, lazy Nil)
    else Cons (start, lazy (range (next start) finish next))

let range_int (start: int) (finish: int) (inc: int): int t = range start finish ((+) inc)

let range_char (start: char) (finish: char) (inc: int): char t =
    range start finish (fun c -> Char.code c + inc |> Char.chr)

let rec filter (filter_fn: 'a -> bool): 'a t -> 'a t = function
    | Nil -> Nil
    | Cons (x, xs) ->
        if filter_fn x then Cons (x, lazy (filter filter_fn (Lazy.force xs)))
        else filter filter_fn (Lazy.force xs)

let find_all: ('a -> bool) -> 'a t -> 'a t = filter

let rec append (s1: 'a t) (s2: 'a t): 'a t = match s1 with
    | Nil -> s2
    | Cons (x, xs) -> Cons(x, lazy (append (Lazy.force xs) s2))

let rec append_lazy (s1: 'a t) (s2_lazy: 'a t lazy_t): 'a t =
    match s1 with
        | Nil -> Lazy.force s2_lazy
        | Cons (x, xs) -> Cons(x, lazy (append_lazy (Lazy.force xs) s2_lazy))

let mapi (map_fn: int -> 'a -> 'b): 'a t -> 'b t =
    let rec map_i_aux (i: int): 'a t -> 'b t = function
        | Nil -> Nil
        | Cons (x, xs) -> Cons (map_fn i x, lazy (map_i_aux (i + 1) (Lazy.force xs)))
    in map_i_aux 0

let map (map_fn: 'a -> 'b): 'a t -> 'b t = mapi (fun _ el -> map_fn el)

let rec filter_map (fm_fn: 'a -> 'b option) (s: 'a t): 'b t = match s with
    | Nil -> Nil
    | Cons (x, xs) ->
        (match fm_fn x with
            | None -> filter_map fm_fn (Lazy.force xs)
            | Some v -> Cons (v, lazy (filter_map fm_fn (Lazy.force xs)))
        )

let rec flat_map (fm_fn: 'a -> 'b t): 'a t -> 'b t = function
    | Nil -> Nil
    | Cons(x, xs) -> append (fm_fn x) (flat_map fm_fn (Lazy.force xs))

let rec flat_map_lazy (fm_fn: 'a -> 'b t): 'a t -> 'b t = function
    | Nil -> Nil
    | Cons(x, xs) -> append_lazy (fm_fn x) (lazy (flat_map_lazy fm_fn (Lazy.force xs)))

let rec map_mult_aux (rest_map_fns: ('a -> 'c -> 'b) list) (shared: 'c) (el: 'a): 'b t = match rest_map_fns with
    | [] -> Nil
    | map_fn::map_fns' -> Cons (map_fn el shared, lazy (map_mult_aux map_fns' shared el))

let rec map_mult (map_fns: ('a -> 'c -> 'b) list) (shared_fn: 'a -> 'c): 'a t -> 'b t = function
    | Nil -> Nil
    | Cons (x, xs) ->
        append_lazy (map_mult_aux map_fns (shared_fn x) x) (lazy (map_mult map_fns shared_fn (Lazy.force xs)))

let rec zip (zip_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t): 'c t = match s1, s2 with
    | Cons (s1_el, s1'), Cons (s2_el, s2') ->
        Cons (zip_fn s1_el s2_el, lazy (zip zip_fn (Lazy.force s1') (Lazy.force s2')))
    | _ -> Nil

let rec zip_long (zip_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): 'c t = match s1, s2 with
    | Nil, Nil -> Nil
    | Nil, Cons (s2_el, s2') -> Cons (zip_fn s1_pl s2_el, lazy (zip_long zip_fn Nil (Lazy.force s2') s1_pl s2_pl))
    | Cons (s1_el, s1'), Nil -> Cons (zip_fn s1_el s2_pl, lazy (zip_long zip_fn (Lazy.force s1') Nil s1_pl s2_pl))
    | Cons (s1_el, s1'), Cons (s2_el, s2') ->
        Cons (zip_fn s1_el s2_el, lazy (zip_long zip_fn (Lazy.force s1') (Lazy.force s2') s1_pl s2_pl))

let hd: 'a t -> 'a = function
    | Nil -> failwith "hd"
    | Cons (x, _) -> x

let tl: 'a t -> 'a t = function
    | Nil -> failwith "tl"
    | Cons (_, xs) -> Lazy.force xs

let take (n: int): 'a t -> 'a list =
    let rec take_aux (n: int) (acc: 'a list) (s: 'a t): 'a list =
        if n <= 0 then List.rev acc
        else match s with
            | Nil -> List.rev acc
            | Cons (x, xs) -> take_aux (n - 1) (x::acc) (Lazy.force xs)
    in take_aux n []

let take_except (n: int): 'a t -> 'a list =
    let rec take_aux (n: int) (acc: 'a list) (s: 'a t): 'a list =
        if n <= 0 then List.rev acc
        else match s with
            | Nil -> failwith "take_except"
            | Cons (x, xs) -> take_aux (n - 1) (x::acc) (Lazy.force xs)
    in take_aux n []

let take_all (s: 'a t): 'a list =
    let rec take_aux (acc: 'a list): 'a t -> 'a list = function
        | Nil -> List.rev acc
        | Cons (x, xs) -> take_aux (x::acc) (Lazy.force xs)
    in take_aux [] s

let rec drop (n: int): 'a t -> 'a t = function
    | Nil -> Nil
    | s when n <= 0 -> s
    | Cons (_, xs) -> drop (n - 1) (Lazy.force xs)

let rec drop_except (n: int): 'a t -> 'a t = function
    | Nil -> failwith "drop_except"
    | s when n <= 0 -> s
    | Cons (_, xs) -> drop_except (n - 1) (Lazy.force xs)

let rec to_seq: 'a t -> 'a Seq.t = function
    | Nil -> fun () -> Seq.Nil
    | Cons (x, xs) -> fun () -> Seq.Cons (x, to_seq (Lazy.force xs))

let rec of_seq (seq: 'a Seq.t): 'a t = match seq () with
    | Seq.Nil -> Nil
    | Seq.Cons (x, xs) -> Cons (x, lazy (of_seq xs))

let to_list: 'a t -> 'a list = take_all

let rec of_list: 'a list -> 'a t = function
    | [] -> Nil
    | x::xs -> Cons (x, lazy (of_list xs))

let to_string (s: char t): string = to_seq s |> String.of_seq

let of_string (str: string): char t =
    let n = String.length str in
    let rec of_string_aux (i: int): char t =
        if i >= n then Nil
        else Cons (String.get str i, lazy (of_string_aux (i + 1)))
    in of_string_aux 0

let to_bytes (s: char t): bytes = to_seq s |> Bytes.of_seq

let of_bytes (b: bytes): char t =
    let n = Bytes.length b in
    let rec of_bytes_aux (i: int): char t =
        if i >= n then Nil
        else Cons (Bytes.get b i, lazy (of_bytes_aux (i + 1)))
    in of_bytes_aux 0

let rec output_to_channel (chan: out_channel): char t -> unit = function
    | Nil -> ()
    | Cons (x, xs) -> output_char chan x; output_to_channel chan (Lazy.force xs)

let rec of_channel (chan: in_channel): char t =
    try Cons(input_char chan, lazy (of_channel chan))
    with End_of_file -> Nil

let repeat_elements (n: int) (s: 'a t): 'a t =
    let rec repeat_elements_aux (i: int) (rest_s: 'a t): 'a t = match rest_s with
        | Nil -> Nil
        | Cons (x, xs) ->
            if i < n
            then Cons(x, lazy (repeat_elements_aux (i + 1) rest_s))
            else repeat_elements_aux 0 (Lazy.force xs)
    in repeat_elements_aux 0 s

let rec repeat_stream (n: int) (s: 'a t): 'a t =
    if n <= 0 then Nil
    else append s (repeat_stream (n - 1) s)

let cartesian_product (s1: 'a t) (s2: 'b t): ('a * 'b) t =
    let rec s2_inner (s1_el: 'a): 'b t -> ('a * 'b) t = function
        | Nil -> Nil
        | Cons (s2_el, s2') -> Cons ((s1_el, s2_el), lazy (s2_inner s1_el (Lazy.force s2')))
    in let rec s1_outer: 'a t -> ('a * 'b) t = function
        | Nil -> Nil
        | Cons (s1_el, s1') -> append_lazy (s2_inner s1_el s2) (lazy (s1_outer (Lazy.force s1')))
    in s1_outer s1

let rev (s: 'a t): 'a t =
    let rec rev_aux (acc: 'a t): 'a t -> 'a t = function
        | Nil -> acc
        | Cons (x, xs) -> rev_aux (Cons (x, lazy acc)) (Lazy.force xs)
    in rev_aux Nil s

let rec fold_left (fold_fn: 'b -> 'a -> 'b) (acc: 'b): 'a t -> 'b = function
    | Nil -> acc
    | Cons (x, xs) -> fold_left fold_fn (fold_fn acc x) (Lazy.force xs)

let rec fold_left_lazy (fold_fn: 'b -> 'a -> 'b) (acc: 'b): 'a t -> 'b t = function
    | Nil -> Cons (acc, lazy Nil)
    | Cons (x, xs) -> Cons (acc, lazy (fold_left_lazy fold_fn (fold_fn acc x) (Lazy.force xs)))

let fold_right (fold_fn: 'a -> 'b -> 'b) (s: 'a t) (acc: 'b): 'b = fold_left (Fun.flip fold_fn) acc (rev s)

let length (s: 'a t): int =
    let rec length_aux (acc: int): 'a t -> int = function
        | Nil -> acc
        | Cons (_, xs) -> length_aux (acc + 1) (Lazy.force xs)
    in length_aux 0 s

let rec compare_lengths (s1: 'a t) (s2: 'b t): int = match s1, s2 with
    | Nil, Nil -> 0
    | Nil, _ -> -1
    | _, Nil -> 1
    | Cons (_, s1'), Cons (_, s2') -> compare_lengths (Lazy.force s1') (Lazy.force s2')

let opt_get_nf: 'a option -> 'a = function
    | None -> raise Not_found
    | Some v -> v

let nth_opt (s: 'a t) (n: int): 'a option =
    let s' = drop n s in
    match s' with
        | Nil -> None
        | Cons (x, _) -> Some x

let nth (s: 'a t) (n: int): 'a = match nth_opt s n with
    | None -> invalid_arg "LazyStream.nth"
    | Some v -> v

let init (len: int) (init_fn: int -> 'a): 'a t =
    if len < 0 then invalid_arg "LazyStream.init"
    else map init_fn (range_int 0 (len - 1) 1)

let rev_append (s1: 'a t) (s2: 'a t): 'a t = append (rev s1) s2

let rev_append_lazy (s1: 'a t) (s2_lazy: 'a t lazy_t): 'a t = append_lazy (rev s1) s2_lazy

let rec concat (ss: 'a t t): 'a t = match ss with
    | Nil -> Nil
    | Cons (x, xs) -> append x (concat (Lazy.force xs))

let rec concat_lazy (ss: 'a t t): 'a t = match ss with
    | Nil -> Nil
    | Cons (x, xs) -> append_lazy x (lazy (concat_lazy (Lazy.force xs)))

let flatten: 'a t t -> 'a t = concat

let flatten_lazy: 'a t t -> 'a t = concat_lazy

let iteri (iter_fn: int -> 'a -> unit) (s: 'a t): unit =
    let rec iter_i_aux (i: int): 'a t -> unit = function
        | Nil -> ()
        | Cons (x, xs) -> iter_fn i x; iter_i_aux (i + 1) (Lazy.force xs)
    in iter_i_aux 0 s

let iter (iter_fn: 'a -> unit) (s: 'a t): unit = iteri (fun _ el -> iter_fn el) s

let make_pair (p1: 'a) (p2: 'b): 'a * 'b = (p1, p2)

let combine (s1: 'a t) (s2: 'b t): ('a * 'b) t = zip make_pair s1 s2

let combine_long (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): ('a * 'b) t = zip_long make_pair s1 s2 s1_pl s2_pl

let args_fn_to_pair_fn (fn: 'a -> 'b -> 'c) ((p1, p2): 'a * 'b): 'c = fn p1 p2

let iter2 (iter_fn: 'a -> 'b -> unit) (s1: 'a t) (s2: 'b t): unit = iter (args_fn_to_pair_fn iter_fn) (combine s1 s2)

let iter2_long (iter_fn: 'a -> 'b -> unit) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): unit =
    iter (args_fn_to_pair_fn iter_fn) (combine_long s1 s2 s1_pl s2_pl)

let map2 (map_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t): 'c t = map (args_fn_to_pair_fn map_fn) (combine s1 s2)

let map2_long (map_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): 'c t =
    map (args_fn_to_pair_fn map_fn) (combine_long s1 s2 s1_pl s2_pl)

let rev_map2 (map_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t): 'c t = rev (map2 map_fn s1 s2)

let rev_map2_long (map_fn: 'a -> 'b -> 'c) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): 'c t =
    rev (map2_long map_fn s1 s2 s1_pl s2_pl)

let fold_left2 (fold_fn: 'c -> 'a -> 'b -> 'c) (acc: 'c) (s1: 'a t) (s2: 'b t): 'c =
    fold_left (fun acc (s1_el, s2_el) -> fold_fn acc s1_el s2_el) acc (combine s1 s2)

let fold_left2_lazy (fold_fn: 'c -> 'a -> 'b -> 'c) (acc: 'c) (s1: 'a t) (s2: 'b t): 'c t =
    fold_left_lazy (fun acc (s1_el, s2_el) -> fold_fn acc s1_el s2_el) acc (combine s1 s2)

let fold_left2_long (fold_fn: 'c -> 'a -> 'b -> 'c) (acc: 'c) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): 'c =
    fold_left (fun acc (s1_el, s2_el) -> fold_fn acc s1_el s2_el) acc (combine_long s1 s2 s1_pl s2_pl)

let fold_left2_long_lazy (fold_fn: 'c -> 'a -> 'b -> 'c) (acc: 'c) (s1: 'a t) (s2: 'b t) (s1_pl: 'a) (s2_pl: 'b): 'c t =
    fold_left_lazy (fun acc (s1_el, s2_el) -> fold_fn acc s1_el s2_el) acc (combine_long s1 s2 s1_pl s2_pl)

let rec for_all (pred: 'a -> bool): 'a t -> bool = function
    | Nil -> true
    | Cons (x, xs) ->
        if pred x
        then for_all pred (Lazy.force xs)
        else false

let rec find_map (map_fn: 'a -> 'b) (base: 'b) (pred: 'a -> bool): 'a t -> 'b = function
    | Nil -> base
    | Cons (x, xs) ->
        if pred x
        then map_fn x
        else find_map map_fn base pred (Lazy.force xs)

let exists (pred: 'a -> bool): 'a t -> bool = find_map (Fun.const true) false pred

let for_all2 (pred: 'a -> 'b -> bool) (s1: 'a t) (s2: 'b t): bool =
    for_all (args_fn_to_pair_fn pred) (combine s1 s2)

let exists2 (pred: 'a -> 'b -> bool) (s1: 'a t) (s2: 'b t): bool =
    exists (args_fn_to_pair_fn pred) (combine s1 s2)

let mem (el: 'a): 'a t -> bool = exists ((=) el)

let memq (el: 'a): 'a t -> bool = exists ((==) el)

let find_opt (pred: 'a -> bool): 'a t -> 'a option = find_map Option.some None pred

let find (pred: 'a -> bool) (s: 'a t) = find_opt pred s |> opt_get_nf

let rec partition_lazy (pred: 'a -> bool): 'a t -> 'a t lazy_t * 'a t lazy_t = function
    | Nil -> lazy Nil, lazy Nil
    | Cons (x, xs) ->
        let next = lazy (partition_lazy pred (Lazy.force xs)) in
        let true_acc_next = lazy (Lazy.force next |> fst |> Lazy.force) in
        let false_acc_next = lazy (Lazy.force next |> snd |> Lazy.force) in
        if pred x
        then lazy (Cons (x, true_acc_next)), false_acc_next
        else true_acc_next, lazy (Cons (x, false_acc_next))

let partition (pred: 'a -> bool) (s: 'a t): 'a t * 'a t =
    let (true_acc_lazy, false_acc_lazy) = partition_lazy pred s in
    Lazy.force true_acc_lazy, Lazy.force false_acc_lazy

let assoc_opt (el_key: 'a): ('a * 'b) t -> 'b option =
    find_map (fun (_, value) -> Some value) None (fun (key, _) -> el_key = key)

let assoc (el_key: 'a) (as_s: ('a * 'b) t): 'b = assoc_opt el_key as_s |> opt_get_nf

let assq_opt (el_key: 'a): ('a * 'b) t -> 'b option =
    find_map (fun (_, value) -> Some value) None (fun (key, _) -> el_key == key)

let assq (el_key: 'a) (as_s: ('a * 'b) t): 'b = assq_opt el_key as_s |> opt_get_nf

let mem_assoc (el_key: 'a): ('a * 'b) t -> bool =
    find_map (Fun.const true) false (fun (key, _) -> el_key = key)

let mem_assq (el_key: 'a): ('a * 'b) t -> bool =
    find_map (Fun.const true) false (fun (key, _) -> el_key == key)

let rec remove_assoc (el_key: 'a): ('a * 'b) t -> ('a * 'b) t = function
    | Nil -> Nil
    | Cons ((key, value), xs) ->
        if key = el_key
        then Lazy.force xs
        else Cons ((key, value), lazy (remove_assoc el_key (Lazy.force xs)))

let rec remove_assq (el_key: 'a): ('a * 'b) t -> ('a * 'b) t = function
    | Nil -> Nil
    | Cons ((key, value), xs) ->
        if key == el_key
        then Lazy.force xs
        else Cons ((key, value), lazy (remove_assq el_key (Lazy.force xs)))

let rec split (s: ('a * 'b) t): 'a t * 'b t = match s with
    | Nil -> (Nil, Nil)
    | Cons ((p1, p2), xs) ->
        let next = lazy (split (Lazy.force xs)) in
        (Cons (p1, lazy (Lazy.force next |> fst)), Cons (p2, lazy (Lazy.force next |> snd)))

let rec compare (compare_fn: 'a -> 'a -> int) (s1: 'a t) (s2: 'a t): int = match s1, s2 with
    | Nil, Nil -> 0
    | Nil, _ -> -1
    | _, Nil -> 1
    | Cons (s1_el, s1'), Cons (s2_el, s2') ->
        (match compare_fn s1_el s2_el with
            | 0 -> compare compare_fn (Lazy.force s1') (Lazy.force s2')
            | comparison -> comparison
        )

let equals (equal_fn: 'a -> 'a -> bool) (s1: 'a t) (s2: 'a t): bool =
    compare (fun s1_el s2_el -> if equal_fn s1_el s2_el then 0 else -1) s1 s2 = 0

let sort (compare_fn: 'a -> 'a -> int) (s: 'a t): 'a t = List.sort compare_fn (to_list s) |> of_list

let stable_sort (compare_fn: 'a -> 'a -> int) (s: 'a t): 'a t = List.stable_sort compare_fn (to_list s) |> of_list

let fast_sort (compare_fn: 'a -> 'a -> int) (s: 'a t): 'a t = List.fast_sort compare_fn (to_list s) |> of_list

let sort_uniq (compare_fn: 'a -> 'a -> int) (s: 'a t): 'a t = List.sort_uniq compare_fn (to_list s) |> of_list

let rec merge (compare_fn: 'a -> 'a -> int) (s1: 'a t) (s2: 'a t): 'a t = match s1, s2 with
    | Nil, Nil -> Nil
    | Nil, _ -> s2
    | _, Nil -> s1
    | Cons (s1_el, s1'), Cons (s2_el, s2') ->
        let comparison = compare_fn s1_el s2_el in
        if comparison < 0
        then Cons (s1_el, lazy (merge compare_fn (Lazy.force s1') s2))
        else Cons (s2_el, lazy (merge compare_fn s1 (Lazy.force s2')))
