defmodule Awwfun do

  def test do
    map = %{:a => 1, :b => 2, :c => 3}
    map_pipe(map)   ## map values are not changed, so store the output in new value 'new_map'
    test_pm(map)
    test_pm1(map)
  end


# iex(1)> %{name: "raju"} == %{:name => "raju"} 
# true

## ============================================================
##%{a: 11, b: 22, c: 3} // update values
  def map_pipe(map) do
    map
    |> Map.put(:a, 11)
    |> Map.put(:b, 22) 
    |> Map.merge(%{:c => 13})
    |> Map.merge(%{d: 45}) 
  end


## ============================================================
##method 1 pattern matching function of empty map
  def test_pm(map) when map == %{} do
  	%{}
  end
  def test_pm(map) do
  	map |> Map.merge(%{:name => "rajj"})
  end

## ============================================================
## method 2 pattern matching function of empty map  using map_size/1

def test_pm1(map) when map_size(map) == 0 do
    %{}
  end

  def test_pm1(map) when map_size(map) == 1 do
    map |> Map.merge(%{:name => "rajj"})
  end

  def test_pm1(map) do
    map |> Map.merge(%{ final: "map_data"})
  end


  def datetime do
    DateTime.to_string(DateTime.utc_now())
  end


## ============================================================

end





