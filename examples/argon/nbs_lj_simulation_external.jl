# Based on this guide: https://ase.tufts.edu/chemistry/lin/images/FortranMD_TeachersGuide.pdf

using Atomistic
using InteratomicPotentials
using NBodySimulator
using Plots

N = 864
element = :Ar
box_size = 3.47786u"nm"
reference_temp = 94.4u"K"
thermostat_prob = 0.1 # this number was chosen arbitrarily
Δt = 1e-2u"ps"

initial_system = generate_atoms_in_cubic_cell(N, element, box_size, reference_temp)

eq_steps = 2000
eq_thermostat = NBodySimulator.AndersenThermostat(austrip(reference_temp), thermostat_prob / austrip(Δt))
eq_simulator = NBSimulator(Δt, eq_steps, thermostat = eq_thermostat)
potential = InteratomicPotentials.LennardJones(austrip(1.657e-21u"J"), austrip(0.34u"nm"), austrip(0.765u"nm"), [:Ar])

eq_result = @time simulate(initial_system, eq_simulator, potential)

temp = @time plot_temperature(eq_result, 10)
energy = @time plot_energy(eq_result, 10)

prod_steps = 5000
prod_simulator = NBSimulator(Δt, prod_steps, t₀ = get_time(eq_result))

prod_result = @time simulate(get_system(eq_result), prod_simulator, potential)

display(@time plot_temperature!(temp, prod_result, 10))
display(@time plot_energy!(energy, prod_result, 10))

rdf = @time plot_rdf(prod_result, potential.σ, Int(0.95 * prod_steps))
display(rdf)
savefig(rdf, "artifacts/argon_lj_nbs_ip_rdf.svg")

;