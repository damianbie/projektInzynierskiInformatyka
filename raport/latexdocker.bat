:; echo "Running on *nix";  docker run -i --rm -w /data -v "$(pwd):/data" tianon/latex $*; exit $?
@ECHO OFF
ECHO Running on Windows
docker run -i --rm -w /data -v "%cd%:/data" tianon/latex %*