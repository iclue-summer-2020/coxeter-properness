#r "nuget: LZMA-SDK, 19.0.0"
#r "nuget: pythonnet, 3.0.0-preview2021-06-04"


open Python.Runtime

Py.Import("..proper.sage.py")

type Word = {
    family: char;
    elements: list<int>;
}

let rec choose =
    let mutable cache = Map.empty
    let recComp = function
        | (_, 0) -> 1
        | (0, _) -> 0
        | (n, k) -> choose (n-1) k + choose (n-1) (k-1)
    let memo n k =
        match cache |> Map.tryFind (n, k) with
        | Some ans -> ans
        | None ->
            let ans = recComp (n, k)
            cache <- cache |> Map.add (n, k) ans
            ans
    memo
    

module CoxeterGroup =
    /// O(n)
    let rank = List.length
    
    /// O(n^2) run time
    let rec length = function
    | [] -> 0
    | hd::tail ->
        let acc = tail |> List.sumBy (fun x -> System.Convert.ToInt32 (hd > x))
        acc + length tail
    
    let rec descents = function
    | [] | [_] -> 0
    | a::b::tl -> 1

    let maxW0 word =
        let d = descents word
    let proper word =
        let n = rank word
        let l = length word
        let m = maxw0 word
        l <= n + m

[1; 2; 3; 4]
|> List.map (fun x -> pown x 2)
printfn "Hi"