struct MetaGraph{Vertex <: Integer, InnerGraph, AtVertex, AtEdge, GraphMeta, WeightFunction, Weight <: Real} <: AbstractMetaGraph{Vertex, InnerGraph, AtVertex, AtEdge, GraphMeta, WeightFunction, Weight}
    inner_graph::InnerGraph
    vertex_meta::Dict{Vertex, AtVertex}
    edge_meta::Dict{Edge{Vertex}, AtEdge}
    graph_meta::GraphMeta
    weight_function::WeightFunction
    default_weight::Weight
end

"""
    meta_graph(inner_graph;
        AtVertex = nothing,
        AtEdge = nothing,
        graph_meta = nothing,
        weight_function = edge_meta -> 1.0,
        default_weight = 1.0
    )

Construct a new meta graph based on `inner_graph`, where `AtVertex` is the type
of the metadata at a vertex, and `AtEdge` is the type of the metadata at an
edge. You can also attach arbitrary graph level metadata as `graph_meta`.

```jldoctest example
julia> using LightGraphs

julia> using MetaGraphs

julia> colors = meta_graph(Graph(), AtVertex = Symbol, AtEdge = Symbol)
Meta graph based on a {0, 0} undirected simple Int64 graph with Symbol(s) at vertices, Symbol(s) at edges, Nothing metadata, Float64 weights, and default weight 1.0
```

Use `push!` to add a new vertex with the given metadata. `push!` will return
the vertex number of the new vertex. Note that you can associate the same
metadata with multiple vertices.

```jldoctest example
julia> push!(colors, :red)
1

julia> push!(colors, :blue)
2

julia> push!(colors, :yellow)
3
```

You can access and change the metadata at a vertex using indexing:

```jldoctest example
julia> colors[1] = :scarlet;

julia> colors[1]
:scarlet
```

You can access and change the metadata at an edge using indexing:

```jldoctest example
julia> colors[Edge(1, 2)] = :orange;

julia> colors[Edge(1, 2)]
:orange
```

You can delete vertices and edges with `delete!`.

```jldoctest example
julia> delete!(colors, Edge(1, 2));

julia> delete!(colors, 3)
```

!!! warning "Vertex number reassignment"
    Deleting a vertex might result in MetaGraphs reassigning a vertex number. If
    so, `delete!` will return a pair showing the reassignment.

```jldoctest example
julia> delete!(colors, 1)
2 => 1

julia> filter_vertices(colors, isequal(:blue))
1-element Array{Int64,1}:
 1
```

You can use the `weight_function` keyword to specify a function which will
transform vertex metadata into a weight. This weight must always be the same
type as the `default_weight`.

```jldoctest example
julia> weighted = meta_graph(Graph(), AtEdge = Float64, weight_function = identity)
Meta graph based on a {0, 0} undirected simple Int64 graph with Nothing(s) at vertices, Float64(s) at edges, Nothing metadata, Float64 weights, and default weight 1.0

julia> push!(weighted, nothing); push!(weighted, nothing); push!(weighted, nothing);

julia> weighted[Edge(1, 2)] = 1.0;

julia> weighted[Edge(2, 3)] = 2.0;

julia> diameter(weighted)
3.0
```
"""
function meta_graph(inner_graph::AbstractGraph{Vertex};
    AtVertex = Nothing,
    AtEdge = Nothing,
    graph_meta = nothing,
    weight_function = edge_meta -> 1.0,
    default_weight = 1.0
) where {Vertex}
    MetaGraph(
        inner_graph,
        Dict{Vertex, AtVertex}(),
        Dict{Edge{Vertex}, AtEdge}(),
        graph_meta,
        weight_function,
        default_weight
    )
end

SimpleGraph(g::MetaGraph) = g.graph

is_directed(::Type{<: MetaGraph}) = false

maybe_order_edge(::MetaGraph, edge) =
    if is_ordered(edge)
        edge
    else
        reverse(edge)
    end