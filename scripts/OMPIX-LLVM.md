Build Steps: OMPIX + LLVM/OpenMP
--------------------------------

Quick summary of build steps (see scripts in `llvm/` and `ompix` dirs)

Note: Must manually edit paths at top of scripts, see `XXX: Edit here` marks

 - 0. Move to source directory and run the following scripts...

 - 1. `ompix/build_ompix.sh`: Build ompix stack, summary of steps:
        - 1.a) libevent
        - 1.b) pmix
              - ompi: Requires path to libevent
        - 1.c) ompi
              - ompi: Requires path to PMIX and libevent
        - 1.d) moc
              - moc: Requires path to OMPI and PMIX

 - 2. `llvm/*`: Setup and Build llvm with libomp runtime
        - Note: Must manually edit paths at top of scripts
        - `llvm/llvm_setup_git.sh`: Setup LLVM source/build trees (first time)
        - `llvm/llvm_build_git.sh`: Build LLVM+OpenMP
              - libomp: Requires path to PMIX inc/lib

 - Note: The `env_*.sh` scripts can be used to setup EnvVars
   (e.g., PATH, LD_LIBRARY_PATH).


