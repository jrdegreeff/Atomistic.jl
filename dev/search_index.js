var documenterSearchIndex = {"docs":
[{"location":"api/#API-Reference","page":"API Reference","title":"API Reference","text":"","category":"section"},{"location":"api/","page":"API Reference","title":"API Reference","text":"This page provides a list of all documented types and functions and in Atomistic.jl. If you are looking for more specifics on the Atomistic API, see the Implementing the Atomistic API page.","category":"page"},{"location":"api/","page":"API Reference","title":"API Reference","text":"Modules = [Atomistic]\nOrder   = [:type, :function]","category":"page"},{"location":"api/#Atomistic.DynamicAtom","page":"API Reference","title":"Atomistic.DynamicAtom","text":"DynamicAtom{D,L<:Unitful.Length,V<:Unitful.Velocity} <: AbstractAtom\n\nAn atom representation based on the StaticAtom but with a velocity.\n\nType parameters\n\nD: the dimension of the coordinate space\nL: the type for the position components\nV: the type for the velocity components\n\nFields should not be accessed directly. Use the provided accessors instead.\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.DynamicSystem","page":"API Reference","title":"Atomistic.DynamicSystem","text":"DynamicSystem{D,AT<:AbstractAtom,L<:Unitful.Length,TT<:Unitful.Time} <: AbstractAtomicSystem{D}\n\nA representation of a system of dynamic atoms which is similar to the FlexibleSystem but with a time field.\n\nType parameters\n\nD: the dimension of the coordinate space\nA: the type for the atoms that make up the system\nL: the type for the bounding box components\nT: the type for time field\n\nFields should not be accessed directly. Use the provided accessors instead.\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.MolecularDynamicsResult","page":"API Reference","title":"Atomistic.MolecularDynamicsResult","text":"MolecularDynamicsResult\n\nAbstract type to be extended by all concrete structs representing the result of a molecular dynamics simulation.\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.MolecularDynamicsSimulator","page":"API Reference","title":"Atomistic.MolecularDynamicsSimulator","text":"MolecularDynamicsSimulator\n\nAbstract type to be extended by all concrete molecular dynamics simulators.\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.NBSResult","page":"API Reference","title":"Atomistic.NBSResult","text":"NBSResult <: MolecularDynamicsResult\n\nThe result generating from running a MolecularDynamicsSimulator.\n\nField descriptions\n\nresult::SimulationResult the standard simulation result from NBodySimulator\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.NBSimulator","page":"API Reference","title":"Atomistic.NBSimulator","text":"NBSimulator <: MolecularDynamicsSimulator\n\nA wrapper around NBodySimulator to implement the Atomistic API.\n\nField descriptions\n\nΔt::Real the time between timesteps, assumed to be in atomic units\nsteps::Integer the number of timesteps for the simulation\nt₀::Real the starting time of the simulation, assumed to be in atomic units;   defaults to 0\nthermostat::Thermostat the thermostat for the simulation;   many options are defined by NBodySimulator, but a user could also define a custom thermostat;   defaults to the NullThermostat\nsimulator::OrdinaryDiffEqAlgorithm the algorithm to be used for the ODE;   defaults to VelocityVerlet\npotentials::Dict{Symbol,PotentialParameters} dictionary of potentials;   shouldn't be manipulated directly by the user\n\n\n\n\n\n","category":"type"},{"location":"api/#Atomistic.get_system","page":"API Reference","title":"Atomistic.get_system","text":"get_system(result::MolecularDynamicsResult, t::Integer = 0)::AbstractSystem\n\nExtract the underlying system at a particular timestep from the simulation result.\n\nAn implementer of this API should implement a method of this function for their custom result type.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.get_time_range-Tuple{MolecularDynamicsResult}","page":"API Reference","title":"Atomistic.get_time_range","text":"get_time_range(result::MolecularDynamicsResult)::Vector{<:Real}\n\nExtract the time range from the simulation result in atomic units.\n\nAn implementer of this API should implement a method of this function for their custom result type.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.kinetic_energy","page":"API Reference","title":"Atomistic.kinetic_energy","text":"kinetic_energy(result::MolecularDynamicsResult, t::Integer = 0)::Real\n\nExtract the kinetic energy of the simulation at a particular timestep from the simulation result in atomic units.\n\nAn implementer of this API should implement a method of this function for their custom result type.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.plot_energy!","page":"API Reference","title":"Atomistic.plot_energy!","text":"plot_energy!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)::Plot\n\nPlot the kinetic, potential, and total energy of a MolecularDynamicsResult against time, sampling every stride points. Add the new lines to an existing plot and update the legend only if it is the first plot. If it is not the first plot, add a vertical line to differentiate the segments of the simulation in the plot.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.plot_energy-Tuple{MolecularDynamicsResult, Integer}","page":"API Reference","title":"Atomistic.plot_energy","text":"plot_energy(result::MolecularDynamicsResult, stride::Integer)::Plot\n\nPlot the kinetic, potential, and total energy of a MolecularDynamicsResult against time, sampling every stride points.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.plot_rdf","page":"API Reference","title":"Atomistic.plot_rdf","text":"plot_rdf(result::MolecularDynamicsResult, σ::Real, sample_fraction::Float64 = 1.0)::Plot\n\nPlot the radial distribution function of a MolecularDynamicsResult sampling only the trailing sample_fraction of the timesteps. Use σ (from Lennard Jones) as a normalization factor for the radius (assumed to be in atomic units).\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.plot_rdf-2","page":"API Reference","title":"Atomistic.plot_rdf","text":"plot_rdf(result::MolecularDynamicsResult, σ::Unitful.Length, sample_fraction::Float64 = 1.0)::Plot\n\nPlot the radial distribution function of a MolecularDynamicsResult sampling only the trailing sample_fraction of the timesteps. Use σ (from Lennard Jones) as a normalization factor for the radius.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.plot_temperature!","page":"API Reference","title":"Atomistic.plot_temperature!","text":"plot_temperature!(p::Plot, result::MolecularDynamicsResult, stride::Integer, first_plot::Bool = false)::Plot\n\nPlot the temperature of a MolecularDynamicsResult against time, sampling every stride points. Add the new line to an existing plot and update the legend only if it is the first plot. If it is not the first plot, add a vertical line to differentiate the segments of the simulation in the plot.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.plot_temperature-Tuple{MolecularDynamicsResult, Integer}","page":"API Reference","title":"Atomistic.plot_temperature","text":"plot_temperature(result::MolecularDynamicsResult, stride::Integer)::Plot\n\nPlot the temperature of a MolecularDynamicsResult against time, sampling every stride points.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.potential_energy","page":"API Reference","title":"Atomistic.potential_energy","text":"potential_energy(result::MolecularDynamicsResult, t::Integer = 0)::Real\n\nExtract the potential energy of the simulation at a particular timestep from the simulation result in atomic units.\n\nAn implementer of this API should implement a method of this function for their custom result type.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.rdf","page":"API Reference","title":"Atomistic.rdf","text":"rdf(result::MolecularDynamicsResult, sample_fraction::Float64 = 1.0)::Tuple{Vector{<:Real},Vector{<:Real}}\n\nCalculate the radial distribution function from the simulation result.\n\nTo include only a trailing portion of the timesteps for reduced noise and faster computation, set sample_fraction to be less than 1.0. The result is a tuple of vectors which represent the radial distances (in atomic units) and the value of the rdf at each distance respectively.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.reference_temperature-Tuple{MolecularDynamicsResult}","page":"API Reference","title":"Atomistic.reference_temperature","text":"reference_temperature(result::MolecularDynamicsResult)::Union{Real,Missing}\n\nExtract the reference temperature of the simulation from the simulation result. If there is no thermostat with a reference temperature in this simulation, return missing.\n\nAn implementer of this API should implement a method of this function for their custom result type if it supports thermostats. If not implmented, the default implemenation just returns missing.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.simulate-Tuple{AtomsBase.AbstractSystem, MolecularDynamicsSimulator, InteratomicPotentials.ArbitraryPotential}","page":"API Reference","title":"Atomistic.simulate","text":"simulate(system::AbstractSystem, simulator::MolecularDynamicsSimulator, potential::ArbitraryPotential)::MolecularDynamicsResult\n\nRun a molecular dynamics simulation configured with a particular simulator and potential with any abstract system.\n\nAn implementer of this API should implement a method of this function for their custom simulator type. If the simulator has a fast path for some types of potential, those should be implemented with multiple dispatch.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.temperature","page":"API Reference","title":"Atomistic.temperature","text":"temperature(result::MolecularDynamicsResult, t::Integer = 0)::Real\n\nExtract the temperature of the simulation at a particular timestep from the simulation result in atomic units.\n\nAn implementer of this API should implement a method of this function for their custom result type.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.total_energy","page":"API Reference","title":"Atomistic.total_energy","text":"total_energy(result::MolecularDynamicsResult, t::Integer = 0)::Real\n\nExtract the total energy of the simulation at a particular timestep from the simulation result in atomic units.\n\nThe default implementation simply sums the kinetic and potential energy at the timestep. An implementer of this API could implement a method of this function for their custom result type if it supports a more efficient way to calculate this quantity.\n\n\n\n\n\n","category":"function"},{"location":"api/#Atomistic.write_ase_trajectory-Tuple{MolecularDynamicsResult, DFTK.Element, Any, String}","page":"API Reference","title":"Atomistic.write_ase_trajectory","text":"write_ase_trajectory(result::MolecularDynamicsResult, element::DFTK.Element, lattice, filename::String)\n\nWrite the trajectory of a MolecularDynamicsResult to a .traj file.\n\nThe file can be visualized by running ase gui <filename> on the command line.\n\n\n\n\n\n","category":"method"},{"location":"api/#Atomistic.write_nbs_animation-Tuple{NBSResult, String}","page":"API Reference","title":"Atomistic.write_nbs_animation","text":"write_nbs_animation(result::NBSResult, filename::String)\n\nAnimate an NBSResult and store the result in a .gif file.\n\n\n\n\n\n","category":"method"},{"location":"usage/#Using-Atomistic-Compatible-Packages","page":"Using Atomistic-Compatible Packages","title":"Using Atomistic-Compatible Packages","text":"","category":"section"},{"location":"usage/","page":"Using Atomistic-Compatible Packages","title":"Using Atomistic-Compatible Packages","text":"TODO","category":"page"},{"location":"extension/#Implementing-the-Atomistic-API","page":"Implementing the Atomistic API","title":"Implementing the Atomistic API","text":"","category":"section"},{"location":"extension/","page":"Implementing the Atomistic API","title":"Implementing the Atomistic API","text":"TODO","category":"page"},{"location":"#[WIP]-Atomistic.jl","page":"Home","title":"[WIP] Atomistic.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Package that provides an integrated workflow for molecular dyanmics simulations. Defines an API for molecular dynamics (MD) simulations that is compatible with the interatomic potential interface defined by Interatomicotentials.jl and the atomic configuration interface defined by AtomsBase.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Developed as part of the CESMIX Julia package suite. See also InteratomicPotentials.jl, PotentialLearning.jl, and PotentialUQ.jl.","category":"page"},{"location":"#Conventions","page":"Home","title":"Conventions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The unit convention throught the package and other packages in the CESMIX Julia package suite is to assume all unspecified units to be atomic units as defined in the UnitfulAtomic package. All exposed interfaces should allow for numeric or unitful input. For clarity's sake, it is strongly recommended that user code utilize unitful wherever possible. Internally, Atomistic will automatically convert these quantities to be compatible without any significant performance penalty.","category":"page"},{"location":"#Next-Steps","page":"Home","title":"Next Steps","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If you want to integrate an existing MD code with the Atomistic API, see Implementing the Atomistic API. If you want to use a code that is already integrated with Atomistic to run MD simulations see Using Atomistic-Compatible Packages.","category":"page"}]
}
