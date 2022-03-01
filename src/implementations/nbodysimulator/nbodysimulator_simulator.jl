# -----------------------------------------------------------------------------
# Implementation of Atomistic MolecularDynamicsSimulator API
# -----------------------------------------------------------------------------

"""
    NBSimulator <: MolecularDynamicsSimulator

A wrapper around NBodySimulator to implement the Atomistic API.

**Type parameter descriptions**
- `S` the type of ODE solver
- `T<:Unitful.Time` the type for the time fields
- `C` the type for the thermostat field

**Field descriptions**
- `Δt::T` the time between timesteps, assumed to be in atomic units
- `steps::Integer` the number of timesteps for the simulation
- `t₀::T` the starting time of the simulation, assumed to be in atomic units;
    defaults to 0
- `thermostat::C` the thermostat for the simulation;
    many options are defined by `NBodySimulator`, but a user could also define a custom thermostat;
    defaults to the `NullThermostat`
- `simulator::S` the algorithm to be used for the ODE;
    defaults to VelocityVerlet
- `potentials::Dict{Symbol,PotentialParameters}` dictionary of potentials;
    shouldn't be manipulated directly by the user
"""
struct NBSimulator{S<:OrdinaryDiffEqAlgorithm,T<:Unitful.Time,C<:Thermostat} <: MolecularDynamicsSimulator
    Δt::T
    steps::Int
    t₀::T
    thermostat::C
    simulator::S
    potentials::Dict{Symbol,PotentialParameters}
end
function NBSimulator(Δt::T, steps::Int; t₀::Real = zero(T), thermostat::C = NullThermostat(), simulator::S = NBodySimulator.VelocityVerlet()) where {S<:OrdinaryDiffEqAlgorithm,T<:Real,C<:Thermostat}
    Δt, t₀ = promote(Δt * TIME_UNIT, t₀ * TIME_UNIT)
    NBSimulator(Δt, steps, t₀, thermostat, simulator, Dict{Symbol,PotentialParameters}())
end
function NBSimulator(Δt::T, steps::Integer; t₀::Unitful.Time = zero(T), thermostat::C = NullThermostat(), simulator::S = NBodySimulator.VelocityVerlet()) where {S<:OrdinaryDiffEqAlgorithm,T<:Unitful.Time,C<:Thermostat}
    Δt, t₀ = promote(Δt, t₀)
    NBSimulator(Δt, steps, t₀, thermostat, simulator, Dict{Symbol,PotentialParameters}())
end

# Extract the tuple of start_time, end_time from the simulator
time_range(simulator::NBSimulator) = Float64.(austrip.((simulator.t₀, simulator.t₀ + simulator.steps * simulator.Δt)))

function simulate(system::AbstractSystem{3}, simulator::NBSimulator, potential::ArbitraryPotential)
    wrapper = InteratomicPotentialParameters(potential)
    simulator.potentials[:custom] = wrapper
    result = simulate(system, simulator)
    NBSResult(result, wrapper.energy_cache)
end
function simulate(system::AbstractSystem{3}, simulator::NBSimulator, potential::LennardJonesParameters)
    simulator.potentials[:lennard_jones] = potential
    result = simulate(system, simulator)
    NBSResult(result, [NBodySimulator.potential_energy(result, t) for t ∈ result.solution.t])
end
function simulate(system::AbstractSystem{3}, simulator::NBSimulator)
    nb_system = PotentialNBodySystem{ElementMassBody}(get_bodies(system), simulator.potentials)
    simulation = NBodySimulation(nb_system, time_range(simulator), nbs_boundary_conditions(system), simulator.thermostat, austrip(u"k"))
    run_simulation(simulation, simulator.simulator, dt = austrip(simulator.Δt))
end

# -----------------------------------------------------------------------------
# Integration with InteratomicPotentials
# -----------------------------------------------------------------------------

# Internal struct that represents a potential in the format accepted by NBodySimulator
# Wraps the underlying InteratomicPotential with a cache of the forces for the current timestep
# Also stores the potential energy from every timestep to be referenceable after the simulation
struct InteratomicPotentialParameters{P<:ArbitraryPotential} <: PotentialParameters
    potential::P
    timestep_cache::Ref{Float64}
    force_cache::Ref{Vector{SVector{3,Float64}}}
    energy_cache::Vector{Float64}
    InteratomicPotentialParameters(potential::ArbitraryPotential) = new{typeof(potential)}(potential, Ref{Float64}(), Ref{Vector{SVector{3,Float64}}}(), Vector{Float64}())
end

function NBodySimulator.get_accelerating_function(parameters::InteratomicPotentialParameters, simulation::NBodySimulation)
    bodies = simulation.system.bodies
    boundary_conditions = simulation.boundary_conditions
    (dv, u, v, t, i) -> begin
        if !isassigned(parameters.timestep_cache) || t != parameters.timestep_cache[]
            particles = [ElementMassBody(bodies[i], SVector{3}(u[:, j]), SVector{3}(v[:, j])) for j ∈ 1:length(bodies)]
            system = FlexibleSystem(particles, boundary_conditions)
            eandf = energy_and_force(system, parameters.potential)
            parameters.timestep_cache[] = t
            parameters.force_cache[] = eandf.f
            push!(parameters.energy_cache, eandf.e)
        end
        dv .+= parameters.force_cache[][i] / bodies[i].m
    end
end

# -----------------------------------------------------------------------------
# Unitful Support for Built-in LennardJonesParameters
# -----------------------------------------------------------------------------

function NBodySimulator.LennardJonesParameters(ϵ::Unitful.Energy, σ::Unitful.Length, R::Unitful.Length)
    LennardJonesParameters(austrip(ϵ), austrip(σ), austrip(R))
end