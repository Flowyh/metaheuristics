# Strojenie pszczol dla random danych:

# # 1. Ilosc pszczol a ilosc nodeow ~3.3h
# julia main.jl hardcoded 10   time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 20   time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 50   time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 80   time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 100  time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 200  time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 500  time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 2000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 5000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean

# # 2. limit kwiatkow a ilosc nodeow ~3.5h 
# julia main.jl hardcoded 1000 time 90 100 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 500 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 5000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 20000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 50000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 90 100000 invert roulette 0 n 1 100 100 2000 euclidean

# # 3. limit kwiatkow a ilosc pszczol ~4h
# julia main.jl hardcoded 100 time 120 100 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 200 time 120 500 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 500 time 120 5000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 120 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 2000 time 120 20000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 5000 time 120 50000 invert roulette 0 n 1 100 100 2000 euclidean

# # 4. PRD a rodzaj selekcji ~2h
# julia main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert tournament 0.1 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert tournament 0.2 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert tournament 0.3 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert tournament 0.4 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert tournament 0.5 n 1 100 100 2000 euclidean

# # 5. PRD rodzaj swarmu ~2.3h
# julia main.jl hardcoded 1000 time 60 10000 swap roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 insert roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 random roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 "20,50,30" roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 "30,40,30" roulette 0 n 1 100 100 2000 euclidean
# julia main.jl hardcoded 1000 time 60 10000 "10,60,30" roulette 0 n 1 100 100 2000 euclidean

# # 6. PRD Ilosc threadow a liczba nodeow ~2h
# julia --threads 1 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 3000 euclidean
# julia --threads 2 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 3000 euclidean
# julia --threads 4 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 3000 euclidean
# julia --threads 8 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 3000 euclidean

# # 7. PRD Ilosc threadow a liczba pszczol (stala liczba nodeow, rozne problemy randomowe ~4h
# julia --threads 1 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 2 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 4 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 8 main.jl hardcoded 1000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean

# julia --threads 1 main.jl hardcoded 5000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 2 main.jl hardcoded 5000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 4 main.jl hardcoded 5000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 8 main.jl hardcoded 5000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean

# julia --threads 1 main.jl hardcoded 10000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 2 main.jl hardcoded 10000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 4 main.jl hardcoded 10000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean
# julia --threads 8 main.jl hardcoded 10000 time 60 10000 invert roulette 0 n 1 100 100 2000 euclidean

# # Porownanie z innymi:
# julia main.jl hardcoded 10 time 120 50 invert roulette 0.1 all 50 100 100 1000 euclidean
julia main.jl hardcoded 1000 iteration 2000 100000 invert roulette 0.1 all 50 100 100 1000 euclidean

# Porownanie z TabuSearch
julia main.jl random 1000 iteration 2000 10000 invert roulette 0.1 tabu 1 100 100 1000 euclidean

# Porownanie z TabuSearch (Threaded)
julia --threads 4 main.jl random 1000 iteration 2000 10000 invert roulette 0.1 tabu 1 100 100 2000 euclidean

julia main.jl random 1000 time 120 10000 invert roulette 0.1 tabu 1 100 100 1000 euclidean