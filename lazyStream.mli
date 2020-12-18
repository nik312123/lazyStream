(**
    [LazyStream] is a data structure that is like {{:https://tinyurl.com/ocaml-seq-mod} Seq} and
    {{:https://tinyurl.com/ocaml-stream-mod} Stream} but more lazily evaluated, though calling a function with the same
    parameters multiple times will create different streams and will be evaluated separately, and more provided
    functions
    
    All provided [LazyStream] functions lazily evaluate streams or provide lazily-evaluated streams where applicable
    unless otherwise explicitly mentioned
*)

(**
    The type associated with {!LazyStream}
    
    [Nil] indicates the end of the list as [[]] does for [list]s
    [Cons] is similar to [::] for [list]s, though [Cons] has an eagerly-evaluated head and a lazily-evaluated tail
*)
type 'a t = Nil | Cons of 'a * 'a t lazy_t

(**
    The empty stream, which is equivalent to [Nil]
*)
val empty: 'a t

(**
    [is_empty] returns [true] if the given stream is equivalent to [Nil]
    @param s The stream to compare to [Nil]
    @return [true] if the stream is equivalent to [Nil]
*)
val is_empty: 'a t -> bool

(**
    [cons] concatenates [el] to the beginning of [s]
    @param el The element to concatenate onto [s]
    @param s  The stream on which to concatenate the element
    @return The stream created from concatenating the given element on the given stream
*)
val cons: 'a -> 'a t -> 'a t

(**
    [from] returns an infinite stream with the first element being [start] and all successive elements being the result
    of applying [next] to the previous element
    @param start The starting element of the stream
    @param next  The function applied to each previous element of the stream to get the next element
    @return An infinite stream with the first element being [start] and each successive element being the result of
    applying [next] to the previous element
*)
val from: 'a -> ('a -> 'a) -> 'a t

(**
    [from_int] returns an infinite stream of [int]s with the first element being [start] and each successive element
    being the previous element plus [inc]
    @param start The starting integer of the stream
    @param inc   The increment added to each previous element to get the next element
    @return An infinite stream of [int]s with the first element being [start] and each successive element being the
    previous element plus [inc]
*)
val from_int: int -> int -> int t

(**
    [from_char] returns an infinite stream of [char]s with the first element being [start] and each successive element
    being the character with the character code of the sum of the previous character code and [inc]
    @param start The starting [char] of the stream
    @param inc   The increment added to each previous element's character code to get the code of the next element
    @return An infinite stream of [char]s with the first element being [start] and each successive element the character
    with the character code of the sum of the previous character code and [inc]
*)
val from_char: char -> int -> char t

(**
    [range] returns a stream with the first element being [start], all successive elements being the result
    of applying [next] to the previous element, and the final element being [final]
    @param start The starting element of the stream
    @param next  The function applied to each previous element of the stream to get the next element
    @param final The ending element of the stream
    @return A stream with the first element being [start], each successive element being the result of applying [next]
    to the previous element, and the final element being [finish]
*)
val range: 'a -> 'a -> ('a -> 'a) -> 'a t

(**
    [range_int] returns a stream of [int]s with the first element being [start], each successive element being the
    previous element plus [inc], and the final element being [finish]
    @param start The starting [int] of the stream
    @param inc   The increment added to each previous element to get the next element
    @param final The ending [int] of the stream
    @return A stream of [int]s with the first element being [start], each successive element being the previous element
    plus [inc], and the final element being [finish]
*)
val range_int: int -> int -> int -> int t

(**
    [range_int] returns a stream of [char]s with the first element being [start], each successive element being the
    character with the character code of the sum of the previous character code and [inc], and the final element being
    [finish]
    @param start The starting [char] of the stream
    @param inc   The increment added to each previous element's character code to get the code of the next element
    @param final The ending [char] of the stream
    @return A stream of [int]s with the first element being [start], each successive element being character with the
    character code of the sum of the previous character code and [inc], and the final element being [finish]
*)
val range_char: char -> char -> int -> char t

(**
    [filter] returns a stream that contains all of the elements from the given stream that return [true] when inputted
    into [filter_fn]
    @param filter_fn The function used for filtering the given stream
    @param s         The stream to filter
    @return A stream that contains all of the elements from the given stream that return [true] when inputted
    into [filter_fn]
*)
val filter: ('a -> bool) -> 'a t -> 'a t

(**
    [find_all] is an alias for {!filter}
*)
val find_all: ('a -> bool) -> 'a t -> 'a t

(**
    [append] concatenates two streams
    @param s1 The stream on the left side of the concatenation
    @param s2 The stream on the right side of the concatenation
    @return The concatenation of the given streams
*)
val append: 'a t -> 'a t -> 'a t

(**
    [append_lazy] concatenates a stream and a computationally-deferred stream, mainly used when it is desired that the
    head of the second lazy stream should not be computed until all of the elements from the first stream have been
    iterated through
    @param s1 The stream on the left side of the concatenation
    @param s2 The stream on the right side of the concatenation with its computation deferred
    @return The concatenation of the given stream and computationally-deferred stream
*)
val append_lazy: 'a t -> 'a t lazy_t -> 'a t

(**
    [mapi] is the same as {!map}, but the function is applied to the index of the element as first argument (counting
    from 0) and the element itself as second argument
    @param map_fn The mapping function to apply to each index-element pair
    @param s      The stream to map
    @return The stream created from mapping each index-element pair of the given stream
*)
val mapi: (int -> 'a -> 'b) -> 'a t -> 'b t

(**
    [map] applies the function [map_fn] to each element of the given stream and builds a stream with the result of
    mapping each element using [map_fn]
    @param map_fn The mapping function to apply to each element
    @param s      The stream to map
    @return The stream created from mapping each element of the given stream
*)
val map: ('a -> 'b) -> 'a t -> 'b t

(**
    [filter_map] applies [fm_fn] to every element of [s], filters out the [None] elements, and returns the stream of the
    arguments of the [Some] elements
    @param fm_fn The mapping function to apply to each element to return an [option]
    @param s     The stream on which to apply [filter_map]
    @return The result of applying [fm_map] to every element of [s] and filtering out the [None] elements
*)
val filter_map: ('a -> 'b option) -> 'a t -> 'b t

(**
    [flat_map] maps each element to a substream using [fm_fn] and then returns the stream resulting from concatenating
    the substreams, using {!append} to concatenate the substreams
    @param fm_fn The mapping function to apply to each element to get a substream
    @param s     The stream on which to apply [flat_map]
    @return The result of mapping each element to a substream using [fm_fn] and then concatenating each of the
    substreams
*)
val flat_map: ('a -> 'b t) -> 'a t -> 'b t

(**
    [flat_map_lazy] maps each element to a substream using [fm_fn] and then returns the stream resulting from
    concatenating the substreams, using {!append_lazy} to concatenate the substreams
    @param fm_fn The mapping function to apply to each element to get a substream
    @param s     The stream on which to apply [flat_map]
    @return The result of mapping each element to a substream using [fm_fn] and then concatenating each of the
    substreams
*)
val flat_map_lazy: ('a -> 'b t) -> 'a t -> 'b t

(**
    [map_mult] maps each element to a number of outputs, mapping each element using each function in [map_fns] and
    producing as many elements of output for every element of input as is the length of [map_fns]
    
    Additionally, for each element taken as input, a value is computed using [shared_fn] that is passed into all of the
    mapping functions and can be used to prevent redundant computation among the mapping functions
    
    Examples (using a list-like representation for streams):
    
    [map_mult [(fun x _ -> x); (fun x _ -> x + 1)] (Fun.const ()) [1; 1; ...] = [1; 2; 1; 2; ...]]
    
    [map_mult [(fun _ sq -> sq); (fun x sq -> x + sq)] (fun x -> x * x) [1; 2; 3; ...] = [1; 2; 4; 6; 9; 12; ...]]
    @param map_fns   The functions to apply to each element of [s] to make elements in the output stream
    @param shared_fn The function that produces the value that is shared among all of the functions in [map_fns]
    @param s         The stream on which to apply [map_mult]
    @return The result of mapping all of the functions in [map_fns] to each element in [s], using the value produced
    from [shared_fn] as one of the inputs to each function in [map_fns]
*)
val map_mult: ('a -> 'c -> 'b) list -> ('a -> 'c) -> 'a t -> 'b t

(**
    [zip] returns a stream that is the result of mapping pairs of elements from two given streams to an element in the
    output stream, ending when one of the streams runs out of elements
    @param zip_fn The function used to map each element pair from [s1] and [s2] to an element in the output stream
    @param s1     The stream whose elements will be used as the first argument of [zip_fn]
    @param s2     The stream whose elements will be used as the second argument of [zip_fn]
    @return The result of mapping each pair of elements from the two given streams to a new element in the output stream
*)
val zip: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

(**
    [zip_long] returns a stream that is the result of mapping pairs of elements from two given streams to an element in
    the output stream, substituting placeholders for elements in the stream that runs out first and ending when both
    streams have run out of elements
    @param zip_fn The function used to map each element pair from [s1] and [s2] to an element in the output stream
    @param s1     The stream whose elements will be used as the first argument of [zip_fn]
    @param s2     The stream whose elements will be used as the second argument of [zip_fn]
    @param s1_pl  The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl  The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The result of mapping each pair of elements from the two given streams to a new element in the output stream
*)
val zip_long: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'a -> 'b -> 'c t

(**
    [hd] returns the first element of the given stream, raising [Failure "hd"] if there are no more elements in the
    given stream
    @param s The stream from which to retrieve the head
    @return The first element of the given stream
    @raise Failure Raised if there are no more elements in the given stream
*)
val hd: 'a t -> 'a

(**
    [tl] returns the given stream without its first element, raising [Failure "tl"] if there are no elements in the
    given stream
    @param s The stream from which to retrieve the tail
    @return The given stream without its first element
    @raise Failure Raised if there are no elements in the given stream
*)
val tl: 'a t -> 'a t

(**
    [take] returns the first [n] elements of the given stream as a [list], but if there are less then [n] elements in
    the stream, it returns the remaining elements from the stream
    @param n The number of elements to retrieve from the given stream
    @param s The stream from which to retrieve the elements
    @return The first [n] elements of the given stream as a [list], but if there are less then [n] elements in the
    stream, it returns the remaining elements from the stream
*)
val take: int -> 'a t -> 'a list

(**
    [take_except] returns the first [n] elements of the given stream as a [list], but if there are less then [n]
    elements in the stream, it raises [Failure "take_except"]
    @param n The number of elements to retrieve from the given stream
    @param s The stream from which to retrieve the elements
    @return The first [n] elements of the given stream as a [list]
    @raise Failure Raised if the given stream has less than [n] elements
*)
val take_except: int -> 'a t -> 'a list

(**
    [take_all] returns the given stream as a [list]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s The stream to convert to a [list]
    @return The given stream as a [list]
*)
val take_all: 'a t -> 'a list

(**
    [drop] returns the given stream without its first [n] elements, but if there are less than [n] elements in the
    stream, then it simply returns [Nil]
    @param n The number of elements to drop from the given stream
    @param s The stream from which elements are dropped
    @return The given stream without its first [n] elements, but if there are less than [n] elements in the stream, then
    it simply returns [Nil]
*)
val drop: int -> 'a t -> 'a t

(**
    [drop_except] returns the given stream without its first [n] elements, but if there are less than [n] elements in
    the stream, then it raises [Failure "drop_except"]
    @param n The number of elements to drop from the given stream
    @param s The stream from which elements are dropped
    @return The given stream without its first [n] elements
    @raise Failure Raised if there are less than [n] elements
*)
val drop_except: int -> 'a t -> 'a t

(**
    [to_seq] converts the given stream to a {{:https://tinyurl.com/ocaml-seq} Seq.t}
    @param s The stream to convert to a sequence
    @return [s] as a sequence
*)
val to_seq: 'a t -> 'a Seq.t

(**
    [of_seq] converts the given {{:https://tinyurl.com/ocaml-seq} Seq.t} to a stream
    @param seq The sequence to convert to a stream
    @return [seq] as a stream
*)
val of_seq: 'a Seq.t -> 'a t

(**
    [to_list] is an alias of {!take_all}
*)
val to_list: 'a t -> 'a list

(**
    [of_list] converts the given [list] to a stream
    @param lst The list to convert to a stream
    @return [lst] as a stream
*)
val of_list: 'a list -> 'a t

(**
    [to_string] converts the given [char] stream to a [string]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s The [char] stream to convert to a [string]
    @return [s] as a [string]
*)
val to_string: char t -> string

(**
    [of_string] converts the given [string] to a [char] stream
    @param str The [string] to convert to a [char] stream
    @return [str] as a [char] stream
*)
val of_string: string -> char t

(**
    [to_bytes] converts the given [char] stream to [bytes]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s The [char] stream to convert to [bytes]
    @return [s] as [bytes]
*)
val to_bytes: char t -> bytes

(**
    [of_string] converts the given [bytes] to a [char] stream
    @param b The [bytes] to convert to a [char] stream
    @return [b] as a [char] stream
*)
val of_bytes: bytes -> char t

(**
    [output_to_channel] outputs each of the [char]s in the given [char] stream into the given [out_channel]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param chan The channel to output the [char]s
    @param s    The stream from which the [char]s are outputted
    @return     unit
*)
val output_to_channel: out_channel -> char t -> unit

(**
    [of_channel] lazily reads [char]s from the given [in_channel] and returns a [char] stream
    @param chan The channel from which to read [char]s
    @return A stream for reading [char]s from the given channel
*)
val of_channel: in_channel -> char t

(**
    [repeat_elements] returns a stream with all of the given stream's elements each repeated [n] times in a row
    @param n The number of times to repeat each element
    @param s The stream that will have its elements repeated
    @return A stream with all of the given stream's elements each repeated [n] times in a row
*)
val repeat_elements: int -> 'a t -> 'a t

(**
    [repeat_stream] returns a stream that essentially is the given stream repeated [n] times in a row
    @param n The number of times to repeat the stream
    @param s The stream that will have its elements repeated
    @return A stream with all of the given stream's elements each repeated [n] times in a row
*)
val repeat_stream: int -> 'a t -> 'a t

(**
    [cartesian_product] Returns a stream representing the cartesian product of two streams
    @param s1 The stream whose elements will each be the outer (first) element in the cartesian product
    @param s2 The stream whose elements will each be the inner (second) element in the cartesian product
    @return A stream representing the cartesian product of two streams
*)
val cartesian_product: 'a t -> 'b t -> ('a * 'b) t

(**
    [rev] reverses the given stream
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s The stream to reverse
    @return The reversal of the given stream
*)
val rev: 'a t -> 'a t

(**
    [fold_left] traverses the stream from left to right, combining each element with [acc] using [fold_fn] and returns
    the result of doing so
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param fold_fn The function used to reduce the stream going from left to right
    @param acc     The accumulator used in gathering the result of reducing the given stream
    @param s       The stream to reduce from the left
    @return The result of applying [fold_fn] with the accumulator and the current element through the entire stream from
    left to right
*)
val fold_left: ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b

(**
    [fold_left_lazy] traverses the stream from left to right, combining each element with [acc] using [fold_fn] and
    returns each intermediary result in a stream from [acc] to the result of completely applying [fold_left] to the
    entire stream
    @param fold_fn The function used to reduce the stream going from left to right
    @param acc     The accumulator used in gathering the result of reducing the given stream at each step
    @param s       The stream to reduce from the left
    @return A stream consisting of each intermediary value of applying [fold_fn] with the accumulator and the current
    element through the entire stream from left to right
*)
val fold_left_lazy: ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b t

(**
    [fold_right] traverses the stream from right to left, combining each element with [acc] using [fold_fn] and returns
    the result of doing so
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param fold_fn The function used to reduce the stream going from right to left
    @param s       The stream to reduce from the right
    @param acc     The accumulator used in gathering the result of reducing the given stream
    @return The result of applying [fold_fn] with the accumulator and the current element through the entire stream from
    right to left
*)
val fold_right: ('a -> 'b -> 'b) -> 'a t -> 'b -> 'b

(**
    [length] returns the number of elements in the given stream
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s The stream whose length is returned
    @return The number of elements in the given stream
*)
val length: 'a t -> int

(**
    [compare_lengths] compares the lengths of the two given streams, and [compare_lengths s1 s2] is equivalent to
    [compare (length s1) (length s2)], except that the computation stops after iteration completes on the shortest
    stream
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param s1 The stream on the left side of the comparison
    @param s2 The stream on the right side of the comparison
    @return -1 if s1 has less elements than s2, 0 if s1 has an equal number of elements as s2, and 1 if s1 has a greater
    number of elements than s2
*)
val compare_lengths: 'a t -> 'b t -> int

(**
    [nth_opt] returns the [n]th element of the given stream wrapped in [Some], but if the stream has less than [n]
    elements, then [None] is returned
    @param s The stream from which to retrieve the [n]th element
    @param n The element number to obtain
    @return The [n]th element of the given stream wrapped in [Some], but if the stream has less than [n] elements, then
    [None] is returned
*)
val nth_opt: 'a t -> int -> 'a option

(**
    [nth] returns the [n]th element of the given stream, but if the stream has less than [n] elements, then
    [Invalid_arg "LazyStream.nth"] is raised
    @param s The stream from which to retrieve the [n]th element
    @param n The element number to obtain
    @return The [n]th element of the given stream wrapped in [Some]
    @raise Invalid_arg Raised if the stream has less than [n] elements
*)
val nth: 'a t -> int -> 'a

(**
    [init] creates a stream whose elements are composed using calls to [init_fn] with the integers [0] through [len - 1]
    inclusive, raising [Invalid_arg "LazyStream.init"] if [len] is negative
    @param len     The final length of the stream
    @param init_fn The function used to map the integers [0] through [len - 1] to values of this stream
    @return The stream whose elements are composed using calls to [init_fn] with the integers [0] through [len - 1]
    inclusive
    @raise Invalid_arg Raised if [len] is negative
*)
val init: int -> (int -> 'a) -> 'a t

(**
    [rev_append] reverses [s1] and concatenates it to [s2], which is equivalent to [append (rev s1) s2]
    
    This involves an immediate traversal over all of the elements ONLY for [s1], evaluating each of them before getting
    to the end, and not terminating on infinite streams
    @param s1 The stream that will be reversed and then concatenated to [s2]
    @param s2 The stream onto which the reversal of [s1] will be concatenate
    @return The stream created by reversing [s1] and concatenating it to [s2]
*)
val rev_append: 'a t -> 'a t -> 'a t

(**
    [rev_append] reverses [s1] and concatenates it to the computationally-delayed [s2], making this function equivalent
    to [append_lazy (rev s1) s2]
    
    This involves an immediate traversal over all of the elements ONLY for [s1], evaluating each of them before getting
    to the end, and not terminating on infinite streams
    @param s1 The stream that will be reversed and then concatenated to [s2]
    @param s2 The computationally-delayed stream onto which the reversal of [s1] will be concatenate
    @return The stream created by reversing [s1] and concatenating it to [s2]
*)
val rev_append_lazy: 'a t -> 'a t lazy_t -> 'a t

(**
    [concat] concatenates a stream of streams, meaning that the elements of [ss] are all concatenated together in the
    same order, using [append]
    @param ss The stream of streams to concatenate
    @return The concatenation of the streams that compose the given stream
*)
val concat: 'a t t -> 'a t

(**
    [concat_lazy] concatenates a stream of streams, meaning that the elements of [ss] are all concatenated together in
    the same order, using [append_lazy]
    @param ss The stream of streams to concatenate
    @return The concatenation of the streams that compose the given stream
*)
val concat_lazy: 'a t t -> 'a t

(**
    [flatten] is an alias of {!concat}
*)
val flatten: 'a t t -> 'a t

(**
    [flatten_lazy] is an alias of {!concat_lazy}
*)
val flatten_lazy: 'a t t -> 'a t

(**
    [iteri] is the same as {!iter}, but [iter_fn] is applied to the index of the element as the first argument and the
    element itself as the second argument
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param iter_fn The iter function to apply to each index-element pair
    @param s       The stream over which to iterate
    @return unit
*)
val iteri: (int -> 'a -> unit) -> 'a t -> unit

(**
    [iter] applies [iter_fn] to each element of the given stream
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param iter_fn The iter function to apply to each element
    @param s       The stream over which to iterate
    @return unit
*)
val iter: ('a -> unit) -> 'a t -> unit

(**
    [combine] transforms the pair of streams [s1] and [s2] into a stream of pairs, ending when one of the streams runs
    out of elements
    @param s1 The stream whose elements each compose the first element in each pair
    @param s2 The stream whose elements each compose the second element in each pair
    @return The stream of pairs composed from the pair of streams [s1] and [s2], ending when one of the streams runs out
    of elements
*)
val combine: 'a t -> 'b t -> ('a * 'b) t

(**
    [combine_long] transforms the pair of streams [s1] and [s2] into a stream of pairs, using placeholder values when
    one of the streams runs out of elements and ending when both streams run out of values
    @param s1    The stream whose elements each compose the first element in each pair
    @param s2    The stream whose elements each compose the second element in each pair
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The stream of pairs composed from the pair of streams [s1] and [s2], using placeholder values when one of
    the streams runs out of elements, ending when both streams run out of values
*)
val combine_long: 'a t -> 'b t -> 'a -> 'b -> ('a * 'b) t

(**
    [iter2] applies the function [iter_fn] to each pair of elements from the given streams, ending when one of the
    streams runs out of elements
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param iter_fn The iter function to apply to each pair of elements
    @param s1      The stream whose elements each compose the first element in each pair that is iterated over
    @param s2      The stream whose elements each compose the second element in each pair that is iterated over
    @return unit
*)
val iter2: ('a -> 'b -> unit) -> 'a t -> 'b t -> unit

(**
    [iter2_long] applies the function [iter_fn] to each pair of elements from the given streams, using placeholder
    values when one of the streams runs out of elements and ending when both streams run out of values
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param iter_fn The iter function to apply to each pair of elements
    @param s1      The stream whose elements each compose the first element in each pair that is iterated over
    @param s2      The stream whose elements each compose the second element in each pair that is iterated over
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return unit
*)
val iter2_long: ('a -> 'b -> unit) -> 'a t -> 'b t -> 'a -> 'b -> unit

(**
    [map2] applies the function [map_fn] to each pair of elements from the given streams and builds a stream with the
    result of mapping each pair of elements using [map_fn], ending when one of the streams runs out of elements
    @param map_fn The mapping function to apply to each pair of elements
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @return The stream created from mapping each pair of elements from the given streams
*)
val map2: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

(**
    [map2_long] applies the function [map_fn] to each pair of elements from the given streams and builds a stream with
    the result of mapping each pair of elements using [map_fn], using placeholder values when one of the streams runs
    out of elements and ending when both streams run out of values
    @param map_fn The mapping function to apply to each pair of elements
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The stream created from mapping each pair of elements from the given streams
*)
val map2_long: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'a -> 'b -> 'c t

(**
    [rev_map2] is equivalent to [rev (map2 map_fn s1 s2)]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param map_fn The mapping function to apply to each pair of elements
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @return The stream created reversing the result of [map2 map_fn s1 s2]
*)
val rev_map2: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t

(**
    [rev_map2_long] is equivalent to [rev (map2_long map_fn s1 s2 s1_pl s2_pl)]
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param map_fn The mapping function to apply to each pair of elements
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The stream created reversing the result of [map2_long map_fn s1 s2]
*)
val rev_map2_long: ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'a -> 'b -> 'c t

(**
    [fold_left2] traverses both streams from left to right, combining each pair of adjacent elements with [acc] using
    [fold_fn] and returns the result of doing so, ending when one of the streams runs out of elements
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param map_fn The mapping function to apply to each pair of elements
    @param acc    The initial value to use as the accumulator with [fold_fn]
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @return The stream created from mapping each pair of elements from the given streams
*)
val fold_left2: ('c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'c

(**
    [fold_left2_lazy] traverses the stream from left to right, combining each element with [acc] using [fold_fn] and
    returns each intermediary result in a stream from [acc] to the result of completely applying [fold_left] to the
    entire stream, ending when one of the streams runs out of elements
    @param map_fn The mapping function to apply to each pair of elements
    @param acc    The initial value to use as the accumulator with [fold_fn]
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @return The stream created from mapping each pair of elements from the given streams
*)
val fold_left2_lazy: ('c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'c t

(**
    [fold_left2_long] traverses both streams from left to right, combining each pair of adjacent elements with [acc]
    using [fold_fn] and returns the result of doing so, using placeholder values when one of the streams runs out of
    elements and ending when both streams run out of values
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param map_fn The mapping function to apply to each pair of elements
    @param acc    The initial value to use as the accumulator with [fold_fn]
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The stream created from mapping each pair of elements from the given streams
*)
val fold_left2_long: ('c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'a -> 'b -> 'c

(**
    [fold_left2_long_lazy] traverses the stream from left to right, combining each element with [acc] using [fold_fn]
    and returns each intermediary result in a stream from [acc] to the result of completely applying [fold_left] to the
    entire stream, using placeholder values when one of the streams runs out of elements and ending when both streams
    run out of values
    @param map_fn The mapping function to apply to each pair of elements
    @param acc    The initial value to use as the accumulator with [fold_fn]
    @param s1     The stream whose elements each compose the first element in each pair that is used in the mapping
    @param s2     The stream whose elements each compose the second element in each pair that is used in the mapping
    @param s1_pl The value to use as a placeholder for [s1] elements if [s1] has less elements than [s2]
    @param s2_pl The value to use as a placeholder for [s2] elements if [s2] has less elements than [s1]
    @return The stream created from mapping each pair of elements from the given streams
*)
val fold_left2_long_lazy: ('c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'a -> 'b -> 'c t

(**
    [for_all] returns [true] if applying [pred] to each elements of the stream results in [true] for all of them
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param pred The predicate that all of the elements are checked against
    @param s    The stream whose elements are checked against the predicate
    @return [true] if all of the elements of the stream each return [true] when put into [pred]
*)
val for_all: ('a -> bool) -> 'a t -> bool

(**
    [exists] returns [true] if applying [pred] to any of the elements of the stream results in [true]
    
    This involves an immediate traversal over all of the elements until an element meeting the predicate is found,
    evaluating each of them, and not terminating on infinite streams in which no element matches the predicate
    @param pred The predicate that all of the elements are checked against
    @param s    The stream whose elements are checked against the predicate
    @return [true] if any of the elements of the stream return [true] when put into [pred]
*)
val exists: ('a -> bool) -> 'a t -> bool

(**
    [for_all2] returns [true] if applying [pred] to each pair of adjacent element pairs from the given streams results
    in [true] for all of them
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param pred The predicate that all of the elements are checked against
    @param s1   The stream whose elements are used as the first argument when checking against the predicate
    @param s2   The stream whose elements are used as the second argument when checking against the predicate
    @return [true] if all of the adjacent elements from the given streams each return [true] when put into [pred]
*)
val for_all2: ('a -> 'b -> bool) -> 'a t -> 'b t -> bool

(**
    [exists2] returns [true] if applying [pred] to any of the adjacent element pairs from the given streams results in
    [true]
    
    This involves an immediate traversal over all of the elements until an element meeting the predicate is found,
    evaluating each of them, and not terminating on infinite streams in which no element matches the predicate
    @param pred The predicate that all of the elements are checked against
    @param s1   The stream whose elements are used as the first argument when checking against the predicate
    @param s2   The stream whose elements are used as the second argument when checking against the predicate
    @return [true] if any of the adjacent element pairs from the given streams return [true] when put into [pred]
*)
val exists2: ('a -> 'b -> bool) -> 'a t -> 'b t -> bool

(**
    [mem] returns [true] if [el] is equal to an element in the given stream
    
    This involves an immediate traversal over all of the elements until an element is found that is equal to the given
    value, evaluating each of them, and not terminating on infinite streams in which no element is equivalent
    @param el The element to search for in the given stream
    @param s  The stream in which to search for [el]
    @return [true] if [el] is equal to an element in the given stream
*)
val mem: 'a -> 'a t -> bool

(**
    [memq] is the same as {!mem} but uses physical equality instead of structural equality to compare elements
    
    This involves an immediate traversal over all of the elements until an element is found that is equal to the given
    value, evaluating each of them, and not terminating on infinite streams in which no element is equivalent
    @param el The element to search for in the given stream
    @param s  The stream in which to search for [el]
    @return [true] if [el] is equal to an element in the given stream
*)
val memq: 'a -> 'a t -> bool

(**
    [find_opt] returns the first element of [s] that satisfies [pred] wrapped in [Some] or returns [None] if there is
    no such element
    
    This involves an immediate traversal over all of the elements until an element meeting the predicate is found,
    evaluating each of them, and not terminating on infinite streams in which no element matches the predicate
    @param pred The predicate that all of the elements are checked against
    @param s    The stream that is searched through for an element that satisfies the predicate
    @return The first element of [s] that satisfies [pred] wrapped in [Some] or returns [None] if there is no such
    element
*)
val find_opt: ('a -> bool) -> 'a t -> 'a option

(**
    [find] returns the first element of [s] that satisfies [pred] or raises [Not_found] if there is no such element
    
    This involves an immediate traversal over all of the elements until an element meeting the predicate is found,
    evaluating each of them, and not terminating on infinite streams in which no element matches the predicate
    @param pred The predicate that all of the elements are checked against
    @param s    The stream that is searched through for an element that satisfies the predicate
    @return The first element of [s] that satisfies [pred]
    @raise Not_found Raised if there is no element that satisfies [pred]
*)
val find: ('a -> bool) -> 'a t -> 'a

(**
    [partition] returns a pair of streams with the first stream being the stream of all the elements of [s] that satisfy
    [pred] and the second being the stream of all the elements of [s] that do not satisfy [pred]; the order of the
    elements in the input list is preserved
    
    This involves an immediate traversal over all of the elements until an element meeting the predicate is found and
    an element not meeting the predicate is found, evaluating each of them, and not terminating on infinite streams in
    which either there are no elements that meet the predicate or all elements meet the predicate
    @param pred The predicate that all of the elements are checked against
    @param s    The stream that is partitioned into elements that do and do not satisfy the predicate
    @return A pair of streams with the first stream being the stream of all the elements of [s] that satisfy the [pred]
    and the second being the stream of all the elements of [s] that do not satisfy [pred]
*)
val partition: ('a -> bool) -> 'a t -> 'a t * 'a t

(**
    [partition_lazy] returns a pair of computationally-delayed streams with the first stream being the stream of all the
    elements of [s] that satisfy [pred] and the second being the stream of all the elements of [s] that do not satisfy
    [pred]; the order of the elements in the input list is preserved
    @param pred The predicate that all of the elements are checked against
    @param s    The stream that is partitioned into elements that do and do not satisfy the predicate
    @return A pair of computationally-delayed streams with the first stream being the stream of all the elements of [s]
    that satisfy [pred] and the second being the stream of all the elements of [s] that do not satisfy [pred]
*)
val partition_lazy: ('a -> bool) -> 'a t -> 'a t lazy_t * 'a t lazy_t

(**
    [assoc_opt] returns the value associated with [el_key] in the stream of pairs [as_s] wrapped in [Some] or [None] if
    there is no value associated with [el_key] in the [as_s]
    
    This involves an immediate traversal over all of the elements until an element with an equivalent key is found,
    evaluating each of them, and not terminating on infinite streams in which no element has an equivalent key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return The value associated with [el_key] in the stream of pairs [as_s] wrapped in [Some] or [None] if there is no
    value associated with [el_key] in the [as_s]
*)
val assoc_opt: 'a -> ('a * 'b) t -> 'b option

(**
    [assoc] returns the value associated with [el_key] in the stream of pairs [as_s] or raises [Not_found] if there is
    no value associated with [el_key] in the [as_s]
    
    This involves an immediate traversal over all of the elements until an element with an equivalent key is found,
    evaluating each of them, and not terminating on infinite streams in which no element has an equivalent key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return The value associated with [el_key] in the stream of pairs [as_s]
    @raise Not_found Raised if there is no value associated with [el_key] in the [as_s]
*)
val assoc: 'a -> ('a * 'b) t -> 'b

(**
    [assq_opt] is the same as {!assoc_opt} but uses physical equality instead of structural equality to compare elements
    
    This involves an immediate traversal over all of the elements until an element with an equivalent key is found,
    evaluating each of them, and not terminating on infinite streams in which no element has an equivalent key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return The value associated with [el_key] in the stream of pairs [as_s] wrapped in [Some] or [None] if there is no
    value associated with [el_key] in the [as_s]
*)
val assq_opt: 'a -> ('a * 'b) t -> 'b option

(**
    [assq] is the same as {!assoc} but uses physical equality instead of structural equality to compare elements
    
    This involves an immediate traversal over all of the elements until an element with an equivalent key is found,
    evaluating each of them, and not terminating on infinite streams in which no element has an equivalent key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return The value associated with [el_key] in the stream of pairs [as_s]
    @raise Not_found Raised if there is no value associated with [el_key] in the [as_s]
*)
val assq: 'a -> ('a * 'b) t -> 'b

(**
    [mem_assoc] returns [true] if there is a value associated with [el_key] in the stream of pairs [as_s] or [false]
    otherwise
    
    This involves an immediate traversal over all of the elements until an element is found that has a key equal to the
    given value, evaluating each of them, and not terminating on infinite streams in which no element has an equivalent
    key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return [true] if there is a value associated with [el_key] in the stream of pairs [as_s] or [false] otherwise
*)
val mem_assoc: 'a -> ('a * 'b) t -> bool

(**
    [mem_assq] is the same as {!mem_assoc} but uses physical equality instead of structural equality to compare elements
    
    This involves an immediate traversal over all of the elements until an element is found that has a key equal to the
    given value, evaluating each of them, and not terminating on infinite streams in which no element has an equivalent
    key
    @param el_key The key that is searched for in the association stream
    @param as_s   The association stream that is searched through
    @return [true] if there is a value associated with [el_key] in the stream of pairs [as_s] or [false] otherwise
*)
val mem_assq: 'a -> ('a * 'b) t -> bool

(**
    [remove_assoc] returns the given stream without the first pair with a key equivalent to [el_key]
    
    This involves an immediate traversal over all of the elements until an element is found that has a key equal to the
    given value, evaluating each of them, and not terminating on infinite streams in which no element has an equivalent
    key
    @param ell_key The key that is searched for in the association stream
    @param as_s    The association stream that is searched through
    @return The given stream without the first pair with a key equivalent to [el_key]
*)
val remove_assoc: 'a -> ('a * 'b) t -> ('a * 'b) t

(**
    [remove_assq] is the same as {!remove_assoc} but uses physical equality instead of structural equality to compare
    elements
    
    This involves an immediate traversal over all of the elements until an element is found that has a key equal to the
    given value, evaluating each of them, and not terminating on infinite streams in which no element has an equivalent
    key
    @param ell_key The key that is searched for in the association stream
    @param as_s    The association stream that is searched through
    @return The given stream without the first pair with a key equivalent to [el_key]
*)
val remove_assq: 'a -> ('a * 'b) t -> ('a * 'b) t

(**
    [split] transforms a stream of pairs into a pair of streams
    @param s The stream of pairs that will be broken apart into a pair of streams
    @return The pair of streams transformed from [s]
*)
val split: ('a * 'b) t -> 'a t * 'b t

(**
    [compare] returns 0 if [s1] is equal to [s2], a negative integer if [s1] is less than [s2], and a positive integer
    if [s1] is greater than [s2]
    
    This involves an immediate traversal over all of the elements of both streams until the end of one of the streams is
    reached or a pair of adjacent elements between the two streams are found to be not equivalent, meaning that this
    function does not terminate on two equivalent infinite streams
    @param compare_fn The comparison function that returns 0 if its arguments compare as equal, a positive integer if
                      the first is greater, and a negative integer if the first is smaller.
    @param s1         The stream on the left side of the comparison
    @param s2         The stream on the right side of the comparison
    @return 0 if [s1] is equal to [s2], a negative integer if [s1] is less than [s2], and a positive integer if [s1] is
    greater than [s2]
*)
val compare: ('a -> 'a -> int) -> 'a t -> 'a t -> int

(**
    [compare] returns [true] if [s1] is equal to [s2]
    
    This involves an immediate traversal over all of the elements of both streams until the end of one of the streams is
    reached or a pair of adjacent elements between the two streams are found to be not equivalent, meaning that this
    function does not terminate on two equivalent infinite streams
    @param equal_fn The comparison function that returns true if its arguments compare as equal
    @param s1       The stream on the left side of the comparison
    @param s2       The stream on the right side of the comparison
    @return [true] if [s1] is equal to [s2]
*)
val equals: ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

(**
    [sort] sorts the given stream in increasing order according to a comparison function. The comparison function must
    return 0 if its arguments compare as equal, a positive integer if the first is greater, and a negative integer if
    the first is smaller. The resulting stream is sorted in increasing order. [sort] is guaranteed to run in constant
    heap space (in addition to the size of the result stream) and logarithmic stack space.
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param compare_fn The comparison function described above
    @param s          The stream to be sorted
    @return The sorted stream in increasing order according to a [compare_fn] function
*)
val sort: ('a -> 'a -> int) -> 'a t -> 'a t

(**
    [stable_sort] is the same as {!sort}, but the sorting algorithm is guaranteed to be stable
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param compare_fn The comparison function as described in {!sort}
    @param s          The stream to be sorted
    @return The sorted stream in increasing order according to a [compare_fn] function
*)
val stable_sort: ('a -> 'a -> int) -> 'a t -> 'a t

(**
    [fast_sort] uses {!sort} or {!stable_sort} depending on which is faster on typical input
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param compare_fn The comparison function as described in {!sort}
    @param s          The stream to be sorted
    @return The sorted stream in increasing order according to a [compare_fn] function
*)
val fast_sort: ('a -> 'a -> int) -> 'a t -> 'a t

(**
    [sort_uniq] is the same as {!sort} but also removes duplicates
    
    This involves an immediate traversal over all of the elements, evaluating each of them before getting to the end,
    and not terminating on infinite streams
    @param compare_fn The comparison function as described in {!sort}
    @param s          The stream to be sorted
    @return The sorted stream in increasing order according to a [compare_fn] function
*)
val sort_uniq: ('a -> 'a -> int) -> 'a t -> 'a t

(**
    [merge] merges two streams. Assuming that [s1] and [s2] are sorted according to the comparison function
    [compare_fn], [merge compare_fn s1 s2] will return a sorted stream containing all the elements of [s1] and [s2].
    If several elements compare equal, the elements of [s1] will be before the elements of [s2].
    @param compare_fn The comparison function  as described in {!sort}
    @param s1         The first of the two streams that will be merged, takes precedence over [s2] when equal
    @param s2         The second of the two streams that will be merged
    @return The result of merging the two given streams
*)
val merge: ('a -> 'a -> int) -> 'a t -> 'a t -> 'a t
