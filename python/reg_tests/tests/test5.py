from __future__ import print_function
############################################################
# DO NOT USE THIS SCRIPT AS A REFERENCE FOR HOW TO USE ADFLOW
# THIS SCRIPT USES PRIVATE INTERNAL FUNCTIONALITY THAT IS
# SUBJECT TO CHANGE!!
############################################################
import sys, os, copy
from mpi4py import MPI
from baseclasses import AeroProblem
from mdo_regression_helper import *
from commonUtils import *

# ###################################################################
# DO NOT USE THIS IMPORT STRATEGY! THIS IS ONLY USED FOR REGRESSION
# SCRIPTS ONLY. Use 'from adflow import ADFLOW' for regular scripts.
sys.path.append(os.path.abspath('../../'))
from python.pyADflow import ADFLOW
# ###################################################################

# ****************************************************************************
printHeader('Test 5: MDO tutorial -- Viscous -- Scalar JST')

# ****************************************************************************
gridFile = '../inputFiles/mdo_tutorial_viscous_scalar_jst.cgns'

options = copy.copy(adflowDefOpts)

options.update(
        {'gridfile': gridFile,
         'mgcycle':'2w',
         'equationtype':'Laminar NS',
         'cfl':1.5,
         'cflcoarse':1.25,
         'ncyclescoarse':250,
         'ncycles':10000,
         'monitorvariables':['cpu', 'resrho','resturb','cl','cd','totalr'],
         'usenksolver':True,
         'l2convergence':1e-14,
         'l2Convergencecoarse':1e-2,
         'nkswitchtol':1e-2,
         'adjointl2convergence': 1e-14,
     }
)

# Setup aeroproblem, cfdsolver, mesh and geometry.
ap = AeroProblem(name='mdo_tutorial', alpha=1.8, beta=0.0, mach=0.50,
                 P=137.0, T=293.15, R=287.87,
                 areaRef=45.5, chordRef=3.25, xRef=0.0, yRef=0.0, zRef=0.0,
                 evalFuncs=defaultFuncList)

def setup_cb(comm):

    # Create the solver
    CFDSolver = ADFLOW(options=options, debug=False)

    return CFDSolver, None, None, None

if __name__ == "__main__":

    solve = True
    if 'solve' not in sys.argv:
        options['restartfile'] = gridFile
        solve = False

    CFDSolver, _, _, _ = setup_cb(MPI.COMM_WORLD)

    standardTest(CFDSolver, ap, solve)
