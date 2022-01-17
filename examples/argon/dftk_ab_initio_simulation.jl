# Based on this guide: https://ase.tufts.edu/chemistry/lin/images/FortranMD_TeachersGuide.pdf
# Uses DFTK in place of LJ for the production stage as a proof-of-concept ab initio MD simulation
# Note that the choice of parameters is for demonstration purposes, and the results are non-physical

using Atomistic
using AtomsBase
using DFTK
using NBodySimulator
using Unitful
using UnitfulAtomic

setup_threading(n_blas = 4)

N = 8
element = :Ar
box_size = 1.5u"nm" # this number was chosen arbitrarily
reference_temp = 94.4u"K"
thermostat_prob = 0.1 # this number was chosen arbitrarily
Δt = 1e-2u"ps"

initial_bodies = generate_bodies_in_cell_nodes(N, element, box_size, reference_temp)
initial_system = FlexibleSystem(initial_bodies, CubicPeriodicBoundaryConditions(austrip(box_size)))

eq_steps = 20000
eq_thermostat = AndersenThermostat(austrip(reference_temp), thermostat_prob / austrip(Δt))
eq_simulator = NBSimulator(Δt, eq_steps, thermostat = eq_thermostat)
potential = LennardJonesParameters(1.657e-21u"J", 0.34u"nm", 0.765u"nm")

eq_result = @time simulate(initial_system, eq_simulator, potential)

display(@time plot_temperature(eq_result, eq_simulator.steps ÷ 200))
display(@time plot_energy(eq_result, eq_simulator.steps ÷ 200))
display(@time plot_rdf(eq_result, potential.σ, 0.5))

ab_initio_steps = 200
ab_initio_simulator = NBSimulator(Δt, ab_initio_steps, t₀ = get_time_range(eq_result)[end])
dftk_potential = DFTKPotential(
    psp = ElementPsp(:Ar, psp = load_psp(list_psp(:Ar, functional = "lda")[1].identifier)),
    lattice = box_size * [[1.0 0 0]; [0 1.0 0]; [0 0 1.0]],
    Ecut = 5u"hartree", # very non-physical but fast for demonstration purposes
    kgrid = [1, 1, 1],
    damping = 0.7,
    mixing = LdosMixing()
)

ab_initio_result = @time simulate(get_system(eq_result), ab_initio_simulator, dftk_potential)

# Plotting on separate plots because the timespan is so much smaller than in the first phase
display(plot_temperature(ab_initio_result, 1))
display(plot_energy(ab_initio_result, 1))
display(@time plot_rdf(ab_initio_result, potential.σ))

write_nbs_animation(ab_initio_result, "artifacts/argon_ab_initio.gif")
write_ase_trajectory(ab_initio_result, dftk_potential.psp, dftk_potential.lattice, "artifacts/argon_ab_initio.traj")

;