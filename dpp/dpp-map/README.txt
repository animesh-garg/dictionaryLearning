Code and data associated with the 2012 NIPS paper
"Near-Optimal MAP Inference for Determinantal Point Processes"
--------------------------------------------------------------

Political Data
--------------

See README.text in the politicking/data folder.


Code Installation
-----------------

Start MATLAB from the code directory and:
1) Go to the lbfgs directory and run "install_lbfgs".
   (If this generates an error about mxCreateDoubleScalar,
   try changing it to mxCreateScalarDouble.)
   If you get an error about gfortran, it needs to be installed
   or added to MATLAB's mexopts.sh file.
2) Go to the match-util directory and run "mex lap_double.cpp".

Note: All of the code in the lbfgs folder was written by other parties
and comes with its own readme and license files.  Additionally,
match-util/lap_double.cpp is a minor modification to code written by
other parties and contains their corresponding copyrights at the top
of the file.

The code in format_debates.py requires NLTK (http://nltk.org/) to run,
but the results of this script are already stored in politicking/data
if the outputs are all you are interested in.


Code Usage
----------

To make sure all necessary paths are added to the matlabpath, either
start MATLAB from the code directory (which will automatically run the
startup.m file in that directory), or cd to the code directory and run
'startup' before trying to run the other scripts.

To re-produce synthetic experiments from the paper, run
synth_scripty.m.  Note that the graphs will probably not be exactly
identical to those in the paper as there is some randomization (test
matrices are randomly generated).

To re-produce political experiments from the paper, run polit_scripty.m.

Details concerning how the data files in politicking/data were created
can be found in get_debates.py and the format_debates.py helper code
it calls.  (The get_debates.py code can be run to re-produce the data
files from the debate transcripts.  Note that some intermediate files
will also be created.)


Contact Information
-------------------

Jennifer Gillenwater (jgillenw at gmail.com)
Alex Kulesza (kulesza at gmail.com)
