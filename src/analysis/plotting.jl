# Functions for plotting molecular dynamics simulation results

PLOTTING_TIME_UNIT = u"ps"
PLOTTING_TEMP_UNIT = u"K"
PLOTTING_ENERGY_UNIT = u"hartree"

# Extract (timestep, time) tuples at stride intervals from a simulation result
function plotting_time_range(result::MolecularDynamicsResult, stride::Integer)
    [(t, uconvert(PLOTTING_TIME_UNIT, time)) for (t, time) ∈ enumerate(get_time_range(result)) if (t - 1) % stride == 0]
end

"""
    plot_temperature(result::MolecularDynamicsResult, stride::Integer)::Plot

Plot the temperature of a `MolecularDynamicsResult` against time, sampling every `stride` points.
"""
function plot_temperature(result::MolecularDynamicsResult, stride::Integer)
    N = length(get_system(result))
    p = plot(
        title = "Temperature during Simulation [n = $(N)]",
        xlab = "Time",
        ylab = "Temperature",
    )
    plot_temperature!(p, result, stride, true)
end
"""
    plot_temperature!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)::Plot

Plot the temperature of a `MolecularDynamicsResult` against time, sampling every `stride` points.
Add the new line to an existing plot and update the legend only if it is the first plot.
If it is not the first plot, add a vertical line to differentiate the segments of the simulation in the plot.
"""
function plot_temperature!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)
    time_range = plotting_time_range(result, stride)
    if (!first_plot)
        vline!(
            p,
            [time_range[1][2]],
            label = false,
            color = :black,
            linestyle = :dot,
            lw = 2
        )
    end
    plot!(
        p,
        [time for (t, time) ∈ time_range],
        [uconvert(PLOTTING_TEMP_UNIT, temperature(result, t)) for (t, time) ∈ time_range],
        label = first_plot ? "Simulation Temperature" : nothing,
        color = 1,
    )
    reference_temp = uconvert(PLOTTING_TEMP_UNIT, reference_temperature(result))
    if (!ismissing(reference_temp))
        plot!(
            p,
            [time for (t, time) ∈ time_range],
            [reference_temp for (t, time) ∈ time_range],
            label = first_plot ? "Reference Temperature" : nothing,
            color = 2,
            linestyle = :dash,
            lw = 2
        )
    end
    p
end

"""
    plot_energy(result::MolecularDynamicsResult, stride::Integer)::Plot

Plot the kinetic, potential, and total energy of a `MolecularDynamicsResult` against time, sampling every `stride` points.
"""
function plot_energy(result::MolecularDynamicsResult, stride::Integer)
    N = length(get_system(result))
    p = plot(
        title = "Energy during Simulation [n = $(N)]",
        xlab = "Time",
        ylab = "Energy",
        legend = :right
    )
    plot_energy!(p, result, stride, true)
end
"""
    plot_energy!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)::Plot

Plot the kinetic, potential, and total energy of a `MolecularDynamicsResult` against time, sampling every `stride` points.
Add the new lines to an existing plot and update the legend only if it is the first plot.
If it is not the first plot, add a vertical line to differentiate the segments of the simulation in the plot.
"""
function plot_energy!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)
    time_range = plotting_time_range(result, stride)
    if (!first_plot)
        vline!(p, [time_range[1][2]], label = false, color = :black, linestyle = :dot, lw = 2)
    end
    plot!(
        p,
        [time for (t, time) ∈ time_range],
        [uconvert(PLOTTING_ENERGY_UNIT, kinetic_energy(result, t)) for (t, time) ∈ time_range],
        label = first_plot ? "Kinetic Energy" : nothing,
        color = 2
    )
    plot!(
        p,
        [time for (t, time) ∈ time_range],
        [uconvert(PLOTTING_ENERGY_UNIT, potential_energy(result, t)) for (t, time) ∈ time_range],
        label = first_plot ? "Potential Energy" : nothing,
        color = 1
    )
    plot!(
        p,
        [time for (t, time) ∈ time_range],
        [uconvert(PLOTTING_ENERGY_UNIT, total_energy(result, t)) for (t, time) ∈ time_range],
        label = first_plot ? "Total Energy" : nothing,
        color = 3
    )
end

"""
    plot_rdf(result::MolecularDynamicsResult, σ::Real, sample_fraction::Float64 = 1.0)::Plot

Plot the radial distribution function of a `MolecularDynamicsResult` sampling only the trailing `sample_fraction` of the timesteps.
Use σ (from Lennard Jones) as a normalization factor for the radius (assumed to be in atomic units).
"""
function plot_rdf(result::MolecularDynamicsResult, σ::Real, sample_fraction::Float64 = 1.0)
    plot_rdf(result, σ * LENGTH_UNIT, sample_fraction)
end
"""
    plot_rdf(result::MolecularDynamicsResult, σ::Unitful.Length, sample_fraction::Float64 = 1.0)::Plot

Plot the radial distribution function of a `MolecularDynamicsResult` sampling only the trailing `sample_fraction` of the timesteps.
Use σ (from Lennard Jones) as a normalization factor for the radius.
"""
function plot_rdf(result::MolecularDynamicsResult, σ::Unitful.Length, sample_fraction::Float64 = 1.0)
    @assert 0 < sample_fraction ≤ 1
    N = length(get_system(result))
    T = length(get_time_range(result)) - 1
    rs, grf = rdf(result, sample_fraction)
    @assert length(rs) == length(grf)
    plot(
        title = "Radial Distribution Function [n = $(N)] [T = $(T)]",
        xlab = "Distance r/σ",
        ylab = "Radial Distribution g(r)",
        legend = false
    )
    plot!(rs / austrip(σ), grf)
end
