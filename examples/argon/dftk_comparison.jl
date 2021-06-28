# Script to compare the results of interfacing with DFTK.jl directly and through the ASEPotential.jl -- ase.py -- asedftk.py -- DFTK.jl pipeline

include("../../src/molecular_simulation.jl")

include("./nbs_argon.jl")

N = 8
box_size = 4σ # arbitrarly choosing 4σ

reference_temp = 94.4u"K"
thermostat_prob = 0.1 # this number was chosen arbitrarily

eq_steps = 20000
Δt = 1e-2u"ps"

eq_result, eq_bodies = simulate_lennard_jones_argon_equilibration(N, box_size, Δt, eq_steps, reference_temp, thermostat_prob)

display(plot_rdf(eq_result, sample_fraction=2))

lattice = box_size * [[1. 0 0]; [0 1. 0]; [0 0 1.]]
kpts = [1, 1, 1]
ecut = 10u"hartree"
tol=1e-6

dftk_parameters = DFTKForceGenerationParameters(
    box_size=box_size,
    psp=ElementPsp(:Ar, psp=load_psp(list_psp(:Ar, functional="lda")[1].identifier)),
    lattice=lattice,
    Ecut=ecut,
    kgrid=kpts,
    tol=tol,
    # α=0.7,
    # mixing=LdosMixing()
)

dftk_forces = generate_forces(eq_bodies, dftk_parameters)
println(dftk_forces)

ase_dftk_parameters = ASEForceGenerationParameters(
    box_size,
    ElementCoulomb(:Ar),
    lattice,
    ASEPotential.DFTKCalculatorParameters(
        ecut=ecut,
        kpts=kpts,
        scftol=tol,
        n_threads=8
    )
)

ase_dftk_forces = generate_forces(eq_bodies, ase_dftk_parameters)
println(ase_dftk_forces)

# Comparing these results isn't really meaningful because the random number generators aren't seeded in the same way

;
