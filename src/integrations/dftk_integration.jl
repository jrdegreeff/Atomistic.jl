# Integrations with DFTK.jl
# This integration should ultimately live within the DFTK package itself

# -----------------------------------------------------------------------------
# Integration with AtomsBase 
# -----------------------------------------------------------------------------

# TODO: should a version of this be integrated into AtomsBase?
# ? Is this logic even correct?
function fractional_position(pos::SVector{3,<:Unitful.Length}, box::SVector{3,<:SVector{3,<:Unitful.Length}})
    [pos[i] / box[i][i] for i ∈ 1:3]
end

# TODO: support multiple species using atom data
function dftk_atoms(system::AbstractSystem{3}, element::DFTK.Element)
    [element => Fix2(fractional_position, bounding_box(system)).(position(system))]
end

# -----------------------------------------------------------------------------
# Integration with InteratomicPotentials
# -----------------------------------------------------------------------------

@kwdef struct DFTKPotential <: ArbitraryPotential
    psp::ElementPsp
    lattice
    Ecut::Real
    kgrid::AbstractVector{<:Integer}
    n_bands::Union{Integer,Nothing} = nothing
    tol::Union{AbstractFloat,Nothing} = nothing
    damping::Union{AbstractFloat,Nothing} = nothing
    mixing::Union{Mixing,Nothing} = nothing
    previous_scfres::RefValue{Any} = Ref{Any}()
    potential_energy_cache::Dict{Float64,Float64} = Dict{Float64,Float64}()
end
function DFTKPotential(
    psp::ElementPsp,
    lattice,
    Ecut::Unitful.Energy,
    kgrid::AbstractVector{<:Integer},
    n_bands::Union{Integer,Nothing} = nothing,
    tol::Union{AbstractFloat,Nothing} = nothing,
    damping::Union{AbstractFloat,Nothing} = nothing,
    mixing::Union{Mixing,Nothing} = nothing,
    previous_scfres::RefValue{Any} = Ref{Any}(),
    potential_energy_cache::Dict{Float64,Float64} = Dict{Float64,Float64}()
)
    DFTKPotential(psp, austrip.(lattice), austrip(Ecut), kgrid, n_bands, tol, damping, mixing, previous_scfres, potential_energy_cache)
end

function InteratomicPotentials.potential_energy(system::AbstractSystem, potential::DFTKPotential)
    calculate_scf(system, potential).energies.total
end

function InteratomicPotentials.potential_energy(system::DynamicSystem, potential::DFTKPotential)
    get!(potential.potential_energy_cache, austrip(system.time)) do
        calculate_scf(system, potential).energies.total
    end
end

function InteratomicPotentials.force(system::AbstractSystem, potential::DFTKPotential)
    # TODO: support multiple species
    compute_forces_cart(calculate_scf(system, potential))[1]
end

function InteratomicPotentials.force(system::DynamicSystem, potential::DFTKPotential)
    scf = calculate_scf(system, potential)
    potential.potential_energy_cache[austrip(system.time)] = scf.energies.total
    # TODO: support multiple species
    compute_forces_cart(scf)[1]
end

function calculate_scf(system::AbstractSystem, potential::DFTKPotential)
    model = model_LDA(potential.lattice, dftk_atoms(system, potential.psp))
    basis = PlaneWaveBasis(model; Ecut = potential.Ecut, kgrid = potential.kgrid)

    extra_args = isassigned(potential.previous_scfres) ? (ψ = potential.previous_scfres[].ψ, ρ = potential.previous_scfres[].ρ) : (;)
    scfres = self_consistent_field(basis; extra_args..., (f => getfield(potential, f) for f ∈ (:n_bands, :tol, :damping, :mixing) if getfield(potential, f) !== nothing)...)
    potential.previous_scfres[] = scfres
end

# -----------------------------------------------------------------------------
# Miscelaneous functions
# -----------------------------------------------------------------------------

function analyze_convergence(system::AbstractSystem, potential::DFTKPotential, cutoffs::AbstractVector{<:Unitful.Energy})
    energies = Vector{Float64}()
    for Ecut ∈ cutoffs
        parameters = DFTKPotential(
            psp = potential.psp,
            lattice = potential.lattice,
            Ecut = Ecut,
            kgrid = potential.kgrid,
            n_bands = potential.n_bands,
            tol = potential.tol,
            damping = potential.damping,
            mixing = potential.mixing
        )
        @info "Ecut: $(Ecut)"
        scfres = calculate_scf(system, parameters)
        push!(energies, scfres.energies.total)
    end

    plot(
        title = "DFTK Analysis",
        xlab = "Ecut",
        ylab = "Total Energy",
        legend = false,
        cutoffs,
        energies * ENERGY_UNIT
    )
end