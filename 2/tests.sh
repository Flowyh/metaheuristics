# # Different moves (invert, insert, swap)
# julia main.jl hardcoded 2opt invert iteration 1000 7 1 15 100 "n" 1
# julia main.jl hardcoded 2opt insert iteration 1000 7 1 15 100 "n" 1
# julia main.jl hardcoded 2opt swap iteration 1000 7 1 15 100 "n" 1

# # Different tabuSize with invert (7, /2, /3)
# julia main.jl hardcoded 2opt invert iteration 1000 7 1 15 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 15 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div3 1 15 100 "n" 1

# # Different backtrackSize with invert, tabu div2, (15, /2, /3)
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 15 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div2 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div3 100 "n" 1

# # Different stagnation with invert, tabu div2, backtrack div2, limit (10%, 20%, 5%, manualy chosen)
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div2 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div2 200 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div2 50 "n" 1

# # Different aspiration with invert, tabu div2, backtrack div2, stagnation 10%, (1%, 3%, 5%)
# julia main.jl hardcoded 2opt invert iteration 1000 div2 1 div2 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 3 div2 100 "n" 1
# julia main.jl hardcoded 2opt invert iteration 1000 div2 5 div2 100 "n" 1

# # Random thread tests
# julia --threads 1 main.jl random 2opt invert iteration 500 div2 1 div2 50 "n" 1 100 100 500 euclidean
julia --threads 2 main.jl random 2opt invert iteration 500 div2 1 div2 50 "n" 1 100 100 500 euclidean
julia --threads 4 main.jl random 2opt invert iteration 500 div2 1 div2 50 "n" 1 100 100 500 euclidean
julia --threads 8 main.jl random 2opt invert iteration 500 div2 1 div2 50 "n" 1 100 100 500 euclidean
julia --threads 10 main.jl random 2opt invert iteration 500 div2 1 div2 50 "n" 1 100 100 500 euclidean

