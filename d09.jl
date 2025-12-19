using Pipe

parse_input(input::AbstractString) = @pipe input |> chomp |> split .|> split(_, ",") .|> parse.(Int, _)

area(a::Vector{Int}, b::Vector{Int})::Int = (a .- b) .|> abs .|> (x -> x + 1) |> prod

p1(input::Vector{Vector{Int}})::Int =
  [area(input[idx1], input[idx2]) for idx1 in eachindex(input) for idx2 in eachindex(input) if idx1 < idx2] |> maximum


function is_vertical_edge(edge::Vector{Vector{Int}})::Bool
  if length(edge) != 2
    error("An edge must have exactly 2 points")
  end

  edge[1][1] == edge[2][1]
end

function is_horizontal_edge(edge::Vector{Vector{Int}})::Bool
  if length(edge) != 2
    error("An edge must have exactly 2 points")
  end

  edge[1][2] == edge[2][2]
end

function edge_by_edge(corners::Vector{Vector{Int}})
  (idx < length(corners) ? [corners[idx], corners[idx+1]] : [corners[idx], corners[1]] for idx in eachindex(corners))
end

struct Polygon
  corners::Vector{Vector{Int}}

  # for point-in-polygon tests
  vertical_edges_asc_y_min::Vector{@NamedTuple{x::Int, y_min::Int, y_max::Int}}

  # for edge intersection checks
  horizontal_edges_by_y::Dict{Int,Vector{@NamedTuple{x_min::Int, x_max::Int}}}
  vertical_edges_by_x::Dict{Int,Vector{@NamedTuple{y_min::Int, y_max::Int}}}

  function Polygon(corners::Vector{Vector{Int}})
    edges = edge_by_edge(corners) |> collect

    vertical_edges_asc_y_min = @pipe (
      edges
      |> filter(is_vertical_edge, _)
      |> map(edge -> (x=edge[1][1], y_min=min(edge[1][2], edge[2][2]), y_max=max(edge[1][2], edge[2][2])), _)
      |> sort(_, by=x -> x.y_min)
      |> collect
    )

    horizontal_edges_by_y = @pipe (
      edges
      |> filter(is_horizontal_edge, _)
      |> map(edge -> Dict(edge[1][2] => [(x_min=min(edge[1][1], edge[2][1]), x_max=max(edge[1][1], edge[2][1]))]), _)
      |> reduce((d1, d2) -> mergewith(vcat, d1, d2), _)
    )

    vertical_edges_by_x = @pipe (
      edges
      |> filter(is_vertical_edge, _)
      |> map(edge -> Dict(edge[1][1] => [(y_min=min(edge[1][2], edge[2][2]), y_max=max(edge[1][2], edge[2][2]))]), _)
      |> reduce((d1, d2) -> mergewith(vcat, d1, d2), _)
    )

    new(corners, vertical_edges_asc_y_min, horizontal_edges_by_y, vertical_edges_by_x)
  end
end

function contains_point(polygon::Polygon, point::Vector{Int})::Bool
  x, y = point
  intersections = 0

  # points on horizontal edges should be included
  if @pipe get(polygon.horizontal_edges_by_y, y, []) |> any(edge -> edge.x_min <= x <= edge.x_max, _)
    return true
  end

  # points on vertical edges should be included, all other included points will have 
  # an odd number of intersections with vertical edges
  for edge in polygon.vertical_edges_asc_y_min
    if y >= edge.y_min && y <= edge.y_max
      if edge.x == x
        return true
      elseif edge.x > x
        intersections += 1
      end
    end
  end

  intersections % 2 == 1
end

function intersects_edge(polygon::Polygon, edge::Vector{Vector{Int}})::Bool
  x, y = edge[1], edge[2]

  if is_vertical_edge(edge)
    @pipe get(polygon.horizontal_edges_by_y, y, []) |> any(
      polygon_edge -> polygon_edge.x_min < x < polygon_edge.x_max, _
    )
  elseif is_horizontal_edge(edge)
    @pipe get(polygon.vertical_edges_by_x, x, []) |> any(
      polygon_edge -> polygon_edge.y_min < y < polygon_edge.y_max, _
    )
  else
    error("An edge must be vertical or horizontal")
  end
end


function all_rect_corners(c1::Vector{Int}, c2::Vector{Int})::Vector{Vector{Int}}
  x1, y1 = c1
  x2, y2 = c2
  [
    [x1, y1],
    [x2, y1],
    [x2, y2],
    [x1, y2]
  ]
end

function is_rect_inside_polygon(polygon::Polygon, rect::Vector{Vector{Int}})::Bool
  corners = all_rect_corners(rect[1], rect[2])
  edges = corners |> edge_by_edge |> collect

  all(corner -> contains_point(polygon, corner), corners) && !any(edge -> intersects_edge(polygon, edge), edges)
end

function color(polygon::Polygon, point::Vector{Int})::Union{Symbol,Nothing}
  if point in polygon.corners
    :red
  elseif contains_point(polygon, point)
    :green
  else
    nothing
  end
end

function p2(input::Vector{Vector{Int}})::Int
  polygon = Polygon(input)
  (area(input[idx1], input[idx2])
   for idx1 in eachindex(input) for idx2 in eachindex(input)
   if idx1 < idx2 && is_rect_inside_polygon(polygon, [input[idx1], input[idx2]])
  ) |> maximum
end


test_input = """
             7,1
             11,1
             11,7
             9,7
             9,5
             2,5
             2,3
             7,3
             """ |> parse_input

input = read("inputs/d09.txt", String) |> parse_input

@assert area([2, 5], [9, 7]) == 24
@assert area([7, 1], [11, 7]) == 35
@assert area([7, 3], [2, 3]) == 6
@assert area([2, 5], [11, 1]) == 50
@assert area([7, 3], [11, 1]) == 15
@assert area([9, 7], [9, 5]) == 3
@assert area([9, 5], [2, 3]) == 24

test_polygon = Polygon(test_input)
@assert all(@pipe [[[7, 3], [11, 1]], [[9, 7], [9, 5]], [[9, 5], [2, 3]]] .|> is_rect_inside_polygon(test_polygon, _))
@assert @pipe test_polygon.corners |> color.((test_polygon,), _) |> all(==(:red), _)
@assert @pipe [[8, 1], [9, 1], [10, 1], [7, 2], [3, 3]] |> color.((test_polygon,), _) |> all(==(:green), _)


@assert p1(test_input) == 50
@assert @show @time p1(input) == 4758121828

@assert p2(test_input) == 24
p2(input)
# 4758121828 is too high
# 4730060646 is too high
